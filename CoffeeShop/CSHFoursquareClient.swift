//
//  CSHFoursquareClient.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 4/24/16.
//  Copyright © 2016 Stefan Burettea. All rights reserved.
//

import Foundation
import MapKit
import Alamofire
import AlamofireObjectMapper


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
    
    private func asDictionary() -> [String: String] {
        guard let location = self.location,
              let radius = self.radius,
              let queryParameter = self.queryParameter else {return [:]}
        
        let latitudeLongitude = String(format: "%.8f,%.8f", location.coordinate.latitude, location.coordinate.longitude)
        
        return ["ll": latitudeLongitude,
                      "client_id": self.dynamicType.ClientId,
                      "client_secret": self.dynamicType.ClientSecret,
                      "query": queryParameter,
                      "v": "20150420",
                      "radius": radius,
                      "sortByDistance": "1",
                      "limit": "100"]
    }
    
    func asString() -> String? {
        
        let sink = asDictionary().map{ NSURLQueryItem(name: $0.0, value: $0.1) }
        
        let components = NSURLComponents()
        components.queryItems = sink
        components.scheme = "https"
        components.host = "api.foursquare.com"
        components.path = "/v2/venues/explore"
        
        return components.URLString
    }
}

class CSHFoursquareClient {
    
    required init() {
        
    }
    
    private func sendRequestWithLocation(location: CLLocation, query: String, radius: String, completion: ([CSHVenue]?, NSError?) -> Void) {
        
        let request = CSHFourquareRequest(location: location, radius: radius, queryParameter: query)
        let path = request.asString()
        
        Alamofire.request(.GET, path!).responseObject{ (response: Response<CSHFoursquareResponse, NSError>) in
            guard let value = response.result.value,
                  let items = value.response?.items else {
                completion(nil, response.result.error)
                return
            }
                        
            let venues = items.flatMap{ return $0.venue }
            completion(venues, nil)
        }
    }
    
    func getVenuesAtLocation(location: CLLocation, radius: String, completion: ([CSHVenue]?, NSError?) -> Void) {
        sendRequestWithLocation(location, query: "wifi", radius: radius, completion: completion)
    }
}