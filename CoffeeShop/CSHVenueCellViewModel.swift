//
//  CSHVenueCellViewModel.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 10/18/16.
//  Copyright © 2016 Stefan Burettea. All rights reserved.
//

import Foundation


struct CSHVenueCellViewModel {
    
    private (set) var name: String
    private (set) var rating: String
    private (set) var ratingColor: UIColor
    private (set) var price: String
    private (set) var openingHours: String
    private (set) var previewImage: UIImage
    private (set) var distance: String
    private (set) var street: String
    private (set) var cityPostCode: String
    
    init(venue: CSHVenue, image: UIImage?) {
        self.name = venue.name
        
        if let rating = venue.rating {
            self.rating = String(format: "%.1f", rating)
        }
        else {
            self.rating = ""
        }
        
        self.ratingColor = UIColor(hexString: venue.ratingColor ?? "") ?? UIColor.grayColor()
        self.price = [String](count: venue.price?.tier ?? 1, repeatedValue: venue.price?.currency ?? "€").reduce("", combine: +)
        
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