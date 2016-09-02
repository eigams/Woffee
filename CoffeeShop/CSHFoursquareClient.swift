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
    let location: CLLocation?
    let radius: String?
    let queryParameter: String?
    let queryType: String
    let version: String
    let sortByDistance: String
    let limit: String
    let identifier: String?
    let isForPhotos: Bool
    
    init(location: CLLocation, radius: String, queryParameter: String, queryType: String = "query", version: String = "20150420", sortByDistance: String = "1", limit: String = "100") {
        self.location = location
        self.radius = radius
        self.queryParameter = queryParameter
        self.queryType = queryType
        self.version = version
        self.sortByDistance = sortByDistance
        self.limit = limit
        self.identifier = nil
        self.isForPhotos = false
    }
    
    init(identifier: String, forPhotos: Bool = false, version: String = "20150420", sortByDistance: String = "1", limit: String = "100", queryType: String = "query") {
        self.identifier = identifier ?? ""
        self.location = nil
        self.radius = nil
        self.queryParameter = nil
        self.queryType = queryType
        self.version = version
        self.sortByDistance = sortByDistance
        self.limit = limit
        self.isForPhotos = forPhotos
    }
    
    private func venueResources() -> [String: String] {
        return ["client_id": CSHConfiguration.sharedInstance.FoursquareClientID() ?? "",
                "client_secret": CSHConfiguration.sharedInstance.FoursquareClientSecret() ?? "",
                "v": self.version,
                "sort": "recent"]
    }
    
    private func venues() -> [String: String] {
        guard let location = self.location else { return [:] }
        let latitudeLongitude = String(format: "%.8f,%.8f", location.coordinate.latitude, location.coordinate.longitude)
        
        return ["ll": latitudeLongitude,
              "client_id": CSHConfiguration.sharedInstance.FoursquareClientID() ?? "",
              "client_secret": CSHConfiguration.sharedInstance.FoursquareClientSecret() ?? "",
              self.queryType: self.queryParameter ?? "",
              "v": self.version,
              "radius": self.radius ?? "2000",
              "sortByDistance": self.sortByDistance,
              "limit": self.limit]
    }
    
    func asString() -> String {
        
        let sink: [NSURLQueryItem]
        if self.location != nil {
           sink = venues().map{ NSURLQueryItem(name: $0.0, value: $0.1) }
        } else {
           sink = venueResources().map{ NSURLQueryItem(name: $0.0, value: $0.1) }
        }
        
        let components = NSURLComponents()
        components.queryItems = sink
        components.scheme = CSHConfiguration.sharedInstance.FoursquareProtocol()
        components.host = CSHConfiguration.sharedInstance.FoursquareHost() ?? ""
        components.path = self.location != nil ? CSHConfiguration.sharedInstance.FoursquarePath() ?? "" : "/v2/venues/\(self.identifier ?? "")/\(self.isForPhotos ? "photos": "tips")"
        
        return components.URLString ?? ""
    }
    
    static func requestForResourceType(identifier: String, resourceType: VenueResourceType) -> String? {
        switch resourceType {
            case .Tip :
                return CSHFourquareRequest(identifier: identifier).asString()
            case .Photo :
                return CSHFourquareRequest(identifier: identifier, forPhotos: true).asString()
        }
    }
}

private enum VenueResourceType {
    case Tip
    case Photo
}

final class CSHFoursquareClient {
    static let sharedInstance = CSHFoursquareClient()
    
    internal required init() {}
    
    private func sendRequestWithLocation(location: CLLocation, query: String, queryType: String, radius: String, completion: ([CSHVenue]?, NSError?) -> Void) {
        
        let request = CSHFourquareRequest(location: location, radius: radius, queryParameter: query)
        let path = request.asString()
        guard path != "" else { completion(nil, nil); return }
        
        Alamofire.request(.GET, path).responseObject{ (response: Response<CSHFoursquareResponse, NSError>) in
            guard let value = response.result.value,
                  let items = value.response?.items else {
                completion(nil, response.result.error)
                return
            }
                        
            let venues = items.flatMap{ return $0.venue }
            completion(venues, nil)
        }
    }
    
    func venuesAtLocation(location: CLLocation, query: String, radius: String, completion: (venues: [CSHVenue]?, error: NSError?) -> Void) {
        sendRequestWithLocation(location, query: query, queryType: "query", radius: radius, completion: completion)
    }
    
    func coffeeVenuesAtLocation(location: CLLocation, radius: String, completion: (venues: [CSHVenue]?, error: NSError?) -> Void) {
        sendRequestWithLocation(location, query: "coffee", queryType: "section", radius: radius, completion: completion)
    }
    
    func foodVenuesAtLocation(location: CLLocation, radius: String, completion: (venues: [CSHVenue]?, error: NSError?) -> Void) {
        sendRequestWithLocation(location, query: "food", queryType: "section", radius: radius, completion: completion)
    }
    
    func venuesAtLocation(location: CLLocation, queries: [String], radius: String, completion: ([CSHVenue]?, NSError?) -> Void) {
        let downloadGroup = dispatch_group_create()
        
        var sink:[[CSHVenue]] = []
        
        queries.forEach {
            dispatch_group_enter(downloadGroup)
            
            self.sendRequestWithLocation(location, query: $0, queryType: "query", radius: radius) { (venues, error) in
                defer { dispatch_group_leave(downloadGroup) }
                
                if let venues = venues {
                    sink.append(venues)
                }
            }
        }
        
        dispatch_group_notify(downloadGroup, dispatch_get_main_queue()) {
            guard sink.count > 0 else {
                completion(nil, nil)
                return
            }
            
            let joined = sink.reduce([],combine: {$0 + $1}).removeDuplicateVenues()
            
            completion(joined, nil)
        }
    }
    
    typealias CSHFoursquareVenueTipResponse = CSHFoursquareVenueResourceResponse<CSHFoursquareVenueTipResponseObject>
    func venueTipsWithIdentifier(identifier: String, completion: (tip: [String: [CSHVenueTip]]?, error: NSError?) -> Void) {
        
        guard let resourceRequest = CSHFourquareRequest.requestForResourceType(identifier, resourceType: .Tip) else { completion(tip: nil, error: nil); return }
        var result: [String: [CSHVenueTip]] = [:]
        
        Alamofire.request(.GET, resourceRequest).responseObject{ (response: Response<CSHFoursquareVenueTipResponse, NSError>) in
            
            guard let value = response.result.value,
                let items = value.response?.tips?.items where items.count > 0 else {
                    completion(tip: nil, error: response.result.error)
                    return
            }
            
            result[identifier] = items
            completion(tip: result, error: nil)
        }
    }

    typealias CSHFoursquareVenuePhotoResponse = CSHFoursquareVenueResourceResponse<CSHFoursquareVenuePhotoResponseObject>
    func venuePhotosWithIdentifier(identifier: String, completion: (photo: [String: [CSHVenuePhoto]]?, error: NSError?) -> Void) {
        
        guard let request = CSHFourquareRequest.requestForResourceType(identifier, resourceType: .Photo) else { completion(photo: nil, error: nil); return }
        var result: [String: [CSHVenuePhoto]] = [:]
        
        Alamofire.request(.GET, request).responseObject{ (response: Response<CSHFoursquareVenueResourceResponse<CSHFoursquareVenuePhotoResponseObject>, NSError>) in
            
            guard let value = response.result.value,
                let items = value.response?.photo?.items else {
                    completion(photo: nil, error: response.result.error)
                    return
            }
            
            result[identifier] = items.filter { $0.source?.name.rangeOfString("iOS") != nil }
            completion(photo: result, error: nil)
        }
    }
}