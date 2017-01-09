//
//  ShopsMapViewController.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 4/24/15.
//  Copyright (c) 2015 Stefan Burettea. All rights reserved.
//

import UIKit
import MapKit

class ShopsMapViewController: UIViewController {//, MKMapViewDelegate {

    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var pulsatingButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var annotations: [MKPointAnnotation]?
    var location: CLLocation?
    
    fileprivate let MetersPerMile = 1609.344
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        guard let coordinates = self.location?.coordinate,
                  let annotations = self.annotations,
                  let viewRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude), 4*MetersPerMile, 4*MetersPerMile) as MKCoordinateRegion? else { return }
            
        // 3
        mapView.setRegion(viewRegion, animated: true)
        mapView.addAnnotations(annotations)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
