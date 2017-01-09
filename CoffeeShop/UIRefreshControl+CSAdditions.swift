//
//  UIRefreshControl+CSAdditions.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 3/17/16.
//  Copyright © 2016 Stefan Burettea. All rights reserved.
//

import Foundation

extension UIRefreshControl {
    func setupInTableView(_ parentTableView: UITableView, viewController: UIViewController, selector: Selector) {
        self.backgroundColor = UIColor.clear
        self.tintColor = UIColor.white
        self.addTarget(viewController, action: selector, for: UIControlEvents.valueChanged)
        
        parentTableView.insertSubview(self, at: 0)
    }
}
