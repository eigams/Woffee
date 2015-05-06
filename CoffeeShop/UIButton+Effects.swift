//
//  UIButton+Effects.swift
//  PulsatingButton
//
//  Created by Stefan Buretea on 4/30/15.
//  Copyright (c) 2015 Stefan Buretea. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {

    typealias AnimationCompletionBlock = () -> ()
    class CompletionBlockHolder : NSObject {
        var block : AnimationCompletionBlock! = nil
    }
    
    func addPulsatingEffect() {
        
        let largeHelperButton = self.createHelperButton()
        let middleHelperButton = self.createHelperButton()
        let smallHelperButton = self.createHelperButton()
        
        var largeHelperFadeOutAnimation = createFadeOutAnimation(NSNumber(float: 0.5), duration: 1.3, repeatCount: 5)
        let completion = { largeHelperButton.hidden = true }
        let holder = CompletionBlockHolder()
        holder.block = completion
        
        largeHelperFadeOutAnimation.setValue(holder, forKey: "completion")
        largeHelperButton.layer.addAnimation(largeHelperFadeOutAnimation, forKey: "opacity")
        
        largeHelperButton.layer.setValue(NSNumber(float: 0.2), forKeyPath: "transform.scale")
        largeHelperButton.layer.addAnimation(createScaleAnimation(NSNumber(float: 0.8), duration: 1.3, repeatCount: 5), forKey: nil)

        middleHelperButton.layer.addAnimation(createFadeOutAnimation(NSNumber(float: 0.5), duration: 1.3, repeatCount: FLT_MAX), forKey: nil)
        middleHelperButton.layer.addAnimation(createScaleAnimation(NSNumber(float: 0.5), duration: 1.3, repeatCount: FLT_MAX), forKey: nil)

        smallHelperButton.layer.addAnimation(createFadeOutAnimation(NSNumber(float: 0.5), duration: 1.3, repeatCount: FLT_MAX), forKey: nil)
        smallHelperButton.layer.addAnimation(createScaleAnimation(NSNumber(float: 0.3), duration: 1.3, repeatCount: FLT_MAX), forKey: nil)
    }
    
    private func createHelperButton() -> UIButton {
        
        let buttonWidth:CGFloat = 44.0
        let buttonHeight:CGFloat = 44.0
        
        let button = UIButton(frame: CGRectMake(self.frame.origin.x, self.frame.origin.y, buttonWidth, buttonHeight))
        button.backgroundColor = UIColor.blackColor()
        button.layer.cornerRadius = 22.0
        button.userInteractionEnabled = false
        
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.superview?.addSubview(button)
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: buttonHeight))
        constraints.append(NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: buttonWidth))
        constraints.append(NSLayoutConstraint(item: button, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: button, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        
        self.superview?.addConstraints(constraints)
        
        return button
    }
    
    private func createFadeOutAnimation(fromValue: AnyObject!, duration: CFTimeInterval, repeatCount: Float) -> CABasicAnimation {
    
        let animation = CABasicAnimation(keyPath: "opacity")
        
        animation.fromValue = fromValue
        animation.toValue = NSNumber(float: 0.0)
        animation.duration = duration
        animation.repeatCount = repeatCount
        animation.delegate = self
        
        return animation
    }

    private func createScaleAnimation(toValue: AnyObject!, duration: CFTimeInterval, repeatCount: Float) -> CABasicAnimation {
    
        let animation = CABasicAnimation(keyPath: "transform.scale")
        
        animation.fromValue = NSNumber(float: 0.2)
        animation.toValue = toValue
        animation.duration = duration
        animation.repeatCount = repeatCount
        animation.autoreverses = false
        
        return animation
    }
    
    override public func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        let completion = anim.valueForKey("completion") as! CompletionBlockHolder
        completion.block()
    }
}
