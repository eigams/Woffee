//
//  VenueAnnotation.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 5/3/15.
//  Copyright (c) 2015 Stefan Burettea. All rights reserved.
//

import Foundation
import MapKit
import AddressBook

class VenueAnnotation: NSObject, MKAnnotation {

    var title: String
    var subtitle: String
    var coordinate: CLLocationCoordinate2D
    
    init(name: String!, address: String!, coordinate: CLLocationCoordinate2D) {
        
        self.title = name
        self.subtitle = address
        self.coordinate = coordinate
        
        super.init()
    }    
}
