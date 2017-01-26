//
//  LocationManager.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 4/20/15.
//  Copyright (c) 2015 Stefan Burettea. All rights reserved.
//

import UIKit
import CoreLocation
import RxCocoa
import RxSwift


class CSLocationManager: NSObject {
    
    typealias CompletionBlock_t = (_ location: CLLocation?, _ error: NSError?) -> Void
    
    fileprivate let locationManager: CLLocationManager = CLLocationManager()
    fileprivate var completion:CompletionBlock_t?
    
    var locationDidUpdate: Observable<CLLocation?> {
        return Observable.create { observer in
            self.start { location, error in
                    if let error = error, error.code > 0 {
                        observer.on(.error(error))
                        return
                    }
        
                    observer.on(.next(location))
                    observer.on(.completed)
                }
    
            return Disposables.create()
        }
    }
    
    fileprivate func start(_ completion: CompletionBlock_t?) {
        locationManager.delegate = self
        self.completion = completion
    
        if locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
            locationManager.requestWhenInUseAuthorization()
        }
        else {
            locationManager.startUpdatingLocation()
        }
    }
    
    fileprivate func stop() {
        locationManager.stopUpdatingLocation()
    }
    
    override init() {
        super.init()
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            self.locationManager.distanceFilter = 100.0;
        }
    }
}

extension CSLocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        guard let location = locations.last else { return }
        
        completion?(location, nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        
        completion?(nil, error as NSError?)
    }
    
}
