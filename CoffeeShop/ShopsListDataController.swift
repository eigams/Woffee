//
//  ShopsListDataController.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 2/20/16.
//  Copyright © 2016 Stefan Burettea. All rights reserved.
//

import UIKit
import MapKit

@objc (ShopsListDataController)
class ShopsListDataController: NSObject, UITableViewDataSource {
    
    private var venues:NSMutableOrderedSet = NSMutableOrderedSet()
    private var images:[String: NSData]?
    
    func venueAtIndexPath(indexPath: NSIndexPath) -> Venue? {
        guard self.venues.count > indexPath.row else { return nil }
        guard let venue = self.venues[indexPath.row] as? Venue else { return nil }
        
        return venue
    }
    
    func sortVenuesByDistance() {
        let sortedVenues = self.venues.array.sort({ (venue1, venue2) -> Bool in
            return (venue1 as! Venue).location.distance.intValue < (venue2 as! Venue).location.distance.intValue
        })

        self.venues = NSMutableOrderedSet(array: sortedVenues)
    }
    
    func annotations() -> [MKPointAnnotation]? {
        guard let venues = self.venues.array as? [Venue] else { return nil }
        
        let annotations = venues.map { (venue) -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.title = venue.name
            annotation.subtitle = "\(venue.location.address)  @\(venue.location.distance)m"
            annotation.coordinate = CLLocationCoordinate2DMake(venue.location.lat.doubleValue, venue.location.lng.doubleValue)
            
            return annotation
        }
        
        return annotations
    }
    
    func addVenue(venue: Venue, completion: (index: Int) -> Void) {
        guard let photo = venue.photo where false == self.venues.containsObject(venue) else { return }
        
        self.venues.addObject(venue)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            guard let imageData = NSData(contentsOfURL: NSURL(string:photo)!) else { return }
            
            print("set venue image for: \(venue.name) imageData count: \(imageData.length)")
//            self.venuesImage[venue.identifier] = imageData
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                guard let index = Array(arrayLiteral: self.venues).indexOf(venue)
                      where self.venues.count > 0 else {
                        completion(index: -1)
                        return
                }
                
                completion(index: index)
            })
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(VenueTableViewCell.reusableIdentifier(), forIndexPath: indexPath) as? VenueTableViewCell else { return UITableViewCell() }
        
        guard let venue = venues[indexPath.row] as? Venue else { return cell }
        
        cell.configureForVenue(venue)
        
        return cell
    }
}
