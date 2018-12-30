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

class MapViewController : UIViewController, UITextFieldDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    @IBOutlet weak var settingsStack: UIStackView!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var switchFollowing: UISwitch!
    @IBOutlet weak var tfMinVotes: UITextField!
    
    var settingsToggled: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
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
            
            let annotation = PostMapPoint(post: post)
            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            annotation.coordinate = coord
            annotation.title = post.getTitle()
            
            mapView.addAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let point = view.annotation as? PostMapPoint {
            let post = point.post
            performSegue(withIdentifier: "postDetailFromMap", sender: post)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postDetailFromMap",
            let dest = segue.destination as? PostViewController,
            let post = sender as? PostItem {
            dest.post = post
        }
    }
    
    @IBAction func addNewPost(_ sender: Any) {
        performSegue(withIdentifier: "newpostMap", sender: sender)
        self.tabBarController?.tabBar.isHidden = true
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
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
