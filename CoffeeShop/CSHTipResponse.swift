//
//  TipResponse.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 4/19/15.
//  Copyright (c) 2015 Stefan Burettea. All rights reserved.
//

import UIKit
import ObjectMapper

struct CSHTipResponse: Mappable {
    var id: String!
    var createdAt: CUnsignedLong?
    var text: String!
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        id          <- map["id"]
        createdAt   <- map["createdAt"]
        text        <- map["text"]
    }
}
