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
    
    @IBAction func actionButtonTapped(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        let METERS_PER_MILE = 1609.344
        
        // 2
        var viewRegion: MKCoordinateRegion?
        if let coordinates = self.location?.coordinate {
            
            viewRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude), 4*METERS_PER_MILE, 4*METERS_PER_MILE)
            
            // 3
            self.mapView.setRegion(viewRegion!, animated: true)
                        
            self.mapView.addAnnotations(self.annotations)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
