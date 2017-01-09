//
//  CSPulsatingButton.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 2/23/16.
//  Copyright © 2016 Stefan Burettea. All rights reserved.
//

import UIKit


typealias AnimationCompletionBlock = () -> ()
private class AnimationCompletionBlockHolder : NSObject {
    var block : AnimationCompletionBlock! = nil
}

@IBDesignable class CSPulsatingAnimationButtonItem: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 22.0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0            
        }
    }
    
    @IBInspectable var scaleAnimationToValue: CGFloat = 1.0
    @IBInspectable var animationRepeatCount: Float = 20.0
    @IBInspectable var completionAnimationKey: String = ""
    @IBInspectable var fadeAnimationFromValue: Float = 0.5
    
    fileprivate var scaleAnimation: CABasicAnimation!
    fileprivate var fadeAnimation: CABasicAnimation!

    fileprivate class CSFadeAnimation: CABasicAnimation {
        
        convenience init(fromValue: Any? = 0.5, duration: CFTimeInterval = 1.3, repeatCount: Float = 20.0, delegate: UIView?) {
            self.init()
            self.init(keyPath: "opacity")
            
            self.fromValue = fromValue
            self.toValue = NSNumber(value: 0.0 as Float)
            self.duration = duration
            self.repeatCount = repeatCount
        }
    }
    
    fileprivate class CSScaleAnimation: CABasicAnimation {
        
        convenience init(toValue: AnyObject?, duration: CFTimeInterval = 1.3, repeatCount: Float = 20.0) {
            self.init()
            self.init(keyPath: "transform.scale")
            
            self.fromValue = NSNumber(value: 0.2 as Float)
            self.toValue = toValue
            self.duration = duration
            self.repeatCount = repeatCount
            self.autoreverses = false
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureForAnimation() {
        let holder = AnimationCompletionBlockHolder()
        let completion = { self.isHidden = true }
        holder.block = completion
        
        scaleAnimation = CSScaleAnimation(toValue: scaleAnimationToValue as AnyObject?, repeatCount: animationRepeatCount)
        fadeAnimation = CSFadeAnimation(repeatCount: animationRepeatCount, delegate: self.superview)
        
        fadeAnimation.setValue(holder, forKey: completionAnimationKey)
        
        self.layer.setValue(NSNumber(value: 0.2 as Float), forKeyPath: "transform.scale")
        self.layer.add(fadeAnimation, forKey: "opacity")
        self.layer.add(scaleAnimation, forKey: nil)
        self.isHidden = false
    }
    
    func animateWithBlocks() {
        self.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        UIView.animate(withDuration: 1.3, delay: 0, options: [.repeat], animations: { () -> Void in
            UIView.setAnimationRepeatCount(self.animationRepeatCount)
            self.isHidden = false
            self.alpha = 0.0
            self.transform = CGAffineTransform(scaleX: self.scaleAnimationToValue, y: self.scaleAnimationToValue)
        }, completion: { (finished) -> Void in
            if finished {
                self.isHidden = true
            }
        })
    }
}

@IBDesignable class CSPulsatingButton: UIView {
    
    @IBOutlet fileprivate weak var contentView: UIView?
    
    fileprivate var smallButtonScaleAnimation: CABasicAnimation!
    fileprivate var smallButtonFadeAnimation: CABasicAnimation!

    fileprivate var mediumButtonScaleAnimation: CABasicAnimation!
    fileprivate var mediumButtonFadeAnimation: CABasicAnimation!

    fileprivate var largeButtonScaleAnimation: CABasicAnimation!
    fileprivate var largeButtonFadeAnimation: CABasicAnimation!
    
    @IBOutlet fileprivate weak var largeButton: CSPulsatingAnimationButtonItem!
    @IBOutlet fileprivate weak var mediumButton: CSPulsatingAnimationButtonItem!
    @IBOutlet fileprivate weak var smallButton: CSPulsatingAnimationButtonItem!
    @IBOutlet fileprivate weak var pulsatingButton: UIButton!
    @IBOutlet fileprivate var animationButtonItems: [CSPulsatingAnimationButtonItem]!
    
    @IBInspectable fileprivate var xibName: String?
    @IBInspectable internal var color: UIColor?
    
    weak var delegate: CSPulsatingButtonDelegate?

    override func awakeFromNib() {
        loadFromXib()
        
        setup()
    }
    
    func loadFromXib() -> UIView? {
        guard let dotIndex = NSStringFromClass(type(of: self)).range(of: ".") else { return nil }
        
        let stringFromClass = NSStringFromClass(type(of: self))
        let index = stringFromClass.index(dotIndex.lowerBound, offsetBy:stringFromClass[dotIndex].characters.count)
        let className = stringFromClass.substring(from: index)
        guard let xib = Bundle.main.loadNibNamed(className, owner: self, options: nil),
              let views = xib as? [UIView], views.count > 0 else { return nil }
        
        guard let view = xib[0] as? UIView else { return nil }
        self.addSubview(view)
        
        return views[0]
    }
    
    
    fileprivate func setup() {
        largeButton.isHidden = true
        mediumButton.isHidden = true
        smallButton.isHidden = true
        pulsatingButton.backgroundColor = color ?? UIColor.clear
        animationButtonItems.forEach{ $0.backgroundColor = color ?? UIColor.clear }
        
        pulsatingButton.addTarget(self, action: #selector(didPressPulsatingButton), for: .touchUpInside)
    }

    func animate() {
        (self.animationButtonItems as NSArray).value(forKey: "configureForAnimation")
    }
    
    internal func animationDidStop(_ animation: CAAnimation, finished flag: Bool) {
        let completion = animationButtonItems.flatMap { animation.value(forKey: $0.completionAnimationKey) as? AnimationCompletionBlockHolder }
        guard completion.count > 0 else { return }
        
        completion[0].block()
    }
    
    @objc fileprivate func didPressPulsatingButton() {
        self.delegate?.didPressPulsatingButton(self.pulsatingButton)
    }
}

// MARK: Animate the control

extension CSPulsatingButton {
    func dropAnimation(view: UIView) {
        animate(view: view, constantValue: 0.0, completion: nil)
    }
    
    typealias CSPulsatingButtonCompletion = ((CSPulsatingButton?) -> Void)
    func dropAnimation(view: UIView, completion: CSPulsatingButtonCompletion?) {
        animate(view: view, constantValue: 0.0, completion: completion)
    }

    func liftAnimation(view: UIView) {
        animate(view: view, constantValue: -100.0, completion: nil)
    }
    
    func liftAnimation(view: UIView, completion: CSPulsatingButtonCompletion?) {
        animate(view: view, constantValue: -100.0, completion: completion)
    }
    
    fileprivate func animate(view: UIView, constantValue: CGFloat, completion: CSPulsatingButtonCompletion?) {
        guard let superview = self.superview else { return }
        
        for constraint in superview.constraints {
            if constraint.firstItem as? NSObject == self && constraint.firstAttribute == .top {
                constraint.constant = constantValue
                break
            }
        }
        
        UIView.animate( withDuration: 1.0, delay: 0.0,
                                    usingSpringWithDamping: 0.4, initialSpringVelocity: 10.0,
                                    options: .curveEaseIn,
                                    animations: {
                                        view.layoutIfNeeded()
                                    },
                                    completion: { [weak self] (complete) in
                                        completion?(self)
                                        return
                                  })
    }
}

protocol CSPulsatingButtonDelegate: NSObjectProtocol {
    func didPressPulsatingButton(_ sender: UIButton!)
}
