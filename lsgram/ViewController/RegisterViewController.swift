//
//  Register.swift
//  lsgram
//
//  Created by Carla Vendrell on 25/12/2018.
//  Copyright © 2018 Daniel. All rights reserved.
//

import SwiftyJSON
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
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var formView: UIView!
    var scrollViewHeight: CGFloat = 0
    
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
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        self.hideKeyboardWhenTappedAround()
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = UIEdgeInsets.zero
            scrollView.contentSize.height = scrollViewHeight
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
            scrollViewHeight = scrollView.contentSize.height
            scrollView.contentSize.height = formView.frame.size.height + formView.frame.origin.y + 16
        }
        
        scrollView.scrollIndicatorInsets = scrollView.contentInset
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
    
    private func checkErrors() -> Bool {
        var error = false
        if (tfName.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
            errorNameLabel.isHidden = false
            constraintErrorName.priority = UILayoutPriority(rawValue: 999)
            error = true
            errorNameLabel.text = "error_empty_field".localize()
        }
        
        if (tfPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
            errorPasswordLabel.isHidden = false
            constraintErrorPassword.priority = UILayoutPriority(rawValue: 999)
            error = true
            errorPasswordLabel.text = "error_empty_field".localize()
        } else {
            if (tfPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines).count < 6) {
                errorPasswordLabel.isHidden = false
                constraintErrorPassword.priority = UILayoutPriority(rawValue: 999)
                error = true
                errorPasswordLabel.text = "error_password".localize()
            }
        }
        
        if (tfPassword2.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
            errorPassword2Label.isHidden = false
            constraintErrorPassword2.priority = UILayoutPriority(rawValue: 999)
            error = true
            errorPassword2Label.text = "error_empty_field".localize()
        } else {
            if (tfPassword2.text!.trimmingCharacters(in: .whitespacesAndNewlines) != tfPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)) {
                errorPassword2Label.isHidden = false
                constraintErrorPassword2.priority = UILayoutPriority(rawValue: 999)
                error = true
                errorPassword2Label.text = "error_password2".localize()
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
    
    func success(response: JSON) {
        let status: String = response["status"].stringValue
        DispatchQueue.main.async {
            if status == "KO" {
                self.showAlert(title: "Error", message: "error_username".localize(), buttonText: "OK", callback: nil)
            } else if status == "OK" {
                if let app = UIApplication.shared.delegate {
                    if let win = app.window {
                        self.switchToMainView(win: win!)
                    }
                }
            }
        }
    }
    
    func error(message: String) {
        DispatchQueue.main.async {
            self.showAlert(title: "Error", message: message, buttonText: "OK", callback: nil)
        }
    }
    
    func switchToMainView(win: UIWindow) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "main") as UIViewController
        present(vc, animated: true, completion: nil)
        
        let prefs = UserDefaults.standard
        prefs.set(self.tfName.text, forKey: "username")
        prefs.set(self.tfPassword.text, forKey: "password")
        prefs.synchronize()
    }
    
}
