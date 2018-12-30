//
//  PreviewViewController.swift
//  lsgram
//
//  Created by Carla Vendrell on 29/12/2018.
//  Copyright © 2018 Daniel. All rights reserved.
//

import Foundation
import UIKit
import ImageSlideshow

class PreviewViewController : UIViewController {
    
    @IBOutlet weak var imageSlider: ImageSlideshow!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    var images: [UIImage]!
    var listener: MorePhotosListener!
    var refreshListener: RefreshListener!
    var goBack: Bool!
    
    override func viewDidLoad() {
        moreButton.layer.cornerRadius = 30
        doneButton.layer.cornerRadius = 30
        
        imageSlider.circular = false
        imageSlider.zoomEnabled = true
        let pageIndicator = UIPageControl()
        pageIndicator.currentPageIndicatorTintColor = UIColor(red: 238.0 / 255.0, green: 88.0 / 255.0, blue: 108.0 / 255.0, alpha: 1.0)
        imageSlider.pageIndicator = pageIndicator
        
        var sources = Array<ImageSource>()
        for image in images {
            sources.append(ImageSource(image: image))
        }
        imageSlider.setImageInputs(sources)
        
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        statusBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.isOpaque = true
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        goBack = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (goBack) {
            listener.removeAllPhotos()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "details") {
            goBack = false
            let postDetails: PostDetailsViewController = segue.destination as! PostDetailsViewController
            postDetails.images = self.images
            postDetails.refreshListener = self.refreshListener
        }
    }
    
    @IBAction func doneClicked(_ sender: Any) {
        goBack = false
        performSegue(withIdentifier: "details", sender: sender)
    }
    
    @IBAction func moreClicked(_ sender: Any) {
        goBack = false
        listener.addMorePhotos(images: images)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteImage(_ sender: Any) {
        let alert = UIAlertController(title: "Do you want to delete this picture?",
                                      message: "The picture will be removed from the set of selected images.",
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { (alert) in
            self.images.remove(at: self.imageSlider.currentPage)
            if (self.images.count > 0) {
                let index = self.imageSlider.currentPage
                
                var sources = Array<ImageSource>()
                for image in self.images {
                    sources.append(ImageSource(image: image))
                }
                
                self.imageSlider.setImageInputs(sources)
                if (index > 0) {
                    self.imageSlider.setCurrentPage(index - 1, animated: true)
                } else {
                    self.imageSlider.setCurrentPage(index, animated: true)
                }
            } else {
                self.listener.removeAllPhotos()
                self.navigationController?.popViewController(animated: true)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
