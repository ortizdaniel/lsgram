//
//  CameraViewController.swift
//  lsgram
//
//  Created by Carla Vendrell on 29/12/2018.
//  Copyright © 2018 Daniel. All rights reserved.
//

import UIKit
import AVFoundation
import OpalImagePicker
import Photos
import ImageSlideshow

class CameraViewController : UIViewController, OpalImagePickerControllerDelegate, UIImagePickerControllerDelegate, MorePhotosListener, AVCapturePhotoCaptureDelegate {
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var previewButton: ImageSlideshow!
    @IBOutlet weak var previewIndicator: UILabel!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var capturePhotoOutput: AVCapturePhotoOutput?
    
    var selectedImages = Array<UIImage>()
    var refreshListener: RefreshListener!
    
    var flash: AVCaptureDevice.FlashMode = .auto
    @IBOutlet weak var flashIcon: UIButton!
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var noCameraIcon: UIImageView!
    
    override func viewDidLoad() {
        flash = .auto
        cameraButton.layer.cornerRadius = 70 / 2
        cameraButton.layer.borderWidth = 3
        
        previewIndicator.layer.masksToBounds = true
        previewIndicator.layer.cornerRadius = 10
        previewIndicator.isHidden = true
        
        previewButton.layer.cornerRadius = 20
        previewButton.isHidden = true
        previewButton.circular = false
        previewButton.pageIndicator = nil
        previewButton.draggingEnabled = false
        previewButton.contentScaleMode = .scaleAspectFill //TODO
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(previewClicked))
        previewButton.addGestureRecognizer(gestureRecognizer)
    
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            authorisationStatusCamera()
        } else {
            noCameraAvaliable()
        }
        checkPhotosAvaliability()
    }
    
    func authorisationStatusCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
            case .authorized:
                self.cameraSetup()
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        self.cameraSetup()
                    }
                }
            case .denied, .restricted:
                self.noCameraAvaliable()
                return
            default:
                break
        }
    }
    
    func cameraSetup() {
        cameraAvailable()
        
        let captureDevice = AVCaptureDevice.default(for: .video)
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            DispatchQueue.main.async {
                self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession!)
                self.videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.videoPreviewLayer?.frame = self.view.layer.bounds
            
                self.cameraView.layer.insertSublayer(self.videoPreviewLayer!, at: 0)
                
                self.capturePhotoOutput = AVCapturePhotoOutput()
                self.capturePhotoOutput?.isHighResolutionCaptureEnabled = true
                self.captureSession?.addOutput(self.capturePhotoOutput!)
            }
            
            captureSession?.startRunning()
        } catch {
            print(error)
        }
    }
    
    private func noCameraAvaliable() {
        cameraButton.backgroundColor = UIColor.lightGray
        cameraButton.layer.borderColor = UIColor.darkGray.cgColor
        self.noCameraIcon.isHidden = false
    }
    
    private func cameraAvailable() {
        DispatchQueue.main.async {
            self.cameraButton.isEnabled = true
            self.cameraButton.backgroundColor = UIColor.white
            self.cameraButton.layer.borderColor = UIColor(red: 238.0 / 255.0, green: 88.0 / 255.0, blue: 108.0 / 255.0, alpha: 1.0).cgColor
            self.noCameraIcon.isHidden = true
        }
    }
    
    private func takePhotoAuthorization() -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                return true
            case .denied, .restricted, .notDetermined:
                return false
            default:
                break
        }
        return false
    }
    
    @IBAction func flashChanged(_ sender: Any) {
        if (flash == .auto) {
            flash = .on
            flashIcon.setImage(UIImage(named: "flash-on"), for: .normal)
        } else if (flash == .on) {
            flash = .off
            flashIcon.setImage(UIImage(named: "flash-off"), for: .normal)
        } else {
            flash = .auto
            flashIcon.setImage(UIImage(named: "flash-auto"), for: .normal)
        }
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        if (cameraButton.layer.borderColor != UIColor.darkGray.cgColor) { //esta disponible
            self.cameraButton.backgroundColor = UIColor.white
        }
        if (takePhotoAuthorization()) {
            guard let capturePhotoOutput = self.capturePhotoOutput else { return }
            let photoSettings = AVCapturePhotoSettings()
            photoSettings.isAutoStillImageStabilizationEnabled = true
            photoSettings.isHighResolutionPhotoEnabled = true
            photoSettings.flashMode = flash
            capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
        } else {
            self.showAlert(title: "camera_no_access".localize(), message: "camera_no_access_message".localize(), buttonText: "OK", callback: nil)
        }
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        self.cameraButton.backgroundColor = UIColor.lightGray
    }
    
    
    //https://stackoverrun.com/es/q/12745048
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // Make sure we get some photo sample buffer
        guard error == nil else {
            print("Fail to capture photo: \(String(describing: error))")
            return
        }
        
        // Convert photo same buffer to a jpeg image data by using // AVCapturePhotoOutput
        guard let imageData = photo.fileDataRepresentation() else {
                return
        }
        
        // Check if UIImage could be initialized with image data
        guard let capturedImage = UIImage.init(data: imageData , scale: 1.0) else {
            print("Fail to convert image data to UIImage")
            return
        }
        
        // Get original image width/height
        let imgWidth = capturedImage.size.width
        let imgHeight = capturedImage.size.height
        // Get origin of cropped image
        let imgOrigin = CGPoint(x: (imgWidth - imgHeight)/2, y: (imgHeight - imgHeight)/2)
        // Get size of cropped iamge
        let imgSize = CGSize(width: imgHeight, height: imgHeight)
        
        // Check if image could be cropped successfully
        guard let imageRef = capturedImage.cgImage?.cropping(to: CGRect(origin: imgOrigin, size: imgSize)) else {
            print("Fail to crop image")
            return
        }
        
        let imageToSave = UIImage(cgImage: imageRef, scale: 1.0, orientation: .right).fixedOrientation()
        self.selectedImages.append(imageToSave!)
        performSegue(withIdentifier: "preview", sender: self)
    }
    
    @IBAction func galleryClicked(_ sender: Any) {
        authorisationStatusPhotos()
    }
    
    private func checkPhotosAvaliability() {
        switch PHPhotoLibrary.authorizationStatus() {
            case .authorized, .notDetermined:
                DispatchQueue.main.async {
                    self.galleryButton.setBackgroundImage(UIImage(named: "gallery") as UIImage?, for: .normal)
                }
            case .denied, .restricted:
                DispatchQueue.main.async {
                    self.galleryButton.setBackgroundImage(UIImage(named: "no-gallery") as UIImage?, for: .normal)
                }
            default:
                break
        }
    }
    
    func authorisationStatusPhotos() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
            case .authorized:
                displayPhotoLibrary()
            case .denied, .restricted:
                noPhotos()
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({ (status) in
                    if status == PHAuthorizationStatus.authorized {
                        self.displayPhotoLibrary()
                    } else {
                        DispatchQueue.main.async {
                            self.galleryButton.setBackgroundImage(UIImage(named: "no-gallery") as UIImage?, for: .normal)
                        }
                    }
                })
            default:
                break
        }
    }
    
    private func noPhotos() {
        self.showAlert(title: "gallery_no_access".localize(), message: "gallery_no_access_message".localize(), buttonText: "OK", callback: nil)
        DispatchQueue.main.async {
            self.galleryButton.setBackgroundImage(UIImage(named: "no-gallery") as UIImage?, for: .normal)
        }
    }
    
    private func displayPhotoLibrary() {
        DispatchQueue.main.async {
            self.galleryButton.setBackgroundImage(UIImage(named: "gallery") as UIImage?, for: .normal)
        }
        
        let imagePicker = OpalImagePickerController()
        imagePicker.imagePickerDelegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "preview") {
            let preview: PreviewViewController = segue.destination as! PreviewViewController
            preview.images = self.selectedImages
            preview.listener = self
            preview.refreshListener = self.refreshListener
        }
    }
    
    func imagePicker(_ picker: OpalImagePickerController, didFinishPickingImages images: [UIImage]) {
        self.selectedImages.append(contentsOf: images)
        performSegue(withIdentifier: "preview", sender: self)
        
        picker.dismiss(animated: true)
    }
    
    @objc func previewClicked(_ sender: Any) {
        performSegue(withIdentifier: "preview", sender: self)
    }
    
    func addMorePhotos(images: [UIImage]) {
        if (images.count > 0) {
            previewButton.isHidden = false
            previewButton.setImageInputs([ImageSource(image: images[0])])
            
            previewIndicator.isHidden = false
            previewIndicator.text = String(images.count)
        }
        
        selectedImages = images
    }
    
    func removeAllPhotos() {
        selectedImages.removeAll()
        previewButton.isHidden = true
        previewIndicator.isHidden = true
        
    }
    
}
