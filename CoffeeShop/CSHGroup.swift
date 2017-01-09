//
//  CSGroup.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 4/11/16.
//  Copyright © 2016 Stefan Burettea. All rights reserved.
//

import Foundation
import ObjectMapper

struct CSHGroup: Mappable {
    var type: String!
    var name: String?
    var items: [AnyObject]?
    
    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        type    <- map["type"]
        name    <- map["name"]
        items   <- map["items"]
    }
}
