//
//  PostDetailsViewController.swift
//  lsgram
//
//  Created by Carla Vendrell on 27/12/2018.
//  Copyright © 2018 Daniel. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import ImageSlideshow
import SwiftyJSON

class PostDetailsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating, UITextViewDelegate, RequestHandler {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var postImage: ImageSlideshow!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var matchingItems: [MKMapItem] = []
    let searchController = UISearchController(searchResultsController: nil)
    var selectedPin: MKPlacemark? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initImage()
        setSearchController()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        titleTextView.delegate = self
        descTextView.delegate = self
        
        requestLocationPermissions()
    }
    
    private func initImage() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        postImage.isUserInteractionEnabled = true
        postImage.addGestureRecognizer(tapGestureRecognizer)
        postImage.circular = false
        postImage.pageIndicator = nil
        postImage.draggingEnabled = false
        
        postImage.setImageInputs([
            ImageSource(image: UIImage(named: "logo")!),
            ImageSource(image: UIImage(named: "logo_hex")!),
        ])
        postImage.contentScaleMode = .scaleAspectFill //TODO
    }
    
    private func setSearchController() {
        searchController.searchResultsUpdater = self
        
        tableView.alpha = 0
        mapView.alpha = 1
    }
    
    private func requestLocationPermissions() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView.textColor != UIColor.black) {
            DispatchQueue.main.async{
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    
    /*func textViewDidChangeSelection(_ textView: UITextView) {
        if (textView.textColor != UIColor.black) {
            DispatchQueue.main.async{
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }*/
    
    func textViewDidChange(_ textView: UITextView) {
        if (textView.textColor != UIColor.black) {
            textView.textColor = UIColor.black
            let text = textView.text
            
            textView.text = "\(text!.prefix(1))"
        } else {
            if (textView.text == "") {
                textView.textColor = UIColor.lightGray
                if (textView.restorationIdentifier == "title") {
                    textView.text = "Add a title..."
                } else {
                    textView.text = "Add a description..."
                }
                DispatchQueue.main.async{
                    textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
                }
            }
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        postImage.presentFullScreenController(from: self)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.count > 0) {
            tableView.alpha = 1
            mapView.alpha = 0
            
            updateSearchResults(for: self.searchController)
        } else {
            tableView.alpha = 0
            mapView.alpha = 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        dropPinZoomIn(placemark: selectedItem)
        
        tableView.alpha = 0
        mapView.alpha = 1
        searchBar?.text = ""
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBar?.text
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        
        search.start(completionHandler: {(response, error) in
            
            if error != nil {
                print("Error occurred in search: \(error!.localizedDescription)")
            } else if response!.mapItems.count == 0 {
                print("No matches found")
            } else {
                self.matchingItems = response!.mapItems
                self.tableView.reloadData()
            }
        })
    }
    
    func parseAddress(selectedItem: MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func postClicked(_ sender: Any) {
        if (titleTextView.textColor != UIColor.black) {
            self.showAlert(title: "No title", message: "A title for this post must be specified.", buttonText: "OK", callback: nil)
        } else {
            if (mapView.annotations.count == 0) {
                self.showAlert(title: "No location specified", message: "Without a location, other users won't be able to find your post through the map view. Please specify a location.", buttonText: "Post", callback: nil)
            } else {
                LSGram.post(handler: self)
            }
        }
    }
    
    func reqParameters() -> [String: Any] {
        var params: [String: Any] = [:]
        params["title"] = titleTextView.text
        if (descTextView.textColor == UIColor.black) {
            params["caption"] = descTextView.text
        } else {
            params["caption"] = ""
        }
        //TODO poner las imagenes bien
        params["links"] = ["https://i.imgur.com/whPBT1D.jpg"]
        params["latitude"] = mapView.annotations[0].coordinate.latitude
        params["longitude"] = mapView.annotations[0].coordinate.longitude
        params["owner"] = UserDefaults.standard.object(forKey: "username")
        
        return params
    }
    
    func success(response: JSON) {
        let status: String = response["status"].stringValue
        DispatchQueue.main.async {
            if status == "KO" {
                //error
            } else if status == "OK" {
                //TODO hacer pop de las pantallas de foto
                //TODO refresh
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func error(message: String) {
        DispatchQueue.main.async {
            self.showAlert(title: "Error", message: message, buttonText: "Ok", callback: nil)
        }
    }
}
