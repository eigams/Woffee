//
//  CSVenueTip.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 4/11/16.
//  Copyright © 2016 Stefan Burettea. All rights reserved.
//

import Foundation
import ObjectMapper

struct CSHVenueTip: Mappable {
    var identifier: String?
    var createdAt: UInt?
    var text: String?
    
    init?(_ map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        identifier  <- map["identifier"]
        createdAt   <- map["createdAt"]
        text        <- map["texttext"]
    }
}

struct Temperature: Mappable {
    var celsius: Double?
    var fahrenheit: Double?
    
    init?(_ map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        celsius     <- map["celsius"]
        fahrenheit  <- map["fahrenheit"]
    }
}