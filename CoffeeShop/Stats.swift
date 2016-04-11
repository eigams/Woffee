//
//  Stats.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 4/11/16.
//  Copyright © 2016 Stefan Burettea. All rights reserved.
//

import Foundation

struct Stats {

    let checkins: Int
    let tips: Int
    let users: Int
    
    init(checkins: Int, tips: Int, users: Int) {
        self.checkins = checkins
        self.tips = tips
        self.users = users
    }
}