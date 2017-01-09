//
//  NSDate+WoffeShop.swift
//  RKGeonames
//
//  Created by Stefan Buretea on 4/3/15.
//  Copyright (c) 2015 Stefan Burettea. All rights reserved.
//

import Foundation

extension Date {
    
    fileprivate var dateFormatter: DateFormatter {
        
        struct Static {
            static let instance: DateFormatter = {
                let formatter = DateFormatter()
                formatter.timeZone = TimeZone.current
                
                return formatter
                }()
        }
        
        return Static.instance
    }
    
    func stringWithDateFormat(_ dateFormat: String) -> String {
        
        self.dateFormatter.dateFormat = dateFormat
        
        return self.dateFormatter.string(from: self)
    }
    
}
