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
    
    fileprivate let locationManager: CLLocationManager
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
        self.locationManager.delegate = self
        self.completion = completion
    
        if self.locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
            self.locationManager.requestWhenInUseAuthorization()
        }
        else {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    fileprivate func stop() {
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
}

extension CSLocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
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
        locationManager.stopUpdatingLocation()
        guard let completion = self.completion else { return }
        
        completion(nil, error as NSError?)
    }
    
}
