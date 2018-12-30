//
//  CameraViewController.swift
//  lsgram
//
//  Created by Carla Vendrell on 29/12/2018.
//  Copyright © 2018 Daniel. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import OpalImagePicker
import Photos
import ImageSlideshow

class CameraViewController : UIViewController, OpalImagePickerControllerDelegate, UIImagePickerControllerDelegate, MorePhotosListener {
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var previewButton: ImageSlideshow!
    @IBOutlet weak var previewIndicator: UILabel!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var selectedImages = Array<UIImage>()
    var refreshListener: RefreshListener!
    
    @IBOutlet weak var cameraView: UIView!
    
    override func viewDidLoad() {
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
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            cameraView.layer.addSublayer(videoPreviewLayer!)
        } catch {
            print(error)
        }
    }
    
    private func noCameraAvaliable() {
        cameraButton.isEnabled = false
        cameraButton.backgroundColor = UIColor.lightGray
        cameraButton.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    private func cameraAvailable() {
        cameraButton.isEnabled = true
        cameraButton.backgroundColor = UIColor.white
        cameraButton.layer.borderColor = UIColor(red: 238.0 / 255.0, green: 88.0 / 255.0, blue: 108.0 / 255.0, alpha: 1.0).cgColor
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
                    }
                })
            default:
                break
        }
    }
    
    private func noPhotos() {
        self.showAlert(title: "No access to Photo Gallery", message: "This app does not have access to the photo gallery. To upload images, be sure to activate the permissions at the phone's settings", buttonText: "OK", callback: nil)
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
