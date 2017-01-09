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
    var photourl: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        identifier  <- map["id"]
        createdAt   <- map["createdAt"]
        text        <- map["text"]
        photourl    <- map["photourl"]
    }
    
    func isWIFI() -> Bool {
        guard let venueTip = self.text else { return false }
        
        let containsWifi = venueTip.range(of: "wifi") != nil
        let hasWifi = venueTip.range(of: "no wifi") == nil && venueTip.range(of: "no free wifi") == nil &&
            venueTip.range(of: "no wi-fi") == nil && venueTip.range(of: "no free wi-fi") == nil
        
        return containsWifi && hasWifi
    }
}

struct CSHFoursquareVenueResourceResponse<T>: Mappable where T:Mappable {
    var meta: CSHFoursquareResponseMeta?
    var response: T?
    
    init?(map: Map){
        
    }
    
    mutating func mapping(map: Map) {
        meta     <- map["meta"]
        response <- map["response"]
    }
}

struct CSHFoursquareVenueTipResponseObject: Mappable {
    var tips: CSHFoursquareVenueResourceData<CSHVenueTip>?
    
    init?(map: Map){ }
    
    mutating func mapping(map: Map) {
        tips <- map["tips"]
    }
}

struct CSHFoursquareVenueTipData: Mappable {
    var count: Int?
    var items: [CSHVenueTip]?
    
    init?(map: Map){
        
    }
    
    mutating func mapping(map: Map) {
        count <- map["count"]
        items <- map["items"]
    }
}

struct CSHFoursquareVenueResourceData<T>: Mappable where T:Mappable {
    var count: Int?
    var items: [T]?
    
    init?(map: Map){
        
    }
    
    mutating func mapping(map: Map) {
        count <- map["count"]
        items <- map["items"]
    }
}

struct CSHFoursquareVenuePhotoResponseObject: Mappable {
    var photo: CSHFoursquareVenueResourceData<CSHVenuePhoto>?
    
    init?(map: Map){ }
    
    mutating func mapping(map: Map) {
        photo <- map["photos"]
    }
}
