//
//  ShopsListDataController.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 2/20/16.
//  Copyright © 2016 Stefan Burettea. All rights reserved.
//

import UIKit
import MapKit

extension MKPointAnnotation {
    convenience init(venue: CSHVenue) {
        self.init()
        title = venue.name
        subtitle = "\(venue.location?.address)  @\(venue.location?.distance)m"
        if let lat = venue.location?.lat, let lng = venue.location?.lng {
            coordinate = CLLocationCoordinate2DMake(lat, lng)
        }
    }
}

@objc (ShopsListDataController)
class ShopsListDataController: NSObject, UITableViewDataSource {
    
    private var venues:NSMutableOrderedSet = NSMutableOrderedSet()
    private var images:[String: NSData]?
    
    func venueAtIndexPath(indexPath: NSIndexPath) -> CSHVenue? {
        guard self.venues.count > indexPath.row else { return nil }
        
        return self.venues[indexPath.row] as? CSHVenue
    }
    
    func sortVenuesByDistance() {
        let sortedVenues = self.venues.array.sort({
            ($0 as! CSHVenue).location?.distance < ($1 as! CSHVenue).location?.distance
        })

        self.venues = NSMutableOrderedSet(array: sortedVenues)
    }
    
    func annotations() -> [MKPointAnnotation]? {
        guard let venues = self.venues.array as? Array<CSHVenue> else { return nil }
        
        return venues.map { MKPointAnnotation(venue: $0) }
    }
    
    func addVenue(venue: CSHVenue, completion: ((index: Int) -> Void)?) {
        guard let photo = venue.photo where false == self.venues.containsObject(venue) else { return }
        
        venues.addObject(venue)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            guard let imageData = NSData(contentsOfURL: NSURL(string:photo)!) else { return }
            
            print("set venue image for: \(venue.name) imageData count: \(imageData.length)")
//            self.venuesImage[venue.identifier] = imageData
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                guard let index = Array(arrayLiteral: venues).indexOf(venue)
//                      where venues.count > 0 else {
//                        completion?(index: -1)
//                        return
//                }
                
                completion?(index: -1)
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
        
        guard let venue = venues[indexPath.row] as? CSHVenue else { return cell }
        
        cell.configureWithVenue(venue)
        
        return cell
    }
}
