//
//  RippleAnimation.swift
//  RippleAnimationView
//
//  Created by Motoki on 2015/12/22.
//  Copyright (c) 2015 MotokiNarita. All rights reserved.
//

import UIKit

private let DefaultScalingAnimateDuration: TimeInterval = 1.0
private let DefaultAlphaAnimateDuration: TimeInterval   = 0.2
private let DefaultScale: CGFloat = 100
private var tahSucceededKey: UInt8 = 0


// MARK: - UIView - Ripple Animation Extension
public extension UIView {
    
    fileprivate var rippleDefaultStartRect: CGRect {
        return CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }
    
    public struct RippleConfiguration {
        var color: UIColor
        var clipsToBounds = false
        var startPoint: CGPoint = CGPoint.zero
        var scale: CGFloat = DefaultScale
        var scaleAnimateDuration = DefaultScalingAnimateDuration
        var fadeAnimateDuration = DefaultAlphaAnimateDuration
        var completionHandler: (() -> Void)? = nil
        var initialOpacity: CGFloat = 1
        var endTAHOpacity: CGFloat = 0
        var tahDecisionTime: TimeInterval = 0
        var tahDecisionOpacity: CGFloat = 0
        var endOpacity: CGFloat = 0
        var tahEnabled = false
        
        public init(color: UIColor, scale: CGFloat = 1, clipsToBounds: Bool, startPoint: CGPoint, scaleAnimateDuration: TimeInterval, fadeAnimateDuration: TimeInterval, initialOpacity: CGFloat, endOpacity: CGFloat, endTAHOpacity: CGFloat, tahDecisionTime: TimeInterval, tahDecisionOpacity: CGFloat, tahEnabled: Bool) {
            self.color = color
            self.scale = scale
            self.clipsToBounds = clipsToBounds
            self.startPoint = startPoint
            self.scaleAnimateDuration = scaleAnimateDuration
            self.fadeAnimateDuration = fadeAnimateDuration
            self.initialOpacity = initialOpacity
            self.endOpacity = endOpacity
            self.tahDecisionTime = tahDecisionTime
            self.endTAHOpacity = endTAHOpacity
            self.tahDecisionOpacity = tahDecisionOpacity
            self.tahEnabled = tahEnabled
        }
    }
    
    public func rippleAnimate(with config: UIView.RippleConfiguration, completionHandler: ((_ tahCompleted: Bool) -> Void)?) -> UIView {
        
        clipsToBounds = config.clipsToBounds
        
        return rippleAnimate(with: config.color, scale: config.scale, startPoint: config.startPoint, initialOpacity: config.initialOpacity, endOpacity: config.endOpacity, scaleAnimateDuration: config.scaleAnimateDuration, fadeAnimateDuration: config.fadeAnimateDuration, endTAHOpacity: config.endTAHOpacity, tahDecisionTime: config.tahDecisionTime, tahDecisionOpacity: config.tahDecisionOpacity, tahEnabled: config.tahEnabled, completionHandler: completionHandler)
    }
    
    var TAHSucceeded: Bool! {
        get {
            return (objc_getAssociatedObject(self, &tahSucceededKey) as? Bool) ?? true
        }
        set(newValue) {
            objc_setAssociatedObject(self, &tahSucceededKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    // swiftlint:disable function_parameter_count
    private func rippleAnimate(with color: UIColor, scale: CGFloat, startPoint: CGPoint, initialOpacity: CGFloat, endOpacity: CGFloat, scaleAnimateDuration: TimeInterval, fadeAnimateDuration: TimeInterval, endTAHOpacity: CGFloat, tahDecisionTime: TimeInterval, tahDecisionOpacity: CGFloat, tahEnabled: Bool, completionHandler: ((_ tahCompleted: Bool) -> Void)?) -> UIView {
        
        let startFrame = CGRect(origin: startPoint, size: CGSize(width: 1, height: 1))
        let rippleView = RippleView(frame: startFrame, backgroundColor: color)
        addSubview(rippleView)
        rippleView.alpha = initialOpacity
        
        let scaleAnimation = {
            let x1 = rippleView.frame.origin.x
            let x2 = self.frame.width - x1
            let y1 = rippleView.frame.origin.y
            let y2 = self.frame.height - y1
            
            let widthRatio = 2 * scale * sqrt(2) * max(max(x1, x2), max(y1, y2)) / rippleView.frame.width
            
            rippleView.transform = CGAffineTransform(scaleX: widthRatio, y: widthRatio)
        }
        
        let tahDecisionAnimation = { rippleView.alpha = tahDecisionOpacity }
        let tahSucceededAnimation = { rippleView.alpha = endTAHOpacity }
        let tahFailedAnimation = { rippleView.alpha = endOpacity }
        
        // start scale animation
        UIView.animate(withDuration: scaleAnimateDuration, animations: scaleAnimation, completion: { completion in
            guard completion else { return }
            if !self.TAHSucceeded
            {
                rippleView.removeFromSuperview()
            }
            completionHandler?(self.TAHSucceeded)
        })
        
        // start fade animation
        UIView.animate(withDuration: tahDecisionTime, animations: tahDecisionAnimation, completion: { _ in
            if tahEnabled
            {
                if self.TAHSucceeded
                {
                    UIView.animate(withDuration: fadeAnimateDuration - tahDecisionTime, animations: tahSucceededAnimation, completion: { _ in
                    })
                }
                else
                {
                    UIView.animate(withDuration: fadeAnimateDuration, animations: tahFailedAnimation, completion: { _ in
                    })
                }
            }
            else
            {
                UIView.animate(withDuration: fadeAnimateDuration, animations: tahFailedAnimation, completion: { _ in
                })
            }
        })
        return rippleView
    }
    // swiftlint:enable function_parameter_count
}

/// Custom UIView for ripple effects
private final class RippleView: UIView {
    
    init(frame: CGRect, backgroundColor: UIColor) {
        super.init(frame: frame)
        self.backgroundColor = backgroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.bounds.width / 2)
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
    
}
