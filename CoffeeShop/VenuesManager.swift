//
//  VenuesManager.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 4/20/15.
//  Copyright (c) 2015 Stefan Burettea. All rights reserved.
//

import UIKit
import CoreLocation
import RxCocoa
import RxSwift


extension Array where Element: Hashable {
    var unique: [Element] {
        return Array(Set(self))
    }
}

// 1. get all venues of a certain type
// 2. check for duplicates with the main pool of venues
// 3. get all tips for non duplicate venues
// 4. check for venues whose tips contain keywords like "free wifi" etc
// 5. call "didFindWirelessVenue" for wifi tagged venues
// 6. get the venues public photos webpath

class CSHVenuesManager: NSObject {
    fileprivate struct Constants {
        static let standardLookupRadius = "2500"
        static let defaultWifiEnabledVenueNames = ["starbucks", "caffe nero", "pizza express", "harris + hoole"]
    }
    
    fileprivate let location: CLLocation!
    
    fileprivate let disposeBag = DisposeBag()
    
    override init() {
        self.location = CLLocation()
        
        super.init()
    }
    
    init(location: CLLocation) {
        self.location = location
        
        super.init()
    }
    
    var startLookingForVenues: Observable<Void> {
        return Observable.create { observer in
            observer.on(.next())
            observer.on(.completed)
            
            return Disposables.create()
        }
    }
    
    func lookForVenuesWithWIFI() -> Observable<[CSHVenue]> {
        
        let defaultWirelessVenues = CSHFoursquareClient.sharedInstance.venues(at: location, queries: Constants.defaultWifiEnabledVenueNames, radius: Constants.standardLookupRadius)
        let coffeeWirelessVenues = CSHFoursquareClient.sharedInstance.coffeeVenues(at: location, radius: Constants.standardLookupRadius)
        let foodWirelessVenues = CSHFoursquareClient.sharedInstance.foodVenues(at: location, radius: Constants.standardLookupRadius)

        let venues = Observable.combineLatest(coffeeWirelessVenues, foodWirelessVenues, resultSelector: {$0 + $1})
        return venues
                .observeOn(MainScheduler.instance)
                .flatMapLatest { venues -> Observable<[CSHVenue: [CSHVenueTip]]> in
                    return Observable
                                .from(venues.removeDuplicates().map{ CSHFoursquareClient.sharedInstance.venueTips(for: $0) })
                                .merge()
                                .filter { (tip: [CSHVenue : [CSHVenueTip]]) -> Bool in
                                    tip.values.first?.index(where: { $0.isWIFI() }) != nil
                                }
                }
                .flatMapLatest { venueTips -> Observable<[CSHVenue]> in
                    let venues = venueTips.flatMap({ (tip: (key: CSHVenue, value: [CSHVenueTip])) -> CSHVenue in
                        return tip.key
                    })
                    
                    return Observable.combineLatest(defaultWirelessVenues, Observable.from(venues), resultSelector: {$0 + $1})
                }
    }
    
    func lookForPhotos(of venues: [CSHVenue]) -> Observable<[CSHVenue]> {
        let result = venues.flatMap ({
                        CSHFoursquareClient.sharedInstance.venuePhotos(for: $0).flatMap { photo -> Observable<CSHVenue> in
                            guard let identifier = photo.keys.first,
                                let url = photo.values.first else { return Observable.empty() }
                        venues.updateVenue(identifier, withPhotoURL: url)
                        if let venue = venues.venue(for: identifier) {
                            return Observable.just(venue)
                        }
                            
                        return Observable.empty()
                    }
                })
        
        return Observable.from(result).merge().toArray()
    }
}
