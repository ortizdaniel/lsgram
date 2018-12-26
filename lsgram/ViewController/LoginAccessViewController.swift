//
//  AccessViewController.swift
//  lsgram
//
//  Created by Carla Vendrell on 24/12/2018.
//  Copyright © 2018 Daniel. All rights reserved.
//

import Foundation
import UIKit

class LoginAccessViewController : UIViewController  {
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    var gradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signInButton.layer.cornerRadius = 8
        signUpButton.layer.cornerRadius = 8
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createGradientLayer()
    }
    
    private func createGradientLayer() {
        let topColor = UIColor(red: 52.0 / 255, green: 82.0 / 255, blue: 93.0 / 255, alpha: 1.0)
        let bottomColor = UIColor(red: 26.0 / 255, green: 41.0 / 255, blue: 47.0 / 255, alpha: 1.0)
        
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
}
