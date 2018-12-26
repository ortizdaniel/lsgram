//
//  LoginViewController.swift
//  lsgram
//
//  Created by Carla Vendrell on 25/12/2018.
//  Copyright © 2018 Daniel. All rights reserved.
//

import Foundation
import UIKit
import JVFloatLabeledTextField

public class LoginViewController : UIViewController {
    
    @IBOutlet weak var tfName: JVFloatLabeledTextField!
    @IBOutlet weak var tfPassword: JVFloatLabeledTextField!
    
    @IBOutlet weak var errorNameLabel: UILabel!
    @IBOutlet weak var errorPasswordLabel: UILabel!
    @IBOutlet weak var constraintErrorName: NSLayoutConstraint!
    @IBOutlet weak var constraintErrorPassword: NSLayoutConstraint!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var registerLabel: UILabel!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        signInButton.layer.cornerRadius = 8
        
        registerLabel.text = "Don't have an account yet? SIGN UP HERE"
        registerLabel.halfTextColorChange(fullText: registerLabel.text!, changeText: "SIGN UP HERE")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        registerLabel.isUserInteractionEnabled = true
        registerLabel.addGestureRecognizer(tap)
        
        errorNameLabel.isHidden = true
        errorPasswordLabel.isHidden = true
        constraintErrorName.priority = UILayoutPriority(rawValue: 10)
        constraintErrorPassword.priority = UILayoutPriority(rawValue: 10)
    }
    
    @objc func handleTap(gestureRecognizer: UIGestureRecognizer) {
        performSegue(withIdentifier: "changeRegister", sender: gestureRecognizer)
    }
    
    @IBAction func nameChanged(_ sender: Any) {
        errorNameLabel.isHidden = true
        constraintErrorName.priority = UILayoutPriority(rawValue: 10)
    }
    @IBAction func passwordChanged(_ sender: Any) {
        errorPasswordLabel.isHidden = true
        constraintErrorPassword.priority = UILayoutPriority(rawValue: 10)
    }
    
    
    @IBAction func signInClick(_ sender: Any) {
        if (!checkErrors()) {
            //TODO check credentials
            //performSegue(withIdentifier: "login", sender: sender)
        }
    }
    
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "login") {
            //TODO manage user
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
        }
        
        return error
    }
}
