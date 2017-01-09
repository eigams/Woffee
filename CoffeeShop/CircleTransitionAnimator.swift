//
//  CircleTransitionAnimator.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 5/2/15.
//  Copyright (c) 2015 Stefan Burettea. All rights reserved.
//

import UIKit

class CircleTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning, CAAnimationDelegate {

    weak var transitionContext: UIViewControllerContextTransitioning?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        
        let containerView = transitionContext.containerView
        let fromShopsListViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? ShopsListViewController
        let fromShopsMapViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? ShopsMapViewController
        let button = (nil == fromShopsListViewController) ? fromShopsMapViewController?.actionButton : fromShopsListViewController?.actionButton
        
        let toShopsMapViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? ShopsMapViewController
        let toShopsListViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? ShopsListViewController
        
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
        let circleMaskPathInitial = UIBezierPath(ovalIn: button!.frame)
        let extremePoint = CGPoint(x: button!.center.x - 0, y: button!.center.y - toViewController.view.bounds.height)
        let radius = sqrt((extremePoint.x*extremePoint.x) + (extremePoint.y*extremePoint.y))
        let circleMaskPathFinal = UIBezierPath(ovalIn: button!.frame.insetBy(dx: -radius, dy: -radius))
        
        //5
        let maskLayer = CAShapeLayer()
        maskLayer.path = circleMaskPathFinal.cgPath
        toViewController.view.layer.mask = maskLayer
        
        //6
        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.fromValue = circleMaskPathInitial.cgPath
        maskLayerAnimation.toValue = circleMaskPathFinal.cgPath
        maskLayerAnimation.duration = self.transitionDuration(using: transitionContext)
        maskLayerAnimation.delegate = self
        maskLayer.add(maskLayerAnimation, forKey: "path")
        
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        transitionContext?.completeTransition(!self.transitionContext!.transitionWasCancelled)
        transitionContext?.viewController(forKey: UITransitionContextViewControllerKey.from)?.view.layer.mask = nil
    }
    
}
