//
//  VenuesManager.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 4/20/15.
//  Copyright (c) 2015 Stefan Burettea. All rights reserved.
//

import UIKit
import CoreLocation

extension Array where Element: Hashable {
    var unique: [Element] {
        return Array(Set(self))
    }
}

protocol VenuesManagerDelegate {
    
    func didFindWirelessVenue(venue: CSHVenue?)
    func didFindPhotoForWirelessVenue(venue: CSHVenue)
    func didFailToFindVenueWithError(error: NSError!)
    func didStartLookingForVenues()
    func didFinishLookingForVenues()
}

// 1. get all venues of a certain type
// 2. check for duplicates with the main pool of venues
// 3. get all tips for non duplicate venues
// 4. check for venues whose tips contain keywords like "free wifi" etc
// 5. call "didFindWirelessVenue" for wifi tagged venues
// 6. get the venues public photos webpath

class VenuesManager: NSObject {

    private let queue: dispatch_queue_t;
    private var venues = [CSHVenue]()
    private var defaultWifiEnabledVenues = [CSHVenue]()
    
    private let location: CLLocation!
    private lazy var downloadGroup: dispatch_group_t = {
        return dispatch_group_create()
    }()
    
    var delegate: VenuesManagerDelegate?
    
    private let defaultWifiEnabledVenueNames = ["starbucks", "caffe nero", "pizza express", "harris + hoole"]
    
    override init() {
        self.location = CLLocation()
        self.queue = dispatch_queue_create("com.coffeshop.cachevenues", DISPATCH_QUEUE_CONCURRENT);
        
        super.init()
    }
    
    init(location: CLLocation) {
        self.location = location
        self.queue = dispatch_queue_create("com.coffeshop.cachevenues", DISPATCH_QUEUE_CONCURRENT);
        
        super.init()
    }
    
    private func lookForDefaultWirelessEnabledVenues() {
        let defaultWifiEnabledVenueNames = ["starbucks", "pizza express", "harris + hoole"]
        
        let defaultEnabledWirelessVenuesDownloadGroup = dispatch_group_create()
        dispatch_group_enter(self.downloadGroup)
        
        CSHFoursquareClient.sharedInstance.venuesAtLocation(location, queries: defaultWifiEnabledVenueNames, radius: "2500") { venues, error in
            defer { dispatch_group_leave(self.downloadGroup) }
            
            if let venues = venues {
                venues.forEach { self.delegate?.didFindWirelessVenue($0) }
                
                dispatch_barrier_async(self.queue, {
                    self.defaultWifiEnabledVenues.appendContentsOf(venues)
                })
            }
        }
    }

    private func lookForCoffeeVenues() {
        dispatch_group_enter(self.downloadGroup)
        
        CSHFoursquareClient.sharedInstance.coffeeVenuesAtLocation(self.location, radius: "2500") { (venues, error) in
            defer { dispatch_group_leave(self.downloadGroup) }
            
            if let venues = venues where venues.count > 0 {
                dispatch_barrier_async(self.queue, {
                    self.venues.appendContentsOf(venues)
                })
            }
        }
    }
    
    private func lookForFoodVenues() {
        dispatch_group_enter(self.downloadGroup)
        
        CSHFoursquareClient.sharedInstance.foodVenuesAtLocation(self.location, radius: "2500") { (venues, error) in
            defer { dispatch_group_leave(self.downloadGroup) }
            
            if let venues = venues where venues.count > 0 {
                dispatch_barrier_async(self.queue, {
                    self.venues.appendContentsOf(venues)
                })
            }
        }
    }
    
    func lookForVenuesWithWIFI() {
        self.delegate?.didStartLookingForVenues()
        
        lookForDefaultWirelessEnabledVenues()
        lookForFoodVenues()
        lookForCoffeeVenues()
        
        dispatch_group_notify(self.downloadGroup, dispatch_get_main_queue()) {
            self.lookForWifiEnabledVenues()
        }
    }
    
    private func lookForWifiEnabledVenues() {
        self.venues = self.venues.removeDuplicateVenues()
        let venueIdentifiers = self.venues.map{ $0.identifier as String }
        
        var sink = [CSHVenue]()
        
        let wifiTipsGroup = dispatch_group_create()
        venueIdentifiers.forEach {
            dispatch_group_enter(wifiTipsGroup)
            
            CSHFoursquareClient.sharedInstance.venueTipsWithIdentifier($0) { [weak self] tips, error in
                defer { dispatch_group_leave(wifiTipsGroup) }
                
                guard error == nil, let tips = tips else { return }
                
                guard let wifiTips = tips.values.first?.filter ({ $0.isWIFI() }) where wifiTips.count > 0,
                    let wifiIdentifier = tips.keys.first else { return }
                
                guard let wifiEnabledVenue = self?.venues.filter( { $0.identifier == wifiIdentifier} ).first else { return }
                sink.append(wifiEnabledVenue)
                self?.delegate?.didFindWirelessVenue(wifiEnabledVenue)
                
                print("wifiIdentifier: \(wifiIdentifier)")
            }
        }
        
        dispatch_group_notify(wifiTipsGroup, dispatch_get_main_queue(), {
            self.venues = (sink + self.defaultWifiEnabledVenues).removeDuplicateVenues()
            
            self.delegate?.didFinishLookingForVenues()
            
            self.lookForVenuesPhoto()
        })
    }
    
    private func lookForVenuesPhoto() {
        self.venues.map{ $0.identifier }.forEach {
            CSHFoursquareClient.sharedInstance.venuePhotosWithIdentifier($0) { result, error in
                
                guard let identifier = result?.keys.first else { return }
                guard let photos = result?.values.first where photos.count > 0,
                    let mostRecentPhoto = photos.first else {
                        print("No photo for: \(identifier)\n")
                        return
                }
                
                print("\(identifier) <-> \(mostRecentPhoto.url)\n")
                self.venues.updatePhotoURL(identifier, photoURL: mostRecentPhoto.url)
                if let venue = self.venues.venueForIdentifier(identifier) {
                    self.delegate?.didFindPhotoForWirelessVenue(venue)
                }
            }
        }
    }
}
