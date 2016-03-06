//
//  CSFadeable.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 2/25/16.
//  Copyright © 2016 Stefan Burettea. All rights reserved.
//

import UIKit

public protocol CSFadeable {
    var alpha: CGFloat {get set}

    mutating func fade(duration: NSTimeInterval, delay: NSTimeInterval, completion: ((Bool)-> Void)?)
    
//    mutating func fadeIn(duration: NSTimeInterval, delay: NSTimeInterval, completion: (Bool)-> Void)
//    mutating func fadeOut(duration: NSTimeInterval, delay: NSTimeInterval, completion: (Bool)-> Void)
}

public extension CSFadeable {
    
    public mutating func fade(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.0, completion: ((Bool)-> Void)? = nil) {
        UIView.animateWithDuration(duration, delay: delay, options: [.CurveEaseOut, .Autoreverse, .Repeat], animations: { () in
            self.alpha = 1.0
            }, completion: { (finished) in
                self.alpha = 0.0
                completion?(finished)
        })
    }
    
//    public mutating func fadeIn(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.0, completion: (Bool)-> Void) {
//        UIView.animateWithDuration(duration, delay: delay, options: [.CurveEaseOut], animations: { () in
//            self.alpha = 1.0
//            }, completion: { (finished) in
//                completion(finished)
//            })
//    }
//    
//    public mutating func fadeOut(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.0, completion: (Bool)-> Void) {
//        UIView.animateWithDuration(duration, delay: delay, options: .CurveEaseOut, animations: { () in
//            self.alpha = 0.0
//            }, completion: completion)
//    }
}

extension UIView: CSFadeable {}