//
//  CSHVenueCellViewModel.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 10/18/16.
//  Copyright © 2016 Stefan Burettea. All rights reserved.
//

import Foundation


struct CSHVenueCellViewModel {
    
    fileprivate (set) var name: String
    fileprivate (set) var rating: String
    fileprivate (set) var ratingColor: UIColor
    fileprivate (set) var price: String
    fileprivate (set) var openingHours: String
    fileprivate (set) var previewImage: UIImage
    fileprivate (set) var distance: String
    fileprivate (set) var street: String
    fileprivate (set) var cityPostCode: String
    
    init(venue: CSHVenue, image: UIImage?) {
        self.name = venue.name
        
        if let rating = venue.rating {
            self.rating = String(format: "%.1f", rating)
        }
        else {
            self.rating = ""
        }
        
        self.ratingColor = UIColor(hexString: venue.ratingColor ?? "") ?? UIColor.gray
        self.price = [String](repeating: venue.price?.currency ?? "€", count: venue.price?.tier ?? 1).reduce("", +)
        
        if let status = venue.hours?.status {
            self.openingHours = status
        }
        else {
            self.openingHours = venue.hours?.isOpen ?? false ? "Open" : ""
        }
        
        self.previewImage = image ?? UIImage()
        
        self.distance = "\(venue.location?.distance ?? 0) m"
        self.street = venue.location?.address ?? ""
        self.cityPostCode = venue.address
        
    }
}
