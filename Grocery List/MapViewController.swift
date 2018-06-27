//
//  MapViewController.swift
//  Grocery List
//
//  Created by Aashana on 11/7/17.
//  Copyright © 2017 Aashana. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import GooglePlaces
import GoogleMaps


class MapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate, GMSAutocompleteViewControllerDelegate {
    
    
    @IBOutlet var mapView : MKMapView!
    @IBOutlet var saveAdd : UIButton!
    var currLocation:CLLocationCoordinate2D!
    let currannotation = MKPointAnnotation()
    var locationManager: CLLocationManager!
    var searchLoc = CLLocationCoordinate2D()
    var address : String!
    var coordinate : CLLocationCoordinate2D!
    var name = "Current Location"
    var flag = 0
    var currLocFlag = 1
    //var currRegion : CLCircularRegion!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Choose your location"
        updateLoc()
    }
    func updateLoc()
    {
        if flag == 1
        {
            saveAdd.setTitle(name, for: .normal)
            setAnnotation(location: coordinate)
            self.locationManager = CLLocationManager()
            address = ""
            // For use in foreground
            
            self.locationManager.requestAlwaysAuthorization()
            searchLoc = coordinate
            if CLLocationManager.locationServicesEnabled()
            {
                locationManager.delegate = self as CLLocationManagerDelegate
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.allowsBackgroundLocationUpdates = true
                locationManager.startUpdatingLocation()
            }
            currLocFlag = 0
            mapView.delegate = self
            mapView.mapType = MKMapType.standard
        }
        else
        {
            mapView.showsUserLocation = false
            self.locationManager = CLLocationManager()
            address = ""
            // For use in foreground
            
            self.locationManager.requestAlwaysAuthorization()
            
            if CLLocationManager.locationServicesEnabled()
            {
                locationManager.delegate = self as CLLocationManagerDelegate
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.allowsBackgroundLocationUpdates = true
                locationManager.startUpdatingLocation()
            }
            mapView.delegate = self
            mapView.mapType = MKMapType.standard
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        currLocation = manager.location!.coordinate
        if currLocation.latitude != 0.0 && currLocation.longitude != 0.0
        {
            locationManager.stopUpdatingLocation()
        }
        if flag == 0
        {
            let span = MKCoordinateSpanMake(0.01, 0.01)
            let region = MKCoordinateRegion(center: currLocation, span: span)
            mapView.setRegion(region, animated: true)
            self.setAnnotation(location: currLocation)
        }
    }
    @IBAction func autocompleteClicked(_ sender: UIButton) {
        
        let placePickerController = GMSAutocompleteViewController()
        placePickerController.delegate = self
        present(placePickerController, animated: true, completion: nil)
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace)
    {
        name = place.name
        address = place.formattedAddress
        saveAdd.setTitle(name, for: .normal)
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        currLocFlag = 0
        getAddress()
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    func getAddress()
    {
        self.view.endEditing(true)
        mapView.showsUserLocation = true
        mapView.removeAnnotation(currannotation)
        mapView.delegate = self
        getMapBySource(mapView, address:address, title: "Chosen location", subtitle: "Chosen location")
    }
    func getMapBySource(_ locationMap:MKMapView?, address:String?, title: String?, subtitle: String?)
    {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address!, completionHandler: {(placemarks, error) -> Void in
            if let validPlacemark = placemarks?[0]{
                self.setSearch(LocCoordinate:(validPlacemark.location?.coordinate)!)
                if(self.searchLoc.latitude != 0.0 )
                {
                    let allAnnotations = self.mapView.annotations
                    self.mapView.removeAnnotations(allAnnotations)
                    self.setAnnotation(location: self.searchLoc)
                }
            }
        })
    }
    func setSearch(LocCoordinate:CLLocationCoordinate2D)
    {
        searchLoc=LocCoordinate
    }
    func setAnnotation(location:CLLocationCoordinate2D)
    {
        //Thread.sleep(forTimeInterval: 1.0)
        let allAnnotations = self.mapView.annotations
        print(location)
        self.mapView.removeAnnotations(allAnnotations)
        let searchPlacemark = MKPlacemark(coordinate: location, addressDictionary: nil)
        let searchAnnotation = MKPointAnnotation()
        searchAnnotation.title = name
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let searchregion = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(searchregion, animated: true)
        if let Location = searchPlacemark.location
        {
            searchAnnotation.coordinate = Location.coordinate
        }
        self.mapView.addAnnotation(searchAnnotation)
    }
    func getAddress(coordinate:CLLocationCoordinate2D)
    {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(CLLocation(latitude:coordinate.latitude, longitude:coordinate.longitude), completionHandler: {
                placemarks, error in
                if error == nil && placemarks?.count != 0 {
                    let placeMark = placemarks!.last
                    if (placeMark?.name) != nil
                    {
                        self.address.append((placeMark?.name!)!)
                        self.name = (placeMark?.name)!
                    }
                    self.saveAdd.setTitle("Current Location", for: .normal)
                    UserDefaults.standard.set(self.address, forKey: "Place")
                    UserDefaults.standard.set(self.currLocation.latitude, forKey: "Latitude")
                    UserDefaults.standard.set(self.currLocation.longitude, forKey: "Longitude")
                    self.navigationController?.popViewController(animated: true)
               }
           })
       }
    func returnData()
    {
        saveAdd.setTitle(name, for: .normal)
        UserDefaults.standard.set(name, forKey: "Place")
        UserDefaults.standard.set(searchLoc.latitude, forKey: "Latitude")
        UserDefaults.standard.set(searchLoc.longitude, forKey: "Longitude")
    }
    func resetData()
    {
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegion(center: currLocation, span: span)
        mapView.setRegion(region, animated: true)
        currannotation.coordinate = currLocation
        currannotation.title = "Current location"
        mapView.addAnnotation(currannotation)
        mapView.showsUserLocation = false
        UserDefaults.standard.set(nil, forKey: "Place")
        UserDefaults.standard.set(nil, forKey: "Latitude")
        UserDefaults.standard.set(nil, forKey: "Longitude")
        saveAdd.setTitle("Search Places", for: .normal)
        currLocFlag = 1
    }
    @IBAction func currentLocation(sender : UIButton)
    {
        updateLoc()
        resetData()
    }
    @IBAction func saveAddress(sender : UIButton)
    {
        if currLocFlag == 1
        {
            getAddress(coordinate: currLocation)
        }
        else
        {
            returnData()
            self.navigationController?.popViewController(animated: true)
        }
    }
}
    
