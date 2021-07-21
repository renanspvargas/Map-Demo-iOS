//
//  ViewController.swift
//  Map-Demo-iOS
//
//  Created by Renan Silveira Pimentel Vargas on 7/14/21.
//

import UIKit
import MapKit // map
import CoreLocation // user location

class ViewController: UIViewController {
    //App constructipn order
    //  Indicate the necessity and type of the location in info.plis, request user auhorization, look for authorization changes
    //  Get user location
    //  Centralize and zoom map based on user location
    //  Start traking user location updates to ajust map centralization
    
    //  Look for a location using a string (geocode)
    //  Request route to apple
    //  Draw route on screen

    let regionInMeters: Double = 1000
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchAdressField: UITextField!
    @IBOutlet weak var getDirectionsButton: UIButton!
    @IBOutlet weak var adressLabel: UILabel!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        
        checkLocationServices()
    }
    
    @IBAction func getDirectionsButtonTapped(_ sender: Any) {
        getAdress()
        view.endEditing(true)
    }
    
    func getAdress() { //get adress by the name on textfield
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(searchAdressField.text!) { (placemarks, error) in
            guard let placemarks = placemarks, let location = placemarks.first?.location else {
                print("No location found")
                return
            }
            
            self.createRoute(destinationCordinates: location.coordinate)
            self.pinOriginAndDestination(destinationCordinates: location.coordinate)
        }
    }
    
    func pinOriginAndDestination(destinationCordinates: CLLocationCoordinate2D) {
        let location  = locationManager.location?.coordinate
        let pinOrigin = MKPointAnnotation()
        pinOrigin.coordinate = location!
        mapView.addAnnotation(pinOrigin)
        
        let pinDestination = MKPointAnnotation()
        pinDestination.coordinate = destinationCordinates
        mapView.addAnnotation(pinDestination)
    }
    
    func createRoute(destinationCordinates: CLLocationCoordinate2D) {
        let userLocation  = locationManager.location?.coordinate
        
        let userLocationPlaceMark = MKPlacemark(coordinate: userLocation!)
        let destinationCordinatesPlaceMark = MKPlacemark(coordinate: destinationCordinates)
        
        let userMapItem = MKMapItem(placemark: userLocationPlaceMark) //map item armazena mais informaoes alem das coordenadas
        let destinationMapItem = MKMapItem(placemark: destinationCordinatesPlaceMark)
        
        let directionsRequest = MKDirections.Request() // request para apple
        directionsRequest.source = userMapItem //origem
        directionsRequest.destination = destinationMapItem //destino
        directionsRequest.transportType = .automobile //meio de transporte
        directionsRequest.requestsAlternateRoutes = true //pedir multiplas rotas
        
        let directions = MKDirections(request: directionsRequest)
        directions.calculate { response, error in
            guard let response = response else {
                if let error = error {
                    print("im broke")
                }
                return
            }
            let routes = response.routes[0] // look at the delegate now
            self.mapView.addOverlay(routes.polyline)
            self.mapView.setVisibleMapRect(routes.polyline.boundingMapRect, animated: true)
        }
        
        
        
    }
    
    func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //battery
//        locationManager.activityType = CLActivityType.fitness
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
            
        //delegate with function notifying changes
        
            locationManager.requestWhenInUseAuthorization()
            setupLocationManager()
            showUserLocationIcon()
            centerViewUserLocation()
            locationManager.startUpdatingLocation() // update didUpdateLocations list
        } else {
            //alert informing the user to turn location on
            print("turn the iphone config location to on")
            return
        }
    }

    func getCenterLocation(_ mapView: MKMapView) -> CLLocation {
        let lat = mapView.centerCoordinate.latitude
        let long = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: lat, longitude: long)
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

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .blue
        return render
    }
    
}
