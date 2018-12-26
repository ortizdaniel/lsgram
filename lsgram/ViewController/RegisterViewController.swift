//
//  Register.swift
//  lsgram
//
//  Created by Carla Vendrell on 25/12/2018.
//  Copyright © 2018 Daniel. All rights reserved.
//

import Foundation
import UIKit
import JVFloatLabeledTextField

public class RegisterViewController : UIViewController, RequestHandler {
    
    @IBOutlet weak var tfName: JVFloatLabeledTextField!
    @IBOutlet weak var tfPassword: JVFloatLabeledTextField!
    @IBOutlet weak var tfPassword2: JVFloatLabeledTextField!
    
    @IBOutlet weak var errorNameLabel: UILabel!
    @IBOutlet weak var errorPasswordLabel: UILabel!
    @IBOutlet weak var errorPassword2Label: UILabel!
    
    @IBOutlet weak var constraintErrorName: NSLayoutConstraint!
    @IBOutlet weak var constraintErrorPassword: NSLayoutConstraint!
    @IBOutlet weak var constraintErrorPassword2: NSLayoutConstraint!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 229.0 / 255, green: 237.0 / 255, blue: 239.0 / 255, alpha: 1.0)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        signUpButton.layer.cornerRadius = 8
        
        errorNameLabel.isHidden = true
        errorPasswordLabel.isHidden = true
        errorPassword2Label.isHidden = true
        constraintErrorName.priority = UILayoutPriority(rawValue: 10)
        constraintErrorPassword.priority = UILayoutPriority(rawValue: 10)
        constraintErrorPassword2.priority = UILayoutPriority(rawValue: 10)
    }
    
    @IBAction func nameChanged(_ sender: Any) {
        errorNameLabel.isHidden = true
        constraintErrorName.priority = UILayoutPriority(rawValue: 10)
    }
    
    @IBAction func passwordChanged(_ sender: Any) {
        errorPasswordLabel.isHidden = true
        constraintErrorPassword.priority = UILayoutPriority(rawValue: 10)
    }
    
    @IBAction func password2Changed(_ sender: Any) {
        errorPassword2Label.isHidden = true
        constraintErrorPassword2.priority = UILayoutPriority(rawValue: 10)
    }
    
    @IBAction func signUpClick(_ sender: Any) {
        if (!checkErrors()) {
            LSGram.register(handler: self)
        }
    }
    
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "register") {
            let prefs = UserDefaults.standard
            prefs.set(tfName.text, forKey: "username")
            prefs.synchronize()
        }
    }
    
    private func checkErrors() -> Bool {
        var error = false
        if (tfName.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
            errorNameLabel.isHidden = false
            constraintErrorName.priority = UILayoutPriority(rawValue: 999)
            error = true
            errorNameLabel.text = "Field cannot be empty"
        }
        
        if (tfPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
            errorPasswordLabel.isHidden = false
            constraintErrorPassword.priority = UILayoutPriority(rawValue: 999)
            error = true
            errorPasswordLabel.text = "Field cannot be empty"
        } else {
            if (tfPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines).count < 6) {
                errorPasswordLabel.isHidden = false
                constraintErrorPassword.priority = UILayoutPriority(rawValue: 999)
                error = true
                errorPasswordLabel.text = "Password must be at least 6 characters long"
            }
        }
        
        if (tfPassword2.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
            errorPassword2Label.isHidden = false
            constraintErrorPassword2.priority = UILayoutPriority(rawValue: 999)
            error = true
            errorPassword2Label.text = "Field cannot be empty"
        } else {
            if (tfPassword2.text!.trimmingCharacters(in: .whitespacesAndNewlines) != tfPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)) {
                errorPassword2Label.isHidden = false
                constraintErrorPassword2.priority = UILayoutPriority(rawValue: 999)
                error = true
                errorPassword2Label.text = "Passwords do not match"
            }
        }
        
        return error
    }
    
    func reqParameters() -> [String: Any] {
        var params: [String: Any] = [:]
        params["username"] = tfName.text ?? ""
        params["password"] = tfPassword.text ?? ""
        return params
    }
    
    func success(response: [String: Any]) {
        let status: String = (response["status"] as? String) ?? ""
        DispatchQueue.main.async {
            if status == "KO" {
                self.showAlert(title: "Error", message: "This username is already taken. Please choose another one.", buttonText: "Ok", callback: nil)
            } else if status == "OK" {
                self.performSegue(withIdentifier: "register", sender: self)
            }
        }
    }
    
    func error(message: String) {
        DispatchQueue.main.async {
            self.showAlert(title: "Error", message: message, buttonText: "Ok", callback: nil)
        }
    }
    
}
