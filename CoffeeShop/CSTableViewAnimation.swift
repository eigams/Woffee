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
        self.duration = 1.5
        self.delay = 0.05
        self.dampingRatio = 0.0
        self.velocity = 0.0
    }
    
    private func hideCell(cell: UITableViewCell) {
        cell.transform = CGAffineTransformMakeTranslation(0, owner.bounds.size.height);
        cell.alpha = 0;
    }

    private func showCell(cell: UITableViewCell) {
        guard let row = owner.indexPathForCell(cell)?.row else { return }
        
        UIView.animateWithDuration(1.5, delay: 0.05 * Double(row), usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity, options: [], animations: {
            cell.transform = CGAffineTransformMakeTranslation(0, 0);
            cell.alpha = 1.0
            }, completion: nil)
    }
    
    func play() {
        self.owner.reloadData()

        _ = owner.visibleCells.map { hideCell($0) }
        _ = owner.visibleCells.map { showCell($0) }
    }
}
