//
//  ViewController.swift
//  Map-Demo-iOS
//
//  Created by Renan Silveira Pimentel Vargas on 7/14/21.
//

import UIKit
import MapKit // map
import CoreLocation // user location

class ViewController: UIViewController, MKMapViewDelegate {
    //App constructipn order
    //  Indicate the necessity and type of the location in info.plis, request user auhorization, look for authorization changes
    //  Get user location
    //  Centralize and zoom map based on user location
    //  Start traking user location updates to ajust map centralization

    let regionInMeters: Double = 1000
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        
        checkLocationServices()
    }

    func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //battery
    }
    
    func centerViewUserLocation() {
        if let location  = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func showUserLocationIcon() {
        mapView.showsUserLocation = true //you can enable via storyboard attributes inspector
        
//        if let location  = locationManager.location?.coordinate {
//            let pin = MKPointAnnotation()
//            pin.coordinate = location
//            mapView.addAnnotation(pin)
//        }
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() { // verify if user disabled location via phone settings
            
        // you can obtain user location authorization status with
        // CLAuthorizationStatus and treat every case in a switch
        
        //restricted = Restricted to decide (ex parental control)
        //notDetermined = User has not made a choice yet
        //denied = User refuses to allow location. If denied once you cant ask again, user have to modify it manually on settings
        //authorizedWhenInUse = Works when app is open
        //authorizedAlways = Works when in backgroud
        
            locationManager.requestWhenInUseAuthorization()
            setupLocationManager()
            showUserLocationIcon()
            centerViewUserLocation()
            locationManager.startUpdatingLocation() // update didUpdateLocations list
        } else {
            //alert informing the user to turn location on
            print("turn on location")
            return
        }
    }

}

extension ViewController: CLLocationManagerDelegate {
    
    //update map center as user moves
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    //notify location authorization changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationServices()
    }
}
