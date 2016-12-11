//
//  UIRefreshControl+CSAdditions.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 3/17/16.
//  Copyright © 2016 Stefan Burettea. All rights reserved.
//

import Foundation

extension UIRefreshControl {
    func setupInTableView(parentTableView: UITableView, viewController: UIViewController, selector: Selector) {
        self.backgroundColor = UIColor.clearColor()
        self.tintColor = UIColor.whiteColor()
        self.addTarget(viewController, action: selector, forControlEvents: UIControlEvents.ValueChanged)
        
        parentTableView.insertSubview(self, atIndex: 0)
    }
}