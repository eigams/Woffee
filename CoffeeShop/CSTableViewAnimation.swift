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
    
    private func hideCell(cell: UITableViewCell) {
        cell.transform = CGAffineTransformMakeTranslation(0, self.owner.bounds.size.height);
        cell.alpha = 0;
    }

    private func showCell(cell: UITableViewCell) {
        UIView.animateWithDuration(1.5, delay: 0.05 * Double((self.owner.indexPathForCell(cell)?.row)!), usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity, options: [], animations: {
            cell.transform = CGAffineTransformMakeTranslation(0, 0);
            cell.alpha = 1.0
            }, completion: nil)
    }
    
    func play() {
        self.owner.reloadData()

        _ = self.owner.visibleCells.map { hideCell($0) }
        _ = self.owner.visibleCells.map { showCell($0) }
    }
}
