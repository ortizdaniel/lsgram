//
//  MapViewController.swift
//  lsgram
//
//  Created by Carla Vendrell on 27/12/2018.
//  Copyright © 2018 Daniel. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class MapViewController : UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var button: UIButton!
    let locationManager = CLLocationManager()
    @IBOutlet weak var settingsStack: UIStackView!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var switchFollowing: UISwitch!
    @IBOutlet weak var tfMinVotes: UITextField!
    
    var settingsToggled: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createFloatingButton()
        requestLocationPermissions()
        settingsStack.setView([settingsView], gone: true, animated: false)
        settingsView.addBottomBorderWithColor(color: .lightGray, width: 1)
        tfMinVotes!.keyboardType = .numberPad
        tfMinVotes!.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //load waypoints
        mapView.removeAnnotations(mapView.annotations)
        for post in PostList.instance().filtered() {
            let lat = post.getLatitude()
            let lng = post.getLongitude()
            
            let annotation = MKPointAnnotation()
            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            annotation.coordinate = coord
            annotation.title = post.getTitle()
            
            mapView.addAnnotation(annotation)
        }
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        settingsStack.setView([settingsView], gone: settingsToggled, animated: true)
        settingsToggled = !settingsToggled
    }
    
    @IBAction func switchFollowingChanged(_ sender: Any) {
        DispatchQueue.main.async {
            let isOn: Bool = self.switchFollowing.isOn
            if self.tfMinVotes!.text?.isEmpty ?? false {
                if isOn {
                    PostList.instance().filterFollowing(
                        following: FollowingList.instance().following()
                    )
                } else {
                    PostList.instance().noFilter()
                }
            } else {
                let minVotes: Int = Int(self.tfMinVotes.text!)!
                if isOn {
                    PostList.instance().filterFollowingAndMinLikes(
                        following: FollowingList.instance().following(),
                        amount: minVotes
                    )
                } else {
                    PostList.instance().filterMinLikes(amount: minVotes)
                }
            }
            self.viewDidAppear(false)
        }
    }
    
    @IBAction func minVotesChanged(_ sender: Any) {
        switchFollowingChanged(sender)
    }
    
    
    @IBAction func logoutPressed(_ sender: Any) {
        let prefs = UserDefaults.standard
        prefs.removeObject(forKey: "username")
        prefs.synchronize()
        
        performSegue(withIdentifier: "logoutMap", sender: sender)
    }
    
    private func createFloatingButton() {
        let buttonSize = 48
        let buttonX = self.view.frame.width - 70
        let buttonY = self.view.frame.height - 70 - (self.tabBarController?.tabBar.frame.height)!
        
        button = UIButton(frame: CGRect(origin: CGPoint(x: buttonX, y: buttonY), size: CGSize(width: buttonSize, height: buttonSize)))
        button.backgroundColor = UIColor(red: 238.0 / 255.0, green: 88.0 / 255.0, blue: 108.0 / 255.0, alpha: 1.0)
        button.layer.cornerRadius = CGFloat(buttonSize / 2)
        button.setImage(UIImage(named: "plus-icon-white") as UIImage?, for: .normal)
        button.addTarget(self, action: #selector(addNewPost), for: .touchUpInside)
        
        self.navigationController?.view.addSubview(button)
    }
    
    @objc func addNewPost() {
        performSegue(withIdentifier: "newpostMap", sender: self)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        button.isHidden = false
        button.isEnabled = true
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        button.isHidden = true
        button.isEnabled = false
    }
    
    private func requestLocationPermissions() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        return string.rangeOfCharacter(from: invalidCharacters) == nil
    }
}
