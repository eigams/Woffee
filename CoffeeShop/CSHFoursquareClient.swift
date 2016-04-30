//
//  CSHFoursquareClient.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 4/24/16.
//  Copyright © 2016 Stefan Burettea. All rights reserved.
//

import Foundation
import MapKit

private struct CSHFourquareRequest {
    
    private static let ClientId = "ZZCLOTJ2RO5TY5LVDUVVUOWW41VN2PGQXHEL1IR3U14XEZTC";
    private static let ClientSecret = "Q3OCB5OC0V30JXVLCIBZRGMGJOFRWE2QXDRKKVTKIQSYF43N";
    
    let location: CLLocation?
    let radius: String?
    let queryParameter: String?
    
    init(location: CLLocation, radius: String, queryParameter: String) {
        self.location = location
        self.radius = radius
        self.queryParameter = queryParameter
    }
    
    func asDictionary() -> [String: String]? {
        guard let location = self.location,
              let radius = self.radius,
              let queryParameter = self.queryParameter else {return nil}
        
        let latitudeLongitude = String(format: "%.8f,%.8f", location.coordinate.latitude, location.coordinate.longitude)
        
        let result = ["ll": latitudeLongitude,
                      "client_id": self.dynamicType.ClientId,
                      "client_secret": self.dynamicType.ClientSecret,
                      "query": queryParameter,
                      "v": "20150420",
                      "radius": radius,
                      "sortByDistance": "1",
                      "limit": "100"]
        
        return result
    }
}

class CSHFoursquareClient {
    
    required init() {
        
    }
    
    private func getVenuesAtLocation(location: CLLocation, radius: String, completion: ([CSHVenue]?, NSError?) -> Void) {
        
    }
}