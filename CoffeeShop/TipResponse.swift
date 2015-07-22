//
//  TipResponse.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 4/19/15.
//  Copyright (c) 2015 Stefan Burettea. All rights reserved.
//

import UIKit

class TipResponse: NSObject {
   
    let id: String!
    let createdAt: CUnsignedLong!
    let text: String!
    
    override init() {
        
        self.id = ""
        self.createdAt = 0
        self.text = ""
    }
    
    init(id: String, dateCreated: CUnsignedLong, text: String) {
        
        self.id = id
        self.createdAt = dateCreated
        self.text = text
    }
}
