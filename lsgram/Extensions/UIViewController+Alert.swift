//
//  UIViewController+Alert.swift
//  lsgram
//
//  Created by Daniel on 26/12/2018.
//  Copyright © 2018 Daniel. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String,
                   message: String,
                   buttonText: String,
                   callback: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: buttonText, style: UIAlertAction.Style.default, handler: callback))
        self.present(alert, animated: true, completion: nil)
    }
}

extension UITableViewCell {
    
    func showAlert(title: String,
                   message: String,
                   buttonText: String,
                   whoPresents: UIViewController,
                   callback: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: buttonText, style: UIAlertAction.Style.default, handler: callback))
        whoPresents.present(alert, animated: true, completion: nil)
    }
}
