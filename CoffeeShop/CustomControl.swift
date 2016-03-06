//
//  CustomControl.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 3/1/16.
//  Copyright © 2016 Stefan Burettea. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class CustomControl: UIView {
    
    @IBInspectable var xibName: String?
    
    override func awakeFromNib() {
        guard let xibName = xibName,
              let xib = NSBundle.mainBundle().loadNibNamed(xibName, owner: self, options: nil) else { return }
        
        guard let views = xib as? [UIView] where views.count > 0 else { return }
        
        self.addSubview(xib[0] as! UIView)
    }
}