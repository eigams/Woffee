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
        subtitle = "\(venue.location?.address ?? "")  @\(venue.location?.distance ?? 0)m"
        if let lat = venue.location?.lat, let lng = venue.location?.lng {
            coordinate = CLLocationCoordinate2DMake(lat, lng)
        }
    }
}

@objc (ShopsListDataController)
class ShopsListDataController: NSObject, UITableViewDataSource {
    
    private var venues = [CSHVenue]()
    private var images = [String: NSData]()
    
    var annotations: [MKPointAnnotation]? {
        return venues.map { MKPointAnnotation(venue: $0) }
    }
    
    func venueAtIndexPath(indexPath: NSIndexPath) -> CSHVenue? {
        guard venues.count > indexPath.row else { return nil }
        
        return venues[indexPath.row]
    }
        
    func addVenue(venue: CSHVenue, completion: ((index: Int) -> Void)?) {
        guard self.venues.venueForIdentifier(venue.identifier) == nil else { return }
        
        venues.append(venue)
        images[venue.identifier] = nil
        
        venues = venues.sort{ $0.location?.distance < $1.location?.distance }
        
        if let index = self.venues.indexOf({$0.identifier == venue.identifier}) {
            completion?(index: index)
        }
    }

    func imageForVenue(venue: CSHVenue, completion: ((index: Int) -> Void)?) {
        guard images[venue.identifier] == nil,
              let photo = venue.photo else { return }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { [weak self] in
            guard let url = NSURL(string: photo),
                      imageData = NSData(contentsOfURL: url)  else { return }
            
            self?.images[venue.identifier] = imageData
            dispatch_sync(dispatch_get_main_queue(), { [weak self] in
                guard let index = self?.venues.indexOf({ $0.identifier == venue.identifier }) else { return }
                
                completion?(index: index)
            })
        })
    }
    
    func venueImageAtIndexPath(indexPath: NSIndexPath) -> UIImage? {
        guard let venue = venueAtIndexPath(indexPath) else { return nil }
        
        return UIImage(data: images[venue.identifier] ?? NSData())
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(CSHVenueTableViewCell.reusableIdentifier(), forIndexPath: indexPath) as? CSHVenueTableViewCell else { return UITableViewCell() }
        
        cell.configureWithVenue(venues[indexPath.row], image: venueImageAtIndexPath(indexPath))
        
        return cell
    }
}
