//
//  CSVenue.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 4/11/16.
//  Copyright © 2016 Stefan Burettea. All rights reserved.
//

import Foundation
import ObjectMapper

struct CSHHours: Mappable {
    var status: String?
    var isOpen: Bool?
    
    init?(map: Map){
        
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
    
    init?(map: Map){
        
    }
    
    mutating func mapping(map: Map) {
        message     <- map["message"]
        currency    <- map["currency"]
        tier        <- map["tier"]
    }
}

struct CSHFoursquareResponse: Mappable {
    var meta: CSHFoursquareResponseMeta?
    var response: CSHFoursquareResponseObject?
    
    init?(map: Map){
        
    }
    
    mutating func mapping(map: Map) {
        meta     <- map["meta"]
        response    <- map["response"]
    }
}

struct CSHFoursquareResponseMeta: Mappable {
    var code: Int?
    var requestId: String?
    
    init?(map: Map){
        
    }
    
    mutating func mapping(map: Map) {
        code        <- map["code"]
        requestId   <- map["requestId"]
    }
}

struct CSHFoursquareResponseObject: Mappable {
    var query: String?
    var totalResults: Int?
    var items: [CSHFoursquareResponseObjectGroupItem]?
    
    init?(map: Map){
        
    }
    
    mutating func mapping(map: Map) {
        query        <- map["query"]
        totalResults <- map["totalResults"]
        items        <- map["groups.0.items"]
    }
}

struct CSHFoursquareResponseObjectGroupItem: Mappable {
    var venue: CSHVenue?
    var referralId: String?
    
    init?(map: Map){
        
    }
    
    mutating func mapping(map: Map) {
        venue        <- map["venue"]
        referralId   <- map["referralId"]
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
            result = (result as NSString).appending(city)
        }
        
        if postalCode.isEmpty == false {
            if result.isEmpty == false && result.characters.last != "," {
                result = (result as NSString).appending(", ")
            }
            
            result = (result as NSString).appending(postalCode)
        }
        
        var sink:[String] = []
        if city.isEmpty == false { sink.append(city) }
        if postalCode.isEmpty == false { sink.append(postalCode) }
        
        if sink.count > 1 { return sink.joined(separator: ", ") }
        if sink.count > 0 { return sink[0] }
        
        return ""
    }
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        identifier  <- map["id"]
        name        <- map["name"]
        location    <- map["location"]
        stats       <- map["stats"]
        rating      <- map["rating"]
        ratingColor <- map["ratingColor"]
        hours       <- map["hours"]
        price       <- map["price"]
    }
}

extension CSHVenue: Hashable {
    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    public var hashValue: Int {
        return identifier.characters.flatMap{Int(String($0))}.reduce(0, +)
    }

    public static func ==(_ lhs: CSHVenue, _ rhs: CSHVenue) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
