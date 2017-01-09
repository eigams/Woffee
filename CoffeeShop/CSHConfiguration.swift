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
    fileprivate var keys: [String:Any] = [:]
    fileprivate var foursquareAPIKey: [String:String]? {
        get {
            return self.keys["FoursquareAPI"] as? [String:String]
        }
    }
    
    fileprivate init() {
        if let keysPath = Bundle.main.path(forResource: "configuration", ofType: "plist") {
            keys = (NSDictionary(contentsOfFile: keysPath) as? [String: AnyObject])!
        }
    }
    
    var foursquareClientID: String {
        return foursquareAPIKey?["ClientID"] ?? ""
    }
    
    var foursquareClientSecret: String {
        return foursquareAPIKey?["ClientSecret"] ?? ""
    }
    
    var foursquareProtocol: String {
        return foursquareAPIKey?["Protocol"] ?? ""
    }

    var foursquareHost: String {
        return foursquareAPIKey?["Host"] ?? ""
    }

    var foursquarePath: String {
        return foursquareAPIKey?["Path"] ?? ""
    }
}
