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
    
    @IBInspectable var duration: TimeInterval
    @IBInspectable var delay: TimeInterval
    @IBInspectable var dampingRatio: CGFloat
    @IBInspectable var velocity: CGFloat

    override required init() {
        self.duration = 1.5
        self.delay = 0.05
        self.dampingRatio = 0.0
        self.velocity = 0.0
    }
    
    fileprivate func hideCell(_ cell: UITableViewCell) {
        cell.transform = CGAffineTransform(translationX: 0, y: owner.bounds.size.height);
        cell.alpha = 0;
    }

    fileprivate func showCell(_ cell: UITableViewCell) {
        guard let row = owner.indexPath(for: cell)?.row else { return }
        
        UIView.animate(withDuration: 1.5, delay: 0.05 * Double(row), usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity, options: [], animations: {
            cell.transform = CGAffineTransform(translationX: 0, y: 0);
            cell.alpha = 1.0
            }, completion: nil)
    }
    
    func play() {
        self.owner.reloadData()

        _ = owner.visibleCells.map { hideCell($0) }
        _ = owner.visibleCells.map { showCell($0) }
    }
}
