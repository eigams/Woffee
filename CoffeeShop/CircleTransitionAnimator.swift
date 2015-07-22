//
//  CircleTransitionAnimator.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 5/2/15.
//  Copyright (c) 2015 Stefan Burettea. All rights reserved.
//

import UIKit

class CircleTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    weak var transitionContext: UIViewControllerContextTransitioning?
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        
        var containerView = transitionContext.containerView()
        var fromShopsListViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as? ShopsListViewController
        var fromShopsMapViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as? ShopsMapViewController
        var button = (nil == fromShopsListViewController) ? fromShopsMapViewController?.actionButton : fromShopsListViewController?.actionButton
        
        var toShopsMapViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as? ShopsMapViewController
        var toShopsListViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as? ShopsListViewController
        
        var toViewController: UIViewController! = nil
        if let tvc = toShopsMapViewController {
            toViewController = tvc
            containerView.addSubview(toViewController.view)
        }
        else {
            if let tvc = toShopsListViewController {
                containerView.addSubview(tvc.view)
                toViewController = toShopsListViewController
            }
        }
        
        //4
        var circleMaskPathInitial = UIBezierPath(ovalInRect: button!.frame)
        var extremePoint = CGPoint(x: button!.center.x - 0, y: button!.center.y - CGRectGetHeight(toViewController.view.bounds))
        var radius = sqrt((extremePoint.x*extremePoint.x) + (extremePoint.y*extremePoint.y))
        var circleMaskPathFinal = UIBezierPath(ovalInRect: CGRectInset(button!.frame, -radius, -radius))
        
        //5
        var maskLayer = CAShapeLayer()
        maskLayer.path = circleMaskPathFinal.CGPath
        toViewController.view.layer.mask = maskLayer
        
        //6
        var maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.fromValue = circleMaskPathInitial.CGPath
        maskLayerAnimation.toValue = circleMaskPathFinal.CGPath
        maskLayerAnimation.duration = self.transitionDuration(transitionContext)
        maskLayerAnimation.delegate = self
        maskLayer.addAnimation(maskLayerAnimation, forKey: "path")
        
    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        self.transitionContext?.completeTransition(!self.transitionContext!.transitionWasCancelled())
        self.transitionContext?.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view.layer.mask = nil
    }
    
}
