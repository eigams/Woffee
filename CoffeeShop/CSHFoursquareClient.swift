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
        self.identifier = identifier 
        self.location = nil
        self.radius = nil
        self.queryParameter = nil
        self.queryType = queryType
        self.version = version
        self.sortByDistance = sortByDistance
        self.limit = limit
        self.isForPhotos = forPhotos
    }
    
    fileprivate var venueResources: [String: String] {
        return ["client_id": CSHConfiguration.sharedInstance.foursquareClientID,
                "client_secret": CSHConfiguration.sharedInstance.foursquareClientSecret,
                "v": version,
                "sort": "recent"]
    }
    
    fileprivate var venues: [String: String] {
        guard let location = location else { return [:] }
        let latitudeLongitude = String(format: "%.8f,%.8f", location.coordinate.latitude, location.coordinate.longitude)
        
        return ["ll": latitudeLongitude,
              "client_id": CSHConfiguration.sharedInstance.foursquareClientID,
              "client_secret": CSHConfiguration.sharedInstance.foursquareClientSecret,
              queryType: queryParameter ?? "",
              "v": version,
              "radius": radius ?? "2000",
              "sortByDistance": sortByDistance,
              "limit": limit]
    }
    
    func asString() -> String {
        let sink: [URLQueryItem] = location.map { _ in venues.map{ URLQueryItem(name: $0.0, value: $0.1) } } ?? venueResources.map{ URLQueryItem(name: $0.0, value: $0.1) }
        
        var components = URLComponents()
        components.queryItems = sink
        components.scheme = CSHConfiguration.sharedInstance.foursquareProtocol
        components.host = CSHConfiguration.sharedInstance.foursquareHost
        components.path = location.map { _ in CSHConfiguration.sharedInstance.foursquarePath } ?? "/v2/venues/\(identifier ?? "")/\(isForPhotos ? "photos": "tips")"
        
        return components.string ?? ""
    }
    
    static func requestForResourceType(_ identifier: String, resourceType: VenueResourceType) -> String? {
        switch resourceType {
            case .tip :
                return CSHFourquareRequest(identifier: identifier).asString()
            case .photo :
                return CSHFourquareRequest(identifier: identifier, forPhotos: true).asString()
        }
    }
}

private enum VenueResourceType {
    case tip
    case photo
}

typealias CSHVenuesCompletionBlock = ([CSHVenue]?, Error?) -> Void

final class CSHFoursquareClient {
    static let sharedInstance = CSHFoursquareClient()
    
    internal required init() {}
    
    fileprivate func sendRequestWithLocation(_ location: CLLocation, query: String, queryType: String, radius: String, completion: @escaping CSHVenuesCompletionBlock) {
        
        let request = CSHFourquareRequest(location: location, radius: radius, queryParameter: query)
        let path = request.asString()
        guard path != "" else { completion(nil, nil); return }
        
        Alamofire.request(path).responseObject{ (response: DataResponse<CSHFoursquareResponse>) in
            guard let value = response.result.value,
                  let items = value.response?.items else {
                completion(nil, response.result.error)
                return
            }
                        
            let venues = items.flatMap{ return $0.venue }
            completion(venues, nil)
        }
    }
    
    func venues(location: CLLocation, query: String, radius: String, completion: @escaping CSHVenuesCompletionBlock) {
        sendRequestWithLocation(location, query: query, queryType: "query", radius: radius, completion: completion)
    }
    
    func coffeeVenuesAtLocation(_ location: CLLocation, radius: String, completion: @escaping CSHVenuesCompletionBlock) {
        sendRequestWithLocation(location, query: "coffee", queryType: "section", radius: radius, completion: completion)
    }
    
    func foodVenuesAtLocation(_ location: CLLocation, radius: String, completion: @escaping CSHVenuesCompletionBlock) {
        sendRequestWithLocation(location, query: "food", queryType: "section", radius: radius, completion: completion)
    }
    
    func venues(location: CLLocation, queries: [String], radius: String, completion: @escaping CSHVenuesCompletionBlock) {
        let downloadGroup = DispatchGroup()
        
        var sink:[[CSHVenue]] = []
        
        queries.forEach {
            downloadGroup.enter()
            
            self.sendRequestWithLocation(location, query: $0, queryType: "query", radius: radius) { (venues, error) in
                defer { downloadGroup.leave() }
                
                if let venues = venues {
                    sink.append(venues)
                }
            }
        }
        
        downloadGroup.notify(queue: DispatchQueue.main) {
            guard sink.count > 0 else {
                completion(nil, nil)
                return
            }
            
            let joined = sink.reduce([],{$0 + $1}).removeDuplicates()
            
            completion(joined, nil)
        }
    }
    
    typealias CSHFoursquareVenueTipsCompletion = (([String: [CSHVenueTip]]?, Error?) -> Void)
    typealias CSHFoursquareVenueTipResponse = CSHFoursquareVenueResourceResponse<CSHFoursquareVenueTipResponseObject>
    func venueTips(identifier: String, completion: @escaping CSHFoursquareVenueTipsCompletion) {
        
        guard let resourceRequest = CSHFourquareRequest.requestForResourceType(identifier, resourceType: .tip) else {
            completion(nil, nil)
            return
        }
        
        var result: [String: [CSHVenueTip]] = [:]
        
        Alamofire.request(resourceRequest).responseObject{ (response: DataResponse<CSHFoursquareVenueTipResponse>) in
            
            guard let value = response.result.value,
                  let items = value.response?.tips?.items, items.count > 0 else {
                    completion(nil, response.result.error)
                    return
            }
            
            result[identifier] = items
            completion(result, nil)
        }
    }

    typealias CSHFoursquareVenuePhotosCompletion = (([String: [CSHVenuePhoto]]?, Error?) -> Void)
    typealias CSHFoursquareVenuePhotoResponse = CSHFoursquareVenueResourceResponse<CSHFoursquareVenuePhotoResponseObject>
    func venuePhotos(identifier: String, completion: @escaping CSHFoursquareVenuePhotosCompletion) {
        
        guard let request = CSHFourquareRequest.requestForResourceType(identifier, resourceType: .photo) else { completion(nil, nil); return }
        var result: [String: [CSHVenuePhoto]] = [:]
        
        Alamofire.request(request).responseObject{ (response: DataResponse<CSHFoursquareVenueResourceResponse<CSHFoursquareVenuePhotoResponseObject>>) in
            
            guard let value = response.result.value,
                  let items = value.response?.photo?.items else {
                    completion(nil, response.result.error)
                    return
            }
            
            result[identifier] = items.filter { $0.source?.name.range(of: "iOS") != nil }
            completion(result, nil)
        }
    }
}
