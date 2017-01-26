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
import RxCocoa
import RxSwift


private struct CSHFoursquareRequest {
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
        let sink: [URLQueryItem] = location.map { _ in
            venues.map{ URLQueryItem(name: $0.0, value: $0.1) } } ?? venueResources.map{ URLQueryItem(name: $0.0, value: $0.1)
        }
        
        var components = URLComponents()
        components.queryItems = sink
        components.scheme = CSHConfiguration.sharedInstance.foursquareProtocol
        components.host = CSHConfiguration.sharedInstance.foursquareHost
        components.path = location.map { _ in CSHConfiguration.sharedInstance.foursquarePath } ?? "/v2/venues/\(identifier ?? "")/\(isForPhotos ? "photos": "tips")"
        
        return components.string ?? ""
    }
}

private enum CSHVenueResourceType {
    case tip(String)
    case photo(String)
    
    var request: String? {
        switch self {
            case .tip(let identifier):
                return CSHFoursquareRequest(identifier: identifier).asString()
            case .photo(let identifier):
                return CSHFoursquareRequest(identifier: identifier, forPhotos: true).asString()
        }
    }
}

typealias CSHVenuesCompletionBlock = ([CSHVenue]?, Error?) -> Void

final class CSHFoursquareClient {
    static let sharedInstance = CSHFoursquareClient()
    
    internal required init() {}
    
    fileprivate func venues(at location: CLLocation, query: String, queryType: String, radius: String) -> Observable<[CSHVenue]> {
        return Observable.create { observer in
            let request = CSHFoursquareRequest(location: location, radius: radius, queryParameter: query)
            let path = request.asString()
            
            let requestRef = Alamofire.request(path).responseObject{ (response: DataResponse<CSHFoursquareResponse>) in
                if let value = response.result.value,
                   let items = value.response?.items {
                    
                    observer.on(.next(items.flatMap{ $0.venue }))
                    observer.on(.completed)
                } else if let error = response.result.error {
                    observer.onError(error)
                }
            }
            
            return Disposables.create(with: { requestRef.cancel() })
        }
    }
        
    func coffeeVenues(at location: CLLocation, radius: String) -> Observable<[CSHVenue]> {
        return venues(at: location, query: "coffee", queryType: "section", radius: radius)
    }

    func foodVenues(at location: CLLocation, radius: String) -> Observable<[CSHVenue]> {
        return venues(at: location, query: "food", queryType: "section", radius: radius)
    }
    
    fileprivate let disposeBag = DisposeBag()
    func venues(at location: CLLocation, queries: [String], radius: String) -> Observable<[CSHVenue]> {
        return Observable
                .from(queries.map {
                        self.venues(at: location, query: $0, queryType: "query", radius: radius)
                })
                .merge()
                .reduce([CSHVenue](), accumulator: {
                    var sink = $0
                    sink.append(contentsOf: $1)
                    return sink
                })
    }
    
    typealias CSHFoursquareVenueTipsCompletion = (([String: [CSHVenueTip]]?, Error?) -> Void)
    typealias CSHFoursquareVenueTipResponse = CSHFoursquareVenueResourceResponse<CSHFoursquareVenueTipResponseObject>
    func venueTips(for venue: CSHVenue) -> Observable<[CSHVenue: [CSHVenueTip]]> {
        guard let resourceRequest = CSHVenueResourceType.tip(venue.identifier).request else { return Observable.just([:]) }
        
        return Observable.create{ observer in
            let requestRef = Alamofire.request(resourceRequest).responseObject{ (response: DataResponse<CSHFoursquareVenueTipResponse>) in
                if let value = response.result.value,
                   let items = value.response?.tips?.items {
                    
                    observer.on(.next([venue: items]))
                    observer.on(.completed)
                } else if let error = response.result.error {
                    observer.onError(error)
                }
            }
            
            return Disposables.create(with: { requestRef.cancel() })
        }
    }
    
    typealias CSHFoursquareVenuePhotosCompletion = (([String: [CSHVenuePhoto]]?, Error?) -> Void)
    typealias CSHFoursquareVenuePhotoResponse = CSHFoursquareVenueResourceResponse<CSHFoursquareVenuePhotoResponseObject>
    func venuePhotos(for venue: CSHVenue) -> Observable<[String: String]> {
        guard let request = CSHVenueResourceType.photo(venue.identifier).request else { return Observable.just([:]) }
        
        return Observable.create{ observer in
            let requestRef = Alamofire.request(request).responseObject{ (response: DataResponse<CSHFoursquareVenueResourceResponse<CSHFoursquareVenuePhotoResponseObject>>) in
                if let value = response.result.value,
                    let items = value.response?.photo?.items {
                    
                    if let photo = items.index (where: { $0.source?.name.range(of: "iOS") != nil }).map ({ items[$0] }) {
                        observer.on(.next([venue.identifier: photo.url]))
                    }
                    observer.on(.completed)
                } else if let error = response.result.error {
                    observer.onError(error)
                }
            }
            
            return Disposables.create(with: { requestRef.cancel() })
        }        
    }
}
