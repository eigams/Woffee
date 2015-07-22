//
//  VenuesManager.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 4/20/15.
//  Copyright (c) 2015 Stefan Burettea. All rights reserved.
//

import UIKit
import CoreLocation

@objc protocol VenuesManagerDelegate {
    
    func didFindWirelessVenue(venue: Venue?)
    func didFindWirelessVenuesGroup()
    func didFailToFindVenueWithError(error: NSError!)
    
optional
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

    private var _venues = Set<Venue>()
    private var _venuesIdentifiers = Set<String>()
    private var _tips = [String]()
    
    private var starbucksVenues = Set<Venue>()
    private var wifiTaggedVenues = Set<Venue>()
    private var coffeeVenues = Set<Venue>()
    private var foodVenues = Set<Venue>()
    private var defaultWifiEnabledVenues = [Set<Venue>]()
    
    private let location: CLLocation!
    var delegate: VenuesManagerDelegate?
    private var processedVenueIdentifiers = [String]()
    
    let defaultWifiEnabledVenueNames = ["starbucks", "caffe nero", "pizza express", "harris + hoole"]
    
    override init() {
        
        self.location = CLLocation()
        
        super.init()
    }
    
    init(location: CLLocation) {
        self.location = location
        
        super.init()
    }
    
    func getWifiVenues(input: NSArray) {
        
        getVenues(input)
        
    }
    
    private func getVenues(input: NSArray!) -> Set<Venue> {
        
        var venues = Set<Venue>()
        
        if input.count > 0 {
            for gItems in input {
                venues.insert(gItems.venue)
            }
        }
        
        return venues
    }
    
    private func getStarbucks(input: NSArray) -> Set<Venue> {
        
        let starbucks = Set<Venue>()
        
        let venues = getVenues(input)
        
        return starbucks
    }
    
    private func getWiffiTaggedVenues() {
        
        let distance = "2000"
        
        RestKitClient.getWifiTaggedVenues(self.location, radius: distance, completion: { (results: [AnyObject]?, error: NSError?) -> Void in
            
            if let err = error {
                println("\(error)")
                self.delegate?.didFailToFindVenueWithError(error!)
                self.delegate?.didFinishLookingForVenues()
                
                return
            }
            
            if results?.count < 1 {
                return ;
            }
            
            var wifiTaggedVenues:[Venue] = (results as! [Venue])
            
            var closeByVenues = wifiTaggedVenues.filter {
                return $0.location.distance.intValue < Int32(distance.toInt()!)
            }
            
            if self._venues.isEmpty {
                self.delegate?.didStartLookingForVenues?()
            }
            
            self.wifiTaggedVenues = VenuesManager.makeUniqueVenueSequence(&self._venues, breed: Set<Venue>(closeByVenues))

            Array(self.wifiTaggedVenues).filter {
                self.getVenuePhoto($0, completion: nil)
                return true
            }
//            for taggedVenues in self.wifiTaggedVenues {
//                self.getVenuePhoto(taggedVenues, completion: nil)
//            }
        })
    }
    
    private class func makeUniqueVenueSequence(inout all: Set<Venue>, breed: Set<Venue>) -> Set<Venue> {
    
        var uniques: Set<Venue> = Set<Venue>(breed)
        if all.isEmpty {
            all = Set<Venue>(breed)
        }
        else {
            
            uniques = breed.subtract(all)
            all = all.union(breed)
        }
        
        return uniques
    }
    
    private func getDefaultWirelessEnabledVenues() {
        
        let distance = "2500"
        for venue in self.defaultWifiEnabledVenueNames {
            
            RestKitClient.getDefaultWifiEnabledVenues(self.location, query: venue, radius: distance, completion: { (results: [AnyObject]!, error: NSError!) -> Void in
                
                if let err = error {
                    println("\(error)")
                    self.delegate?.didFailToFindVenueWithError(error!)
                    
                    if self.finishedLookingForVenues() {
                        self.delegate?.didFinishLookingForVenues()
                    }
                    
                    return
                }
                
                var defaultVenues:[Venue] = (results as! [Venue])
                
                let integerDistance = Int32(distance.toInt()!)
                var closeByVenues = defaultVenues.filter({ $0.location.distance.intValue < integerDistance })
                
                if self._venues.isEmpty {
                    self.delegate?.didStartLookingForVenues?()
                }
                
                var wirelessEnabledVenues = VenuesManager.makeUniqueVenueSequence(&self._venues, breed: Set<Venue>(closeByVenues))
                self.defaultWifiEnabledVenues.append(wirelessEnabledVenues)
                
                for venue in wirelessEnabledVenues {
                    self.getVenuePhoto(venue, completion: nil)
                }
                
            })
        }
        
    }
        
