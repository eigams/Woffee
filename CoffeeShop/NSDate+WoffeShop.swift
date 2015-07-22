//
//  NSDate+WoffeShop.swift
//  RKGeonames
//
//  Created by Stefan Buretea on 4/3/15.
//  Copyright (c) 2015 Stefan Burettea. All rights reserved.
//

import Foundation

extension NSDate {
    
    private var dateFormatter: NSDateFormatter {
        
        struct Static {
            static let instance: NSDateFormatter = {
                let formatter = NSDateFormatter()
                formatter.timeZone = NSTimeZone.systemTimeZone()
                
                return formatter
                }()
        }
        
        return Static.instance
    }
    
    func stringWithDateFormat(dateFormat: String) -> String {
        
        self.dateFormatter.dateFormat = dateFormat
        
        return self.dateFormatter.stringFromDate(self)
    }
    
}