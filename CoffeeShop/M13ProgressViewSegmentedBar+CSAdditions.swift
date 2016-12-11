//
//  M13ProgressViewSegmentedBar+CSAdditions.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 3/17/16.
//  Copyright © 2016 Stefan Burettea. All rights reserved.
//

import Foundation


extension M13ProgressViewSegmentedBar {
    
    func configure() {
        self.progressDirection = M13ProgressViewSegmentedBarProgressDirectionLeftToRight
        self.indeterminate = true
        self.segmentShape = M13ProgressViewSegmentedBarSegmentShapeCircle
        self.primaryColor = UIColor.whiteColor()
        self.secondaryColor = UIColor.grayColor()
    }
    
    func animateInView(view: UIView, completion: (() -> Void)?) {
        guard let superview = self.superview else { return }
        
        for constraint in superview.constraints {
            guard constraint.secondItem as? NSObject == self && constraint.firstAttribute == .CenterY else { continue }
            
            superview.removeConstraint(constraint)
            
            let newConstraint = NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: superview,
                                                   attribute: .Top, multiplier: 1, constant: 35)
            newConstraint.active = true
            break
        }
        
        UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 3.0, options: .CurveEaseIn,
            animations: {
                view.layoutIfNeeded()
            },
            completion: { (complete: Bool) in
                completion?()
        })
    }
}