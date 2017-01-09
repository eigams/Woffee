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
    
    fileprivate var venues = [CSHVenue]()
    fileprivate var images = [String: Data]()
    
    var annotations: [MKPointAnnotation]? {
        return venues.map { MKPointAnnotation(venue: $0) }
    }
    
    func venueAtIndexPath(_ indexPath: IndexPath) -> CSHVenue? {
        guard venues.count > indexPath.row else { return nil }
        
        return venues[indexPath.row]
    }
        
    func addVenue(_ venue: CSHVenue, completion: ((Int) -> Void)?) {
        guard self.venues.venueForIdentifier(venue.identifier) == nil else { return }
        
        venues.append(venue)
        images[venue.identifier] = nil
        
        venues = venues.sorted{ $0.location?.distance ?? 0 < $1.location?.distance ?? 0 }
        
        if let index = self.venues.index(where: {$0.identifier == venue.identifier}) {
            completion?(index)
        }
    }

    func imageForVenue(_ venue: CSHVenue, completion: ((_ index: Int) -> Void)?) {
        guard images[venue.identifier] == nil,
              let photo = venue.photo else { return }
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: { [weak self] in
            guard let url = URL(string: photo),
                      let imageData = try? Data(contentsOf: url)  else { return }
            
            self?.images[venue.identifier] = imageData
            DispatchQueue.main.sync(execute: { [weak self] in
                guard let index = self?.venues.index(where: { $0.identifier == venue.identifier }) else { return }
                
                completion?(index)
            })
        })
    }
    
    func venueImage(indexPath: IndexPath) -> UIImage? {
        guard let venue = venueAtIndexPath(indexPath) else { return nil }
        
        return UIImage(data: images[venue.identifier] ?? Data())
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CSHVenueTableViewCell.reusableIdentifier(), for: indexPath) as? CSHVenueTableViewCell else { return UITableViewCell() }
        
        cell.model = CSHVenueCellViewModel(venue: venues[indexPath.row], image: venueImage(indexPath: indexPath))
        
        return cell
    }
}