    private func processRequestVenueResponse(results: [AnyObject]?, error: NSError?, inout container: Set<Venue>) {
        
        if let err = error {
            println("\(error)")
            self.delegate?.didFailToFindVenueWithError(error!)
            self.delegate?.didFinishLookingForVenues()
            
            return
        }
        
        if results!.isEmpty {
            return;
        }
        
        if self._venues.isEmpty {
            self.delegate?.didStartLookingForVenues?()
        }
        
        var sink = results!.filter{ (venue) in venue.name.lowercaseString.rangeOfString("starbucks") == nil }
        
        objc_sync_enter(self._venues)
        container = VenuesManager.makeUniqueVenueSequence(&self._venues, breed: Set<Venue>(sink as! Array<Venue>))
        objc_sync_exit(self._venues)
        
        //3. get venues id
        var identifiers = Array(container).map {
            (venue) -> String in
            
            return venue.identifier
        }
        
        self.getVenuesTips(identifiers)
    }
    
    private func getCoffeeVenues() {
        
        RestKitClient.getCoffeeVenues(self.location, radius: "2500", completion: { (results: [AnyObject]?, error: NSError?) -> Void in
            
            if let err = error {
                println("\(error)")
                self.delegate?.didFailToFindVenueWithError(error!)
                self.delegate?.didFinishLookingForVenues()
                
                return
            }
            
            if results!.isEmpty {
                return;
            }
            
            if self._venues.isEmpty {
                self.delegate?.didStartLookingForVenues?()
            }
            
            var sink = results!.filter{ (venue) in venue.name.lowercaseString.rangeOfString("starbucks") == nil }
            
            objc_sync_enter(self._venues)
            self.coffeeVenues = VenuesManager.makeUniqueVenueSequence(&self._venues, breed: Set<Venue>(sink as! Array<Venue>))
            println("self.coffeeVenues.size: \(self.coffeeVenues.count) - self._venues.size: \(self._venues.count)")
            objc_sync_exit(self._venues)
            
            //3. get venues id
            var identifiers = Array(self.coffeeVenues).map {
                (venue) -> String in
                
                return venue.identifier
            }
            
            self.getVenuesTips(identifiers)
        })
    }
    
    private func getFoodVenues() {
        
        RestKitClient.getFoodVenues(self.location, radius: "2500", completion: { (results: [AnyObject]?, error: NSError?) -> Void in
            
            if let err = error {
                println("\(error)")
                self.delegate?.didFailToFindVenueWithError(error!)
                self.delegate?.didFinishLookingForVenues()
                
                return
            }
            
            if results!.isEmpty {
                return;
            }

            if self._venues.isEmpty {
                self.delegate?.didStartLookingForVenues?()
            }
            
            var sink = results!.filter{ (venue) in venue.name.lowercaseString.rangeOfString("starbucks") == nil }
            
            objc_sync_enter(self._venues)
            self.foodVenues = VenuesManager.makeUniqueVenueSequence(&self._venues, breed: Set<Venue>(sink as! Array<Venue>))
            objc_sync_exit(self._venues)

            //3. get venues id
            var identifiers = Array(self.foodVenues).map {
                (venue) -> String in
                
                return venue.identifier
            }
            
            self.getVenuesTips(identifiers)
        })
    }
    
    func venuesWithWIFI() {
        
        self.delegate?.didStartLookingForVenues?()
        
        self._venues = Set<Venue>()
        
        self.getWiffiTaggedVenues()
//        self.getStarbucksVenues()
        self.getDefaultWirelessEnabledVenues()
        self.getFoodVenues()
        self.getCoffeeVenues()
    }
    
