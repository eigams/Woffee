//
//  CSLocation.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 4/11/16.
//  Copyright © 2016 Stefan Burettea. All rights reserved.
//

import Foundation
import ObjectMapper

struct CSHLocation: Mappable {
    var address: String?
    var city: String?
    var country: String?
    var cc: String?
    var postalCode: String?
    var state: String?
    var distance: Int?
    var lat: Double?
    var lng: Double?
    
    init?(_ map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        address     <- map["address"]
        city        <- map["city"]
        country     <- map["country"]
        cc          <- map["cc"]
        postalCode  <- map["postalCode"]
        state       <- map["state"]
        distance    <- map["distance"]
        lat         <- map["lat"]
        lng         <- map["lng"]
    }
}