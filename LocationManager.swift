//
//  LocationManager.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 4/20/15.
//  Copyright (c) 2015 Stefan Burettea. All rights reserved.
//

import UIKit
import CoreLocation

class CSLocationManager: NSObject, CLLocationManagerDelegate {
    
    typealias CompletionBlock_t = (location: CLLocation?, error: NSError?) -> Void
    
    private let locationManager: CLLocationManager!
    private var completion:CompletionBlock_t?
    
    func start(completion: CompletionBlock_t) {
        
        self.locationManager.delegate = self
        self.completion = completion
        
        if self.locationManager.respondsToSelector("requestWhenInUseAuthorization") {
            self.locationManager.requestWhenInUseAuthorization()
        }
        else {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func stop() {
        self.locationManager.stopUpdatingLocation()
    }
    
    override init() {
        
        self.locationManager = CLLocationManager()
        
        super.init()
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            self.locationManager.distanceFilter = 100.0;
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        let location: CLLocation = locations.last as! CLLocation
        
        self.completion!(location: location, error: nil)
        
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        self.completion!(location: CLLocation(), error: error)
        
        self.locationManager.stopUpdatingLocation()
    }
    
}