    private func getVenuesTips(venuesIdentifiers: [String]?) {
        
        if let ids = venuesIdentifiers {
            
            if ids.isEmpty {
                return
            }
            
            var venuesContainer = self._venues
            
            if venuesIdentifiers?.count == self.coffeeVenues.count {
                venuesContainer = self.coffeeVenues
            }
            else {
                if venuesIdentifiers?.count == self.foodVenues.count {
                    venuesContainer = self.foodVenues
                }
            }
            
            //4. get all tips for venues id
            RestKitClient.getVenueTips(venuesIdentifiers, completion: { (result: [NSObject : AnyObject]?, error: NSError?) -> Void in
                
                if let err = error {
                    
                    self.delegate?.didFailToFindVenueWithError(error!)
                    if self.finishedLookingForVenues() {
                        self.delegate?.didFinishLookingForVenues()
                    }
                    
                    return
                }
                
                let key = result!.keys.first as! String
                let tips = result!.values.first as! [AnyObject]
                var wifiTipVenueIdentifier = ""
                
                var tipResult = tips.filter { (tip) -> Bool in
                    return self.isWifiTip(tip as! VenueTip)
                }
                
                if !tipResult.isEmpty {
                    wifiTipVenueIdentifier = key
                }
                
                if wifiTipVenueIdentifier.isEmpty {
                    var venues = Array<Venue>(venuesContainer).filter { $0.identifier == key }
                    var v = venues.first as Venue?
                    var result = self.removeProcessedVenue(v!)
                    if result.isEmpty {
                        self.delegate?.didFindWirelessVenuesGroup()
                        
                        if self.finishedLookingForVenues() {
                            self.delegate?.didFinishLookingForVenues()
                        }
                    }
                }
                else {
                    var wifiVenue = self.venuesWithWifiTips(wifiTipVenueIdentifier)
                    if let v = wifiVenue {
                        self.getVenuePhoto(wifiVenue!, completion: nil)
                    }
                }
            })

        }
    }
    
    private func getVenueIdentifiers(completion: ((Venue?, NSError?) -> Void)?) {
        
        //2. we process starbucks separately
        var sink = Array<Venue>(self._venues)
        sink = sink.filter{ (venue) in venue.name.lowercaseString.rangeOfString("starbucks") == nil }
        
        //3. get venues id
        var identifiers = sink.map {
            (venue) -> String in
            
            return venue.identifier
        }
        
        self.getVenuesTips(identifiers)
    }

    private class func updateVenuesContainer(container: Set<Venue>, venue: Venue) -> Set<Venue> {
        
        var sink = container
        if !container.isEmpty {
            if container.contains(venue) {
                sink.remove(venue)
                if sink.isEmpty {
                    println("self.wifiTaggedVenues.isEmpty")
                }
            }
            
            return sink
        }
        
        return container
    }
    
    private func removeProcessedVenue(venue: Venue) -> Set<Venue> {
        
        if !self.wifiTaggedVenues.isEmpty && self.wifiTaggedVenues.contains(venue) {
            self.wifiTaggedVenues.remove(venue)
            if self.wifiTaggedVenues.isEmpty {
                println("self.wifiTaggedVenues.isEmpty")
            }
            return self.wifiTaggedVenues
        }
        
        if !self.foodVenues.isEmpty && self.foodVenues.contains(venue) {
            self.foodVenues.remove(venue)
            if self.foodVenues.isEmpty {
                println("self.foodVenues.isEmpty")
            }
            
            println("self.foodVenues.size \(self.foodVenues.count)")
            return self.foodVenues
        }

        if !self.coffeeVenues.isEmpty && self.coffeeVenues.contains(venue) {
            self.coffeeVenues.remove(venue)
            if self.coffeeVenues.isEmpty {
                println("self.coffeeVenues.isEmpty")
            }
            return self.coffeeVenues
        }
        
        let defaultVenues = self.defaultWifiEnabledVenues.filter { !$0.isEmpty && $0.contains(venue) }
        if !defaultVenues.isEmpty {
            var venues = defaultVenues.first
            venues?.remove(venue)
            if let v = venues {
                if v.isEmpty {
                    println("v.isEmpty")
                }
            }
            
        }
        if !self.starbucksVenues.isEmpty && self.starbucksVenues.contains(venue) {
            self.starbucksVenues.remove(venue)
            if self.starbucksVenues.isEmpty {
                println("self.starbucksVenues.isEmpty")
            }
            return self.starbucksVenues
        }
        
        println("venue: \(venue)")
        
        var sink = Set<Venue>()
        sink.insert(Venue())
        
        return sink
    }
    
