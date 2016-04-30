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
    func didFindWirelessVenuesGroup()
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

    private var venues = [CSHVenue]()
    private var venuesIdentifiers = [String]()
    private var tips = [String]()
    
    private var starbucksVenues = [CSHVenue]()
    private var wifiTaggedVenues = [CSHVenue]()
    private var coffeeVenues = [CSHVenue]()
    private var foodVenues = [CSHVenue]()
    private var defaultWifiEnabledVenues = [[CSHVenue]]()
    private let downloadGroup: dispatch_group_t
    
    private let location: CLLocation!
    var delegate: VenuesManagerDelegate?
    private var processedVenueIdentifiers = [String]()
    
    private let defaultWifiEnabledVenueNames = ["starbucks", "caffe nero", "pizza express", "harris + hoole"]
    
    override init() {
        self.location = CLLocation()
        self.downloadGroup = dispatch_group_create()
        
        super.init()
    }
    
    init(location: CLLocation) {
        self.location = location
        self.downloadGroup = dispatch_group_create()
        
        super.init()
    }
    
    func getWifiVenues(input: NSArray) {
        
        getVenues(input)
        
    }
    
    private func getVenues(input: NSArray) -> [CSHVenue] {
        var venues = [CSHVenue]()
        
//        return input.map{ $0.venue }
        return venues
    }
    
    private func getStarbucks(input: NSArray) -> [CSHVenue] {
        guard input.count > 0 else {
            return [CSHVenue]()
        }
        
        let starbucks = [CSHVenue]()
        
        let venues = getVenues(input)
        
        return starbucks
    }
    
    private let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    private func getWiffiTaggedVenues() {
        
        let distance = "2000"
        
        dispatch_group_enter(self.downloadGroup)
//        RestKitClient.getWifiTaggedVenues(self.location, radius: distance, completion: { (results: [AnyObject]?, error: NSError?) -> Void in
//            
//            defer {
//                dispatch_group_leave(self.downloadGroup)
//            }
//            
//            if let error = error {
//                print("\(error)")
//                self.delegate?.didFailToFindVenueWithError(error)
//                self.delegate?.didFinishLookingForVenues()
//                
//                return
//            }
//            
//            guard let results = results where results.count >= 1 else {
//                return
//            }
//            
//            let wifiTaggedVenues:[Venue] = (results as! [Venue])
//            
//            let closeByVenues = wifiTaggedVenues.filter {
//                return $0.location.distance.intValue < Int32(Int(distance)!)
//            }
//            
//            if self._venues.isEmpty {
//                self.delegate?.didStartLookingForVenues?()
//            }
//            
//            self.wifiTaggedVenues = VenuesManager.makeUniqueVenueSequence(&self._venues, breed: Set<Venue>(closeByVenues))
//
//            Array(self.wifiTaggedVenues).filter {
//                self.getVenuePhoto($0, completion: nil)
//                return true
//            }
////            for taggedVenues in self.wifiTaggedVenues {
////                self.getVenuePhoto(taggedVenues, completion: nil)
////            }
//        })
    }
    
    private class func makeUniqueVenueSequence(inout all: [CSHVenue], breed: [CSHVenue]) -> [CSHVenue] {
    
//        var uniques: Set<CSHVenue> = Set<CSHVenue>(breed)
//        if all.isEmpty {
//            all = breed
//        }
//        else {
//            
//            uniques = breed.subtract(all)
////            all = all.union(breed)
//        }
//        
//        return uniques
        return [CSHVenue]()
    }
    
    private func getDefaultWirelessEnabledVenues() {
        
        let distance = "2500"
        for venue in self.defaultWifiEnabledVenueNames {
            
            dispatch_group_enter(self.downloadGroup)
//            RestKitClient.getDefaultWifiEnabledVenues(self.location, query: venue, radius: distance, completion: { (results: [AnyObject]!, error: NSError?) -> Void in
//                
//                defer {
//                    dispatch_group_leave(self.downloadGroup)
//                }
//                
//                if let error = error {
//                    print("\(error)")
//                    self.delegate?.didFailToFindVenueWithError(error)
//                    
//                    if self.finishedLookingForVenues() {
//                        self.delegate?.didFinishLookingForVenues()
//                    }
//                    
//                    return
//                }
//                
//                let defaultVenues:[Venue] = (results as! [Venue])
//                
//                let integerDistance = Int32(Int(distance)!)
//                let closeByVenues = defaultVenues.filter({ $0.location.distance.intValue < integerDistance })
//                
//                if self._venues.isEmpty {
//                    self.delegate?.didStartLookingForVenues?()
//                }
//                
//                let wirelessEnabledVenues = VenuesManager.makeUniqueVenueSequence(&self._venues, breed: Set<Venue>(closeByVenues))
//                self.defaultWifiEnabledVenues.append(wirelessEnabledVenues)
//                
//                for venue in wirelessEnabledVenues {
//                    self.getVenuePhoto(venue, completion: nil)
//                }
//                
//            })
        }
        
    }
        
    private func processRequestVenueResponse(results: [AnyObject]?, error: NSError?, inout container: [CSHVenue]) {
        
        if let error = error {
            print("\(error)")
            self.delegate?.didFailToFindVenueWithError(error)
            self.delegate?.didFinishLookingForVenues()
            
            return
        }
        
        if results!.isEmpty {
            return;
        }
        
        if self.venues.isEmpty {
            self.delegate?.didStartLookingForVenues()
        }
        
        let sink = results!.filter{ (venue) in venue.name.lowercaseString.rangeOfString("starbucks") == nil }
        
//        objc_sync_enter(self._venues)
        container = VenuesManager.makeUniqueVenueSequence(&self.venues, breed: [CSHVenue](sink as! Array<CSHVenue>))
//        objc_sync_exit(self._venues)
        
        //3. get venues id
        let identifiers = Array(container).map {
            (venue) -> String in
            
            return venue.identifier
        }
        
        self.getVenuesTips(identifiers)
    }
    
    private func getCoffeeVenues() {
        
        dispatch_group_enter(self.downloadGroup)
//        RestKitClient.getCoffeeVenues(self.location, radius: "2500", completion: { (results: [AnyObject]?, error: NSError?) -> Void in
//            
//            defer { dispatch_group_leave(self.downloadGroup) }
//            
//            if let error = error {
//                print("\(error)")
//                self.delegate?.didFailToFindVenueWithError(error)
//                self.delegate?.didFinishLookingForVenues()
//                
//                return
//            }
//            
//            if results!.isEmpty {
//                return;
//            }
//            
//            if self._venues.isEmpty {
//                self.delegate?.didStartLookingForVenues?()
//            }
//            
//            let sink = results!.filter{ (venue) in venue.name.lowercaseString.rangeOfString("starbucks") == nil }
//            
//            objc_sync_enter(self._venues)
//            self.coffeeVenues = VenuesManager.makeUniqueVenueSequence(&self._venues, breed: Set<Venue>(sink as! Array<Venue>))
//            print("self.coffeeVenues.size: \(self.coffeeVenues.count) - self._venues.size: \(self._venues.count)")
//            objc_sync_exit(self._venues)
//            
//            //3. get venues id
//            let identifiers = Array(self.coffeeVenues).map {
//                (venue) -> String in
//                
//                return venue.identifier
//            }
//            
//            self.getVenuesTips(identifiers)
//        })
    }
    
    private func getFoodVenues() {
        
        dispatch_group_enter(self.downloadGroup)
//        RestKitClient.getFoodVenues(self.location, radius: "2500", completion: { (results: [AnyObject]?, error: NSError?) -> Void in
//            
//            defer { dispatch_group_leave(self.downloadGroup) }
//            
//            if let error = error {
//                print("\(error)")
//                self.delegate?.didFailToFindVenueWithError(error)
//                self.delegate?.didFinishLookingForVenues()
//                
//                return
//            }
//            
//            if results!.isEmpty {
//                return;
//            }
//
//            if self._venues.isEmpty {
//                self.delegate?.didStartLookingForVenues?()
//            }
//            
//            let sink = results!.filter{ (venue) in venue.name.lowercaseString.rangeOfString("starbucks") == nil }
//            
//            objc_sync_enter(self._venues)
//            self.foodVenues = VenuesManager.makeUniqueVenueSequence(&self._venues, breed: Set<Venue>(sink as! Array<Venue>))
//            objc_sync_exit(self._venues)
//
//            //3. get venues id
//            let identifiers = Array(self.foodVenues).map {
//                (venue) -> String in
//                
//                return venue.identifier
//            }
//            
//            self.getVenuesTips(identifiers)
//        })
    }
    
    func lookForVenuesWithWIFI() {
        
        self.delegate?.didStartLookingForVenues()
        
        self.venues = [CSHVenue]()
        
        self.getWiffiTaggedVenues()
//        self.getStarbucksVenues()
        self.getDefaultWirelessEnabledVenues()
        self.getFoodVenues()
        self.getCoffeeVenues()
    }
    
    private func getVenuesTips(venuesIdentifiers: [String]) {
        
//        if let ids = venuesIdentifiers {
//            
//            if ids.isEmpty {
//                return
//            }
        
            var venuesContainer = self.venues
            
            if venuesIdentifiers.count == self.coffeeVenues.count {
                venuesContainer = self.coffeeVenues
            }
            else {
                if venuesIdentifiers.count == self.foodVenues.count {
                    venuesContainer = self.foodVenues
                }
            }
            
            //4. get all tips for venues id
//            RestKitClient.getVenueTips(venuesIdentifiers, completion: { (result: [NSObject : AnyObject]?, error: NSError?) -> Void in
//                
//                if let error = error {
//                    
//                    self.delegate?.didFailToFindVenueWithError(error)
//                    if self.finishedLookingForVenues() {
//                        self.delegate?.didFinishLookingForVenues()
//                    }
//                    
//                    return
//                }
//                
//                let key = result!.keys.first as! String
//                let tips = result!.values.first as! [AnyObject]
//                var wifiTipVenueIdentifier = ""
//                
//                let tipResult = tips.filter { (tip) -> Bool in
//                    return self.isWifiTip(tip as! VenueTip)
//                }
//                
//                if !tipResult.isEmpty {
//                    wifiTipVenueIdentifier = key
//                }
//                
//                if wifiTipVenueIdentifier.isEmpty {
//                    let venues = Array<Venue>(venuesContainer).filter { $0.identifier == key }
//                    let v = venues.first as Venue?
//                    let result = self.removeProcessedVenue(v!)
//                    if result.isEmpty {
//                        self.delegate?.didFindWirelessVenuesGroup()
//                        
//                        if self.finishedLookingForVenues() {
//                            self.delegate?.didFinishLookingForVenues()
//                        }
//                    }
//                }
//                else {
//                    let wifiVenue = self.venuesWithWifiTips(wifiTipVenueIdentifier)
//                    if let _ = wifiVenue {
//                        self.getVenuePhoto(wifiVenue!, completion: nil)
//                    }
//                }
//            })

//        }
    }
    
    private func getVenueIdentifiers(completion: ((CSHVenue?, NSError?) -> Void)?) {
        
        //2. we process starbucks separately
        let identifiers = Array<CSHVenue>(self.venues).filter{ $0.name.lowercaseString.rangeOfString("starbucks") == nil }
                                                      .map{ return $0.identifier }
        
        //3. get venues id
//        let identifierss = sink.map ({
//            (venue) -> String in
//            
//            return venue.identifier
//        })
        
//        getVenuesTips(identifiers)
    }
    
    private func removeProcessedVenue(venue: CSHVenue) -> [CSHVenue] {
        
//        if !self.wifiTaggedVenues.isEmpty && self.wifiTaggedVenues.contains(venue) {
//            self.wifiTaggedVenues.remove(venue)
//            if self.wifiTaggedVenues.isEmpty {
//                print("self.wifiTaggedVenues.isEmpty")
//            }
//            return self.wifiTaggedVenues
//        }
//        
//        if !self.foodVenues.isEmpty && self.foodVenues.contains(venue) {
//            self.foodVenues.remove(venue)
//            if self.foodVenues.isEmpty {
//                print("self.foodVenues.isEmpty")
//            }
//            
//            print("self.foodVenues.size \(self.foodVenues.count)")
//            return self.foodVenues
//        }
//
//        if !self.coffeeVenues.isEmpty && self.coffeeVenues.contains(venue) {
//            self.coffeeVenues.remove(venue)
//            if self.coffeeVenues.isEmpty {
//                print("self.coffeeVenues.isEmpty")
//            }
//            return self.coffeeVenues
//        }
//        
//        let defaultVenues = self.defaultWifiEnabledVenues.filter { !$0.isEmpty && $0.contains(venue) }
//        if !defaultVenues.isEmpty {
//            var venues = defaultVenues.first
//            venues?.remove(venue)
//            if let v = venues {
//                if v.isEmpty {
//                    print("v.isEmpty")
//                }
//            }
//            
//        }
//        if !self.starbucksVenues.isEmpty && self.starbucksVenues.contains(venue) {
//            self.starbucksVenues.remove(venue)
//            if self.starbucksVenues.isEmpty {
//                print("self.starbucksVenues.isEmpty")
//            }
//            return self.starbucksVenues
//        }
//        
//        print("venue: \(venue)")
        
        var sink = [CSHVenue]()
//        sink.appendx(CSHVenue())
        
        return sink
    }
    
    private func getVenuePhoto(venue: CSHVenue, completion: ((CSHVenue?, NSError?) -> Void)?) {
        
        dispatch_group_enter(self.downloadGroup)
//        RestKitClient.getVenuePhotos(venue.identifier, completion: { (results: [AnyObject]?, error: NSError?) -> Void in
//            
//            defer {
//                dispatch_group_leave(self.downloadGroup)
//            }
//            
//            print("getVenuePhoto")
//            let sink = self.removeProcessedVenue(venue)
//            
//            if let error = error {
//                completion?(venue, error)
//                self.delegate?.didFailToFindVenueWithError(error)
//                
//                if self.finishedLookingForVenues() {
//                    self.delegate?.didFinishLookingForVenues()
//                }
//                
//                return
//            }
//            
//            let photos = results as! [Photo]
//            
//            let publicPhotos = photos.filter({ (photo) -> Bool in
//                return photo.visibility == "public"
//            })
//            
//            if let publicPhoto = publicPhotos.first {
//                let photoPath = "\(publicPhoto.prefix)\(publicPhoto.width)x\(publicPhoto.height)\(publicPhoto.suffix)"
//                
//                venue.photo = photoPath
//                
//                completion?(venue, nil)
//                
//                self.delegate?.didFindWirelessVenue(venue)
//            }
//            
//            if sink.isEmpty {
//                self.delegate?.didFindWirelessVenuesGroup()
//            }
//            
//            if self.finishedLookingForVenues() {
//                self.delegate?.didFinishLookingForVenues()
//            }
//        })
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
    
    private func venuesWithWifiTips(wifiTipVenueIdentifier: String) -> CSHVenue? {
    
        let sink = Array(self.venues)
        let venues = sink.filter{ $0.identifier == wifiTipVenueIdentifier }
        
        return venues.first
    }
    
    private func isWifiTip(tip: CSHVenueTip) -> Bool {
        guard let venueTip = tip.text else { return false }
        
        let containsWifi = venueTip.rangeOfString("wifi") != nil
        let hasWifi = venueTip.rangeOfString("no wifi") == nil && venueTip.rangeOfString("no free wifi") == nil &&
                      venueTip.rangeOfString("no wi-fi") == nil && venueTip.rangeOfString("no free wi-fi") == nil

        return containsWifi && hasWifi
    }
    
//    func venues() -> NSArray {
//        return NSArray()
//    }
    
    func venuesWithWIFI(completion: (CSHVenue?, NSError?) -> Void) {
        
        self.delegate?.didStartLookingForVenues()
        
        let downloadGroup = dispatch_group_create()
        
        dispatch_group_enter(downloadGroup)
        //1. get all venues
//        RestKitClient.getFoodVenues(self.location, radius: "2000", completion: { [unowned self] (results: [AnyObject]?, error: NSError?) -> Void in
//            
//            if let error = error {
//                print("\(error)")
//                completion(nil, error)
//                self.delegate?.didFailToFindVenueWithError(error)
//                self.delegate?.didFinishLookingForVenues()
//                
//                dispatch_group_leave(downloadGroup)
//                
//                return
//            }
//            
//            if results!.count > 0 {
//                self._venues = Set<Venue>(results as! Array<Venue>)
//            }
//
//            dispatch_group_leave(downloadGroup)
//        })
        
        dispatch_group_enter(downloadGroup)
//        RestKitClient.getCoffeeVenues(self.location, radius: "2000", completion: { (results: [AnyObject]?, error: NSError?) -> Void in
//            
//            if let error = error {
//                print("\(error)")
//                completion(nil, error)
//                self.delegate?.didFailToFindVenueWithError(error)
//                self.delegate?.didFinishLookingForVenues()
//                
//                return
//            }
//            
//            if results!.count > 0 {
//                let set = Set<Venue>(results as! Array<Venue>)
//                
//                if self._venues.isEmpty {
//                    self._venues = set
//                }
//                else {
//                    self._venues = self._venues.union(set)
//                }
//            }
//            
//            dispatch_group_leave(downloadGroup)
//        })
        
        dispatch_group_notify(downloadGroup, dispatch_get_main_queue()) { // 4
            self.getVenueIdentifiers(completion)
        }
    }
    
}
