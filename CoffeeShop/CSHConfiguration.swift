//
//  CSHConfiguration.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 8/6/16.
//  Copyright © 2016 Stefan Burettea. All rights reserved.
//

import Foundation

struct CSHConfiguration {
    static let sharedInstance = CSHConfiguration()
    private var keys: [String:AnyObject]!
    
    private init() {
        if let keysPath = NSBundle.mainBundle().pathForResource("configuration", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: keysPath) as? [String: AnyObject]
        }
    }
    
    var foursquareClientID: String {
        return keys["FoursquareAPI"]?["ClientID"] as? String ?? ""
    }
    
    var foursquareClientSecret: String {
        return keys["FoursquareAPI"]?["ClientSecret"] as? String ?? ""
    }
    
    var foursquareProtocol: String {
        return (keys["FoursquareAPI"]?["Protocol"] as? String) ?? "http"
    }

    var foursquareHost: String {
        return keys["FoursquareAPI"]?["Host"] as? String ?? ""
    }

    var foursquarePath: String {
        return keys["FoursquareAPI"]?["Path"] as? String ?? ""
    }
}
