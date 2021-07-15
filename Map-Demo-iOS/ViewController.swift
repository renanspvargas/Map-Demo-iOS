//
//  ViewController.swift
//  Map-Demo-iOS
//
//  Created by Renan Silveira Pimentel Vargas on 7/14/21.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
    }


}

