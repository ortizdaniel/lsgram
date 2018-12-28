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
import INSPhotoGallery

class PostDetailsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var postImage: UIImageView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var matchingItems: [MKMapItem] = []
    let searchController = UISearchController(searchResultsController: nil)
    var selectedPin: MKPlacemark? = nil
    
    lazy var photos: [INSPhotoViewable] = {
        return [
            INSPhoto(image: UIImage(named: "fullSizeImage")!, thumbnailImage: UIImage(named: "logo")!),
            INSPhoto(image: UIImage(named: "fullSizeImage")!, thumbnailImage: UIImage(named: "logo")!),
            INSPhoto(image: UIImage(named: "fullSizeImage")!, thumbnailImage: UIImage(named: "logo")!),
            INSPhoto(image: UIImage(named: "fullSizeImage")!, thumbnailImage: UIImage(named: "logo")!),
            ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        postImage.isUserInteractionEnabled = true
        postImage.addGestureRecognizer(tapGestureRecognizer)
        
        setSearchController()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        //tableView.handleMapSearchDelegate = self
        
        requestLocationPermissions()
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
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        //TODO INSPhotoGallery
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
                print("Matches found")
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
    
}
