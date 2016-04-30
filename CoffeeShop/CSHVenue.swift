//
//  CSVenue.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 4/11/16.
//  Copyright © 2016 Stefan Burettea. All rights reserved.
//

import Foundation
import ObjectMapper

struct CSHPhoto: Mappable {
    var identifier: String!
    var createdAt: Int?
    var width: Float?
    var height: Float?
    var prefix: String?
    var suffix: String?
    var visibility: String?
    
    init?(_ map: Map){
        
    }
    
    mutating func mapping(map: Map) {
        identifier  <- map["identifier"]
        createdAt  <- map["createdAt"]
    }
}


struct CSHHours: Mappable {
    var status: String?
    var isOpen: Bool?
    
    init?(_ map: Map){
        
    }
    
    mutating func mapping(map: Map) {
        status  <- map["status"]
        isOpen  <- map["isOpen"]
    }
}

struct CSHPrice: Mappable {
    var message: String?
    var currency: String!
    var tier: Int?
    
    init?(_ map: Map){
        
    }
    
    mutating func mapping(map: Map) {
        message     <- map["message"]
        currency    <- map["currency"]
        tier        <- map["tier"]
    }
}


class CSHVenue: Mappable {

    var identifier: String!
    var name: String!
    var location: CSHLocation?
    var stats: CSHStats?
    var rating: Float?
    var ratingColor: String?
    var hours: CSHHours?
    var price: CSHPrice?
    var photo: String?
    
    var address: String {
        guard let location = self.location,
              let city = location.city,
              let postalCode = location.postalCode else { return "" }
        
        var result = ""
        if city.isEmpty == false {
            result = (result as NSString).stringByAppendingString(city)
        }
        
        if postalCode.isEmpty == false {
            if result.isEmpty == false && result.characters.last != "," {
                result = (result as NSString).stringByAppendingString(", ")
            }
            
            result = (result as NSString).stringByAppendingString(postalCode)
        }
        
        return result
    }
    
    required init?(_ map: Map){
        
    }
    
    func mapping(map: Map) {
        identifier  <- map["identifier"]
        name        <- map["name"]
        location    <- map["location"]
        stats       <- map["stats"]
    }
}
