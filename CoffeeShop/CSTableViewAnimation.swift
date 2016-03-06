//
//  CSTableAnimation.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 2/19/16.
//  Copyright © 2016 Stefan Burettea. All rights reserved.
//

import UIKit

@IBDesignable class CSTableViewAnimation: NSObject {
    @IBOutlet weak var owner: UITableView!
    
    @IBInspectable var duration: NSTimeInterval
    @IBInspectable var delay: NSTimeInterval
    @IBInspectable var dampingRatio: CGFloat
    @IBInspectable var velocity: CGFloat

    override required init() {
        
        duration = 1.5
        delay = 0.05
        dampingRatio = 0.0
        velocity = 0.0
    }
    
    func play() {
        self.owner.reloadData()
        
        self.owner.visibleCells.forEach{ cell in
            cell.transform = CGAffineTransformMakeTranslation(0, self.owner.bounds.size.height);
            cell.alpha = 0;
        }
        
        var index = 0
        self.owner.visibleCells.forEach{ cell in
            UIView.animateWithDuration(1.5, delay: 0.05 * Double(index), usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity, options: [], animations: {
                cell.transform = CGAffineTransformMakeTranslation(0, 0);
                cell.alpha = 1.0
                }, completion: nil)
            
            index++
        }        
    }
}
