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
    var name : String!
    var flag = 0

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Choose your location"
        if flag == 1
        {
              getAddress(coordinate: coordinate)
        }
        else
        {
            mapView.showsUserLocation = false
            self.locationManager = CLLocationManager()
            address = ""
            // For use in foreground
            
            self.locationManager.requestWhenInUseAuthorization()
            
            if CLLocationManager.locationServicesEnabled()
            {
                locationManager.delegate = self as CLLocationManagerDelegate
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
            }
            mapView.delegate = self
            mapView.mapType = MKMapType.standard
            
            let gestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(handleTap(gestureReconizer:)))
            mapView.addGestureRecognizer(gestureRecognizer)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @objc func handleTap(gestureReconizer: UILongPressGestureRecognizer) {
        mapView.showsUserLocation = true
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        let location = gestureReconizer.location(in: mapView)
        let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
        //UserDefaults.setValue(coordinate, forKey: "UserCoordinates")
        self.coordinate = coordinate
        self.searchLoc = coordinate
        
        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "My location"
        mapView.addAnnotation(annotation)
        getAddress(coordinate:coordinate)
        
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        currLocation = manager.location!.coordinate
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: currLocation, span: span)
        mapView.setRegion(region, animated: true)
        currannotation.coordinate = currLocation
        currannotation.title = "Current location"
        mapView.addAnnotation(currannotation)
    }
    @IBAction func autocompleteClicked(_ sender: UIButton) {
        
        let placePickerController = GMSAutocompleteViewController()
        placePickerController.delegate = self
        present(placePickerController, animated: true, completion: nil)
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        name = place.name
        address = place.formattedAddress
        saveAdd.setTitle(name, for: .normal)
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
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
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        let searchPlacemark = MKPlacemark(coordinate: location, addressDictionary: nil)
        let searchAnnotation = MKPointAnnotation()
        searchAnnotation.title = "Chosen Location"
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
                    self.address.append((placeMark?.name!)! + ",")
                }
                if (placeMark?.locality) != nil
                {
                    self.address.append((placeMark?.locality!)! + ",")
                }
                if (placeMark?.administrativeArea) != nil
                {
                    self.address.append((placeMark?.administrativeArea!)! + ",")
                }
                if (placeMark?.postalCode) != nil
                {
                    self.address.append((placeMark?.postalCode!)! + ",")
                }
                if (placeMark?.country) != nil
                {
                    self.address.append((placeMark?.country!)! + ",")
                }
                if self.flag == 0
                {
                    self.checkAddress(address: self.address)
                }
                
            }
        })
    }
    func checkAddress(address:String)
    {
        let alert = UIAlertController(title: "Verify Address", message: "Is this your chosen location?: "+address , preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in self.returnData()}))
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in self.resetData()}))
        self.present(alert, animated: true, completion: nil)
    }
    func returnData()
    {
        UserDefaults.standard.set(name, forKey: "Place")
        UserDefaults.standard.set(searchLoc.latitude, forKey: "Latitude")
        UserDefaults.standard.set(searchLoc.longitude, forKey: "Longitude")
    }
    func resetData()
    {
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: currLocation, span: span)
        mapView.setRegion(region, animated: true)
        currannotation.coordinate = currLocation
        currannotation.title = "Current location"
        mapView.addAnnotation(currannotation)
        mapView.showsUserLocation = false
    }
    @IBAction func saveAddress(sender : UIButton)
    {
        returnData()
        self.navigationController?.popViewController(animated: true)
    }
}
    
