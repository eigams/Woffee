//
//  CSGroupItems.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 4/11/16.
//  Copyright © 2016 Stefan Burettea. All rights reserved.
//

import Foundation
import ObjectMapper

struct CSGroupItems: Mappable {
    var venue: CSHVenue?
    var tips: [String]?
    var referralId: String?
    var reasons: [String: AnyObject]?
    
    init?(_ map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        venue       <- map["venue"]
        tips        <- map["tips"]
        referralId  <- map["referralId"]
        reasons     <- map["reasons"]
    }
}