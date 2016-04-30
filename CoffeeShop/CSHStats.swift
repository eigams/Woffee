//
//  Stats.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 4/11/16.
//  Copyright © 2016 Stefan Burettea. All rights reserved.
//

import Foundation
import ObjectMapper

struct CSHStats: Mappable {
    var checkins: Int?
    var tips: Int?
    var users: Int?

    init?(_ map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        checkins    <- map["checkins"]
        tips        <- map["tips"]
        users       <- map["users"]
    }
}