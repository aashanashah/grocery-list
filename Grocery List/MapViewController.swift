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

class MapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate  {
    @IBOutlet var mapView : MKMapView!
    @IBOutlet var search : UITextField!
    var currLocation:CLLocationCoordinate2D!
    let currannotation = MKPointAnnotation()
    var locationManager: CLLocationManager!
    var searchLoc = CLLocationCoordinate2D()
    var address : String!
    var coordinate : CLLocationCoordinate2D!
    var name : String!

    override func viewDidLoad() {
        self.title = "Choose your location"
        mapView.showsUserLocation = false
        self.locationManager = CLLocationManager()
        
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
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    @IBAction func goClick(sender: UIButton)
    {
        self.view.endEditing(true)
        mapView.showsUserLocation = true
        mapView.removeAnnotation(currannotation)
        if(search.text == "")
        {
            let alert = UIAlertController(title: "Alert", message: "Please enter valid name", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            mapView.delegate = self
            getMapBySource(mapView, address:search.text!, title: "Your location", subtitle: "Your location")
        }
    }
    func getMapBySource(_ locationMap:MKMapView?, address:String?, title: String?, subtitle: String?)
    {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address!, completionHandler: {(placemarks, error) -> Void in
            if let validPlacemark = placemarks?[0]{
                
                self.setSearch(LocCoordinate:(validPlacemark.location?.coordinate)!)
                if(self.searchLoc.latitude != 0.0 )
                {
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
        let searchPlacemark = MKPlacemark(coordinate: location, addressDictionary: nil)
        let searchAnnotation = MKPointAnnotation()
        searchAnnotation.title = "My Location"
        let span = MKCoordinateSpanMake(0.05, 0.05)
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
                self.address = (placeMark?.name!)! + ", " + (placeMark?.thoroughfare!)! + ", " + (placeMark?.locality!)! + ", " + (placeMark?.administrativeArea!)! + " " + (placeMark?.postalCode)! + ", " + (placeMark?.country!)!
                self.name = (placeMark?.name!)!
                self.checkAddress(address: self.address)
                
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
        self.navigationController?.popViewController(animated: true)
    }
    func resetData()
    {
        search.text = ""
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
}
