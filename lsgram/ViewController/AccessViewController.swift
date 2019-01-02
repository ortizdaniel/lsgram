//
//  AccessViewController.swift
//  lsgram
//
//  Created by Carla Vendrell on 24/12/2018.
//  Copyright © 2018 Daniel. All rights reserved.
//

import SwiftyJSON
import UIKit

class AccessViewController : UIViewController {
    
    @IBOutlet weak var accessButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var welcomeBackLabel: UILabel!
    
    var gradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accessButton.layer.cornerRadius = 8
        logoutButton.layer.cornerRadius = 8
        welcomeBackLabel.text = "\("welcome".localize())\(UserDefaults.standard.object(forKey: "username") as? String ?? "")!"
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
    
    @IBAction func logoutPressed(_ sender: Any) {
        let prefs = UserDefaults.standard
        prefs.removeObject(forKey: "username")
        prefs.synchronize()
    }
}
