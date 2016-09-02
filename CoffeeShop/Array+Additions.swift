//
//  Array+Additions.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 8/29/16.
//  Copyright © 2016 Stefan Burettea. All rights reserved.
//

import Foundation


extension Array where Element:CSHVenue {
    func removeDuplicateVenues() -> Array {
        var seen: [String:Bool] = [:]
        
        return self.filter{
            seen.updateValue(false, forKey: $0.identifier) ?? true
        }
    }
    
    func updatePhotoURL(identifier: String, photoURL: String) {
        guard let venue = self.venueForIdentifier(identifier) else { return }
        
        venue.photo = photoURL
    }
    
    func venueForIdentifier(identifier: String) -> CSHVenue? {
        return self.indexOf { $0.identifier == identifier }.map{ self[$0] }
    }
}