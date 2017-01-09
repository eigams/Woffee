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
    private var keys: [String:AnyObject]?
    private var foursquareAPIKey: String? = {
        return keys?["FoursquareAPI"]
    }
    
    private init() {
        if let keysPath = NSBundle.mainBundle().pathForResource("configuration", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: keysPath) as? [String: AnyObject]
        }
    }
    
    var foursquareClientID: String {
        return foursquareAPIKey.map { return $0["ClientID"] as? String } ?? ""
    }
    
    var foursquareClientSecret: String {
        return foursquareAPIKey.map { return $0["ClientSecret"] as? String } ?? ""
    }
    
    var foursquareProtocol: String {
        return foursquareAPIKey.map { return $0["Protocol"] as? String } ?? ""
    }

    var foursquareHost: String {
        return foursquareAPIKey.map { return $0["Host"] as? String } ?? ""
    }

    var foursquarePath: String {
        return foursquareAPIKey.map { return $0["Path"] as? String } ?? ""
    }
}
