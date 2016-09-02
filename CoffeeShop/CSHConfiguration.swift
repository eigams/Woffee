//
//  CSHConfiguration.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 8/6/16.
//  Copyright © 2016 Stefan Burettea. All rights reserved.
//

import Foundation

final class CSHConfiguration {
    static let sharedInstance = CSHConfiguration()
    private var keys: [String:AnyObject]!
    
    private init() {
        if let keysPath = NSBundle.mainBundle().pathForResource("configuration", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: keysPath) as? [String: AnyObject]
        }
    }
    
    func FoursquareClientID() -> String? {
        return self.keys["FoursquareAPI"]?["ClientID"] as? String
    }
    
    func FoursquareClientSecret() -> String? {
        return self.keys["FoursquareAPI"]?["ClientSecret"] as? String
    }
    
    func FoursquareProtocol() -> String {
        return (self.keys["FoursquareAPI"]?["Protocol"] as? String) ?? "http"
    }

    func FoursquareHost() -> String? {
        return self.keys["FoursquareAPI"]?["Host"] as? String
    }

    func FoursquarePath() -> String? {
        return self.keys["FoursquareAPI"]?["Path"] as? String
    }
}
