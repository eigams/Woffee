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
    
    func didFindWirelessVenue(_ venue: CSHVenue?)
    func didFindPhotoForWirelessVenue(_ venue: CSHVenue)
    func didFailToFindVenueWithError(_ error: NSError!)
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

    fileprivate let queue: DispatchQueue = DispatchQueue(label: "com.coffeshop.cachevenues", attributes: DispatchQueue.Attributes.concurrent)
    fileprivate var venues = [CSHVenue]()
    fileprivate var defaultWifiEnabledVenues = [CSHVenue]()
    
    fileprivate let location: CLLocation!
    fileprivate lazy var downloadGroup: DispatchGroup = {
        return DispatchGroup()
    }()
    
    fileprivate let standardLookupRadius = "2500"
    
    var delegate: VenuesManagerDelegate?
    
    fileprivate let defaultWifiEnabledVenueNames = ["starbucks", "caffe nero", "pizza express", "harris + hoole"]
    
    override init() {
        self.location = CLLocation()
        
        super.init()
    }
    
    init(location: CLLocation) {
        self.location = location
        
        super.init()
    }
    
    fileprivate func lookForDefaultWirelessEnabledVenues() {
        let defaultWifiEnabledVenueNames = ["starbucks", "pizza express", "harris + hoole"]
        
        let defaultEnabledWirelessVenuesDownloadGroup = DispatchGroup()
        downloadGroup.enter()
        
        CSHFoursquareClient.sharedInstance.venues(location: location, queries: defaultWifiEnabledVenueNames, radius: standardLookupRadius) { venues, error in
            defer { self.downloadGroup.leave() }
            
            if let venues = venues {
                venues.forEach { self.delegate?.didFindWirelessVenue($0) }
                
                self.queue.async(flags: .barrier, execute: {
                    self.defaultWifiEnabledVenues.append(contentsOf: venues)
                })
            }
        }
    }

    fileprivate func lookForCoffeeVenues() {
        downloadGroup.enter()
        
        CSHFoursquareClient.sharedInstance.coffeeVenuesAtLocation(location, radius: standardLookupRadius) { (venues, error) in
            defer { self.downloadGroup.leave() }
            
            if let venues = venues, venues.count > 0 {
                self.queue.async(flags: .barrier, execute: {
                    self.venues.append(contentsOf: venues)
                })
            }
        }
    }
    
    fileprivate func lookForFoodVenues() {
        downloadGroup.enter()
        
        CSHFoursquareClient.sharedInstance.foodVenuesAtLocation(location, radius: standardLookupRadius) { (venues, error) in
            defer { self.downloadGroup.leave() }
            
            if let venues = venues, venues.count > 0 {
                self.queue.async(flags: .barrier, execute: {
                    self.venues.append(contentsOf: venues)
                })
            }
        }
    }
    
    func lookForVenuesWithWIFI() {
        delegate?.didStartLookingForVenues()
        
        lookForDefaultWirelessEnabledVenues()
        lookForFoodVenues()
        lookForCoffeeVenues()
        
        self.downloadGroup.notify(queue: DispatchQueue.main) {
            self.lookForWifiEnabledVenues()
        }
    }
    
    fileprivate func lookForWifiEnabledVenues() {
        venues = venues.removeDuplicates()
        let venueIdentifiers = venues.map{ $0.identifier as String }
        
        var sink = [CSHVenue]()
        
        let wifiTipsGroup = DispatchGroup()
        venueIdentifiers.forEach {
            wifiTipsGroup.enter()
            
            CSHFoursquareClient.sharedInstance.venueTips(identifier: $0) { [weak self] tips, error in
                defer { wifiTipsGroup.leave() }
                
                guard error == nil, let tips = tips else { return }
                
                guard let _ = tips.values.first?.index (where: { $0.isWIFI() }),
                      let wifiIdentifier = tips.keys.first else { return }
                
                guard let wifiEnabledVenue = self?.venues.index(where: { $0.identifier == wifiIdentifier} ).flatMap({ self?.venues[$0] }) else { return }
                sink.append(wifiEnabledVenue)
                self?.delegate?.didFindWirelessVenue(wifiEnabledVenue)
            }
        }
        
        wifiTipsGroup.notify(queue: DispatchQueue.main, execute: {
            self.venues = (sink + self.defaultWifiEnabledVenues).removeDuplicates()
            
            self.delegate?.didFinishLookingForVenues()
            
            self.lookForVenuesPhoto()
        })
    }
    
    fileprivate func lookForVenuesPhoto() {
        venues.map{ $0.identifier }.forEach {
            CSHFoursquareClient.sharedInstance.venuePhotos(identifier: $0) { result, error in
                guard let identifier = result?.keys.first else { return }
                guard let photos = result?.values.first, photos.count > 0,
                      let mostRecentPhoto = photos.first else {
                        print("No photo for: \(identifier)\n")
                        return
                }
                
                self.venues.updatePhotoURL(identifier, photoURL: mostRecentPhoto.url)
                if let venue = self.venues.venueForIdentifier(identifier) {
                    self.delegate?.didFindPhotoForWirelessVenue(venue)
                }
            }
        }
    }
}
