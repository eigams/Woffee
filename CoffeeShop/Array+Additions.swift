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
    
    func updateVenue(_ identifier: String, withPhotoURL photoURL: String) {
        guard let venue = self.venue(for: identifier) else { return }
        
        venue.photo = photoURL
    }
    
    func venue(for identifier: String) -> CSHVenue? {
        return self.index { $0.identifier == identifier }.map{ self[$0] }
    }
    
    func contains(_ venue: CSHVenue?) -> Bool {
        if let venue = venue {
            return self.venue(for: venue.identifier) != nil
        }
        
        return false
    }
}
