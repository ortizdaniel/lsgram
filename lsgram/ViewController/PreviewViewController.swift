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
    
    override func viewDidLoad() {
        moreButton.layer.cornerRadius = 30
        doneButton.layer.cornerRadius = 30
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "details") {
            //TODO pasar la informacion
        }
    }
    
    @IBAction func doneClicked(_ sender: Any) {
        performSegue(withIdentifier: "details", sender: sender)
    }
    
    @IBAction func moreClicked(_ sender: Any) {
        listener.addMorePhotos(images: images)
        self.navigationController?.popViewController(animated: true)
    }
    
}
