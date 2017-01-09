//
//  Array+Additions.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 8/29/16.
//  Copyright © 2016 Stefan Burettea. All rights reserved.
//

import Foundation


extension Array where Element:CSHVenue {
    func removeDuplicates() -> Array {
        var seen: [String:Bool] = [:]
        
        return self.filter{
            seen.updateValue(false, forKey: $0.identifier) ?? true
        }
    }
    
    func updatePhotoURL(_ identifier: String, photoURL: String) {
        guard let venue = self.venueForIdentifier(identifier) else { return }
        
        venue.photo = photoURL
    }
    
    func venueForIdentifier(_ identifier: String) -> CSHVenue? {
        return self.index { $0.identifier == identifier }.map{ self[$0] }
    }
}