    private func getVenuePhoto(venue: Venue, completion: ((Venue?, NSError?) -> Void)?) {
        
        RestKitClient.getVenuePhotos(venue.identifier, completion: { (results: [AnyObject]?, error: NSError?) -> Void in
            
            if NSThread.isMainThread() {
                println("main thread")
            }
            
            println("getVenuePhoto")
            var sink = self.removeProcessedVenue(venue)
            
            if let err = error {
                completion?(venue, error)
                self.delegate?.didFailToFindVenueWithError(error!)
                
                if self.finishedLookingForVenues() {
                    self.delegate?.didFinishLookingForVenues()
                }
                
                return
            }
            
            let photos = results as! [Photo]
            
            for photo in photos {
                if photo.visibility == "public" {
                    let photoPath = "\(photo.prefix)\(photo.width)x\(photo.height)\(photo.suffix)"
                    
                    venue.photo = photoPath
                    
                    completion?(venue, nil)
                    
                    self.delegate?.didFindWirelessVenue(venue)
                    
                    break;
                }
            }
            
            if sink.isEmpty {
                self.delegate?.didFindWirelessVenuesGroup()
            }
            
            if self.finishedLookingForVenues() {
                self.delegate?.didFinishLookingForVenues()
            }
        })
    }
    
    private func defaultEnabledWirelessVenuesIsEmpty() -> Bool {
        
        let notEmpty = self.defaultWifiEnabledVenues.filter { !$0.isEmpty }
        
        return !notEmpty.isEmpty
    }
    
    private func finishedLookingForVenues() -> Bool {
        return self.wifiTaggedVenues.isEmpty &&
               self.defaultEnabledWirelessVenuesIsEmpty() &&
               self.foodVenues.isEmpty &&
               self.coffeeVenues.isEmpty
    }
    
    private func venuesWithWifiTips(wifiTipVenueIdentifier: String) -> Venue? {
    
        var sink = Array(self._venues)
        var venues = sink.filter{ $0.identifier == wifiTipVenueIdentifier }
        
        return venues.first
    }
    
    private func isWifiTip(tip: VenueTip) -> Bool {
        
        let venueTip = tip.text.lowercaseString
        let containsWifi = venueTip.rangeOfString("wifi") != nil
        let hasWifi = venueTip.rangeOfString("no wifi") == nil && venueTip.rangeOfString("no free wifi") == nil &&
                      venueTip.rangeOfString("no wi-fi") == nil && venueTip.rangeOfString("no free wi-fi") == nil
        
//        return true
        return containsWifi && hasWifi
    }
    
    func venues() -> NSArray {
        
        return NSArray()
    }
    
    func venuesWithWIFI(completion: (Venue?, NSError?) -> Void) {
        
        self.delegate?.didStartLookingForVenues!()
        
        //1. get all venues
        RestKitClient.getFoodVenues(self.location, radius: "2000", completion: { [unowned self] (results: [AnyObject]?, error: NSError?) -> Void in
            
            if let err = error {
                println("\(error)")
                completion(nil, error)
                self.delegate?.didFailToFindVenueWithError(error!)
                self.delegate?.didFinishLookingForVenues()
                
                return
            }
            
            if results!.count > 0 {
                self._venues = Set<Venue>(results as! Array<Venue>)
            }
            
            RestKitClient.getCoffeeVenues(self.location, radius: "2000", completion: { (results: [AnyObject]?, error: NSError?) -> Void in
                
                if let err = error {
                    println("\(error)")
                    completion(nil, error)
                    self.delegate?.didFailToFindVenueWithError(error!)
                    self.delegate?.didFinishLookingForVenues()
                    
                    return
                }
                
                if results!.count > 0 {
                    var set = Set<Venue>(results as! Array<Venue>)
                    
                    if self._venues.isEmpty {
                        self._venues = set
                    }
                    else {
                        self._venues = self._venues.union(set)
                    }
                }
                
                self.getVenueIdentifiers(completion)
            })
            })
    }
    
}
