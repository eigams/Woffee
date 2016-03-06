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
    
    @IBInspectable var scaleAnimationToValue: Float = 1.0
    @IBInspectable var animationRepeatCount: Float = 20.0
    @IBInspectable var completionAnimationKey: String? = ""
    @IBInspectable var fadeAnimationFromValue: Float = 0.5
    
    private var scaleAnimation: CABasicAnimation!
    private var fadeAnimation: CABasicAnimation!

    private class CSFadeAnimation: CABasicAnimation {
        
        convenience init(fromValue: AnyObject? = 0.5, duration: CFTimeInterval = 1.3, repeatCount: Float = 20.0, delegate: UIView?) {
            self.init()
            self.init(keyPath: "opacity")
            
            self.fromValue = fromValue
            self.toValue = NSNumber(float: 0.0)
            self.duration = duration
            self.repeatCount = repeatCount
            self.delegate = delegate
        }
    }
    
    private class CSScaleAnimation: CABasicAnimation {
        
        convenience init(toValue: AnyObject?, duration: CFTimeInterval = 1.3, repeatCount: Float = 20.0) {
            self.init()
            self.init(keyPath: "transform.scale")
            
            self.fromValue = NSNumber(float: 0.2)
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
        let completion = { self.hidden = true }
        holder.block = completion
        
        scaleAnimation = CSScaleAnimation(toValue: scaleAnimationToValue, repeatCount: animationRepeatCount)
        fadeAnimation = CSFadeAnimation(repeatCount: animationRepeatCount, delegate: self.superview)
        
        if let completionAnimationKey = self.completionAnimationKey {
            fadeAnimation.setValue(holder, forKey: completionAnimationKey)
        }
        
        self.layer.setValue(NSNumber(float: 0.2), forKeyPath: "transform.scale")
        self.layer.addAnimation(fadeAnimation, forKey: "opacity")
        self.layer.addAnimation(scaleAnimation, forKey: nil)
        self.hidden = false
    }
}

@IBDesignable class CSPulsatingButton: UIView {
    
    @IBOutlet private weak var contentView: UIView?
    
    private var smallButtonScaleAnimation: CABasicAnimation!
    private var smallButtonFadeAnimation: CABasicAnimation!

    private var mediumButtonScaleAnimation: CABasicAnimation!
    private var mediumButtonFadeAnimation: CABasicAnimation!

    private var largeButtonScaleAnimation: CABasicAnimation!
    private var largeButtonFadeAnimation: CABasicAnimation!
    
    @IBOutlet private weak var largeButton: CSPulsatingAnimationButtonItem!
    @IBOutlet private weak var mediumButton: CSPulsatingAnimationButtonItem!
    @IBOutlet private weak var smallButton: CSPulsatingAnimationButtonItem!
    @IBOutlet private weak var pulsatingButton: UIButton!
    @IBOutlet private var animationButtonItems: [CSPulsatingAnimationButtonItem]!
    
    @IBInspectable private var xibName: String?
    @IBInspectable internal var color: UIColor?
    
    weak var delegate: CSPulsatingButtonDelegate?

    override func awakeFromNib() {
        loadFromXib()
        
        setup()
    }
    
    func loadFromXib() -> UIView? {
        guard let dotIndex = NSStringFromClass(self.dynamicType).rangeOfString(".") else { return nil }
        
        let className = NSStringFromClass(self.dynamicType).substringFromIndex(dotIndex.startIndex.advancedBy(dotIndex.count))
        guard let xib = NSBundle.mainBundle().loadNibNamed(className, owner: self, options: nil),
            let views = xib as? [UIView] where views.count > 0 else { return nil }
        
        self.addSubview(xib[0] as! UIView)
        
        return views[0]
    }
    
    
    private func setup() {
        largeButton.hidden = true
        mediumButton.hidden = true
        smallButton.hidden = true
        pulsatingButton.backgroundColor = color!
        for button in animationButtonItems {
            button.backgroundColor = color!
        }
        
        pulsatingButton.addTarget(self, action: "didPressPulsatingButton", forControlEvents: .TouchUpInside)
    }

    func animate() {
        largeButton.configureForAnimation()
        mediumButton.configureForAnimation()
        smallButton.configureForAnimation()
    }
    
    override internal func animationDidStop(animation: CAAnimation, finished flag: Bool) {
        
        let completion = animationButtonItems.map { animation.valueForKey($0.completionAnimationKey!) as? AnimationCompletionBlockHolder }.filter { $0 != nil }
        guard completion.count > 0 else { return }
        
        completion[0]!.block()
    }
    
    private func didPressPulsatingButton() {
        self.delegate?.didPressPulsatingButton(self.pulsatingButton)
    }
}

// MARK: Animate the control

extension CSPulsatingButton {
    func dropAnimationInView(view: UIView) {
        animateInView(view, constantValue: 0.0, completionBlock: nil)
    }
    
    func dropAnimationInView(view: UIView, completionBlock: ((pulsatingButton: CSPulsatingButton?) -> ())?) {
        animateInView(view, constantValue: 0.0, completionBlock: completionBlock)
    }

    func liftAnimationInView(view: UIView) {
        animateInView(view, constantValue: -100.0, completionBlock: nil)
    }
    
    func liftAnimationInView(view: UIView, completionBlock: ((pulsatingButton: CSPulsatingButton?) -> ())?) {
        animateInView(view, constantValue: -100.0, completionBlock: completionBlock)
    }
    
    private func animateInView(view: UIView, constantValue: CGFloat, completionBlock: ((pulsatingButton: CSPulsatingButton?) -> ())?) {
        guard let superview = self.superview else { return }
        
        for constraint in superview.constraints {
            if constraint.firstItem as? NSObject == self && constraint.firstAttribute == .Top {
                constraint.constant = constantValue
                break
            }
        }
        
        UIView.animateWithDuration( 1.0, delay: 0.0,
                                    usingSpringWithDamping: 0.4, initialSpringVelocity: 10.0,
                                    options: .CurveEaseIn,
                                    animations: {
                                        view.layoutIfNeeded()
                                    },
                                    completion: { [weak self] (complete) in
                                        completionBlock?(pulsatingButton: self)
                                        return
                                  })
    }
}

protocol CSPulsatingButtonDelegate: NSObjectProtocol {
    func didPressPulsatingButton(sender: UIButton!)
}
