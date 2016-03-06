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
        
        let largeHelperFadeOutAnimation = fadeOutAnimation(NSNumber(float: 0.5), duration: 1.3, repeatCount: 10)
        var completion = { largeHelperButton.removeFromSuperview() }
        let holder = CompletionBlockHolder()
        holder.block = completion
        
        largeHelperFadeOutAnimation.setValue(holder, forKey: "completionLarge")
        largeHelperButton.layer.addAnimation(largeHelperFadeOutAnimation, forKey: "opacity")
        
        largeHelperButton.layer.setValue(NSNumber(float: 0.2), forKeyPath: "transform.scale")
        largeHelperButton.layer.addAnimation(scaleAnimation(NSNumber(float: 0.8), duration: 1.3, repeatCount: 10), forKey: nil)

        let middleHelperFadeOutAnimation = fadeOutAnimation(NSNumber(float: 0.5), duration: 1.3, repeatCount: 20)
        completion = { middleHelperButton.removeFromSuperview() }
        holder.block = completion

        middleHelperFadeOutAnimation.setValue(holder, forKey: "completionMiddle")
        middleHelperButton.layer.setValue(NSNumber(float: 0.2), forKeyPath: "transform.scale")
        middleHelperButton.layer.addAnimation(middleHelperFadeOutAnimation, forKey: nil)
        middleHelperButton.layer.addAnimation(scaleAnimation(NSNumber(float: 0.5), duration: 1.3, repeatCount: 20), forKey: nil)

        let smallHelperFadeOutAnimation = fadeOutAnimation(NSNumber(float: 0.5), duration: 1.3, repeatCount: 20)
        completion = { largeHelperButton.removeFromSuperview() }
        holder.block = completion
        
        smallHelperFadeOutAnimation.setValue(holder, forKey: "completionSmall")
        smallHelperButton.layer.setValue(NSNumber(float: 0.2), forKeyPath: "transform.scale")
        smallHelperButton.layer.addAnimation(smallHelperFadeOutAnimation, forKey: nil)
        smallHelperButton.layer.addAnimation(scaleAnimation(NSNumber(float: 0.3), duration: 1.3, repeatCount: 20), forKey: nil)
    }
    
    private func createHelperButton() -> UIButton {
        
        let buttonWidth:CGFloat = 44.0
        let buttonHeight:CGFloat = 44.0
        
        let button = UIButton(frame: CGRectMake(self.frame.origin.x, self.frame.origin.y, buttonWidth, buttonHeight))
        button.backgroundColor = self.backgroundColor
        button.layer.cornerRadius = 22.0
        button.userInteractionEnabled = false
        
        button.translatesAutoresizingMaskIntoConstraints = false
        self.superview?.addSubview(button)
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: buttonHeight))
        constraints.append(NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: buttonWidth))
        constraints.append(NSLayoutConstraint(item: button, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: button, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        
        self.superview?.addConstraints(constraints)
        
        return button
    }
    
    private func fadeOutAnimation(fromValue: AnyObject!, duration: CFTimeInterval, repeatCount: Float) -> CABasicAnimation {
    
        let animation = CABasicAnimation(keyPath: "opacity")
        
        animation.fromValue = fromValue
        animation.toValue = NSNumber(float: 0.0)
        animation.duration = duration
        animation.repeatCount = repeatCount
        animation.delegate = self
        
        return animation
    }

    private func scaleAnimation(toValue: AnyObject!, duration: CFTimeInterval, repeatCount: Float) -> CABasicAnimation {
    
        let animation = CABasicAnimation(keyPath: "transform.scale")
        
        animation.fromValue = NSNumber(float: 0.2)
        animation.toValue = toValue
        animation.duration = duration
        animation.repeatCount = repeatCount
        animation.autoreverses = false
        
        return animation
    }
    
    override public func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        let animations = ["completionLarge", "completionMiddle", "completionSmall"]
        
        var completion: CompletionBlockHolder?
        for animation in animations {
            completion = anim.valueForKey(animation) as? CompletionBlockHolder
            if completion != nil { break }
        }
        
        completion?.block()
    }
}
