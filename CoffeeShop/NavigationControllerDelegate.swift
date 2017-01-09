//
//  NavigationControllerDelegate.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 5/2/15.
//  Copyright (c) 2015 Stefan Burettea. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate {

    @IBOutlet weak var navigationController: UINavigationController?
    var interactionController: UIPercentDrivenInteractiveTransition?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(NavigationControllerDelegate.panned(_:)))
        self.navigationController!.view.addGestureRecognizer(panGesture)
    }

    //1
    @IBAction func panned(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            self.interactionController = UIPercentDrivenInteractiveTransition()
            if self.navigationController?.viewControllers.count > 1 {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.navigationController?.topViewController!.performSegue(withIdentifier: "PushSegue", sender: nil)
            }
            
            //2
        case .changed:
            let translation = gestureRecognizer.translation(in: self.navigationController!.view)
            let completionProgress = -translation.x/self.navigationController!.view.bounds.width
            self.interactionController?.update(completionProgress)
            
            //3
        case .ended:
            if (gestureRecognizer.velocity(in: self.navigationController!.view).x < 0) {
                self.interactionController?.finish()
            } else {
                self.interactionController?.cancel()
            }
            self.interactionController = nil
            
            //4
        default:
            self.interactionController?.cancel()
            self.interactionController = nil
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CircleTransitionAnimator()
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactionController
    }
    
}
