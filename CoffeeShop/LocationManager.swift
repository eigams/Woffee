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
    
    typealias CompletionBlock_t = (_ location: CLLocation?, _ error: NSError?) -> Void
    
    fileprivate let locationManager: CLLocationManager
    fileprivate var completion:CompletionBlock_t?
    
    func start(_ completion: CompletionBlock_t?) {
        
        self.locationManager.delegate = self
        self.completion = completion
        
        if self.locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        guard let completion = self.completion,
              let location = locations.last else { return }
        
        completion(location, nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locationManager.stopUpdatingLocation()
        guard let completion = self.completion else { return }
        
        completion(nil, error as NSError?)
    }
    
}
