//
//  CSHVenuePhoto.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 8/29/16.
//  Copyright © 2016 Stefan Burettea. All rights reserved.
//

import Foundation
import ObjectMapper

struct CSHVenuePhotoSource: Mappable {
    var name: String!
    var url: String!
    
    init?(_ map: Map){
        
    }
    
    mutating func mapping(map: Map) {
        name <- map["name"]
        url  <- map["url"]
    }
}

struct CSHVenuePhoto: Mappable {
    var identifier: String!
    var createdAt: Int?
    var width: Int?
    var height: Int?
    var prefix: String?
    var suffix: String?
    var visibility: String?
    var source: CSHVenuePhotoSource?
    
    var url: String {
        get {
            guard let prefix = self.prefix,
                let width = self.width,
                let height = self.height,
                let suffix = self.suffix else {
                    return ""
            }
            
            return "\(prefix)\(width)x\(height)\(suffix)"
        }
    }
    
    init?(_ map: Map){
        
    }
    
    mutating func mapping(map: Map) {
        identifier <- map["id"]
        createdAt  <- map["createdAt"]
        width      <- map["width"]
        height     <- map["height"]
        prefix     <- map["prefix"]
        suffix     <- map["suffix"]
        source     <- map["source"]
    }
}
