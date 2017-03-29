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
        var endOpacity: CGFloat = 0
        
        public init(color: UIColor, scale: CGFloat, clipsToBounds: Bool, startPoint: CGPoint, scaleAnimateDuration: TimeInterval, fadeAnimateDuration: TimeInterval, initialOpacity: CGFloat, endOpacity: CGFloat) {
            self.color = color
            self.scale = scale
            self.clipsToBounds = clipsToBounds
            self.startPoint = startPoint
            self.scaleAnimateDuration = scaleAnimateDuration
            self.fadeAnimateDuration = fadeAnimateDuration
            self.initialOpacity = initialOpacity
            self.endOpacity = endOpacity
        }
    }
    
    public func rippleAnimate(with config: UIView.RippleConfiguration, completionHandler: (() -> Void)?) {
        
        clipsToBounds = config.clipsToBounds
        //let startRect = config.startRect ?? rippleDefaultStartRect
        
        rippleAnimate(with: config.color, scale: config.scale, startPoint: config.startPoint, initialOpacity: config.initialOpacity, endOpacity: config.endOpacity, scaleAnimateDuration: config.scaleAnimateDuration, fadeAnimateDuration: config.fadeAnimateDuration, completionHandler: completionHandler)
        
    }
    
    // swiftlint:disable function_parameter_count
    private func rippleAnimate(with color: UIColor, scale: CGFloat, startPoint: CGPoint, initialOpacity: CGFloat, endOpacity: CGFloat, scaleAnimateDuration: TimeInterval, fadeAnimateDuration: TimeInterval, completionHandler: (() -> Void)?) {
        
        let startFrame = CGRect(origin: startPoint, size: CGSize(width: 1, height: 1))
        let rippleView = RippleView(frame: startFrame, backgroundColor: color)
        addSubview(rippleView)
        rippleView.alpha = initialOpacity
        
        let scaleAnimation = {
            let widthRatio = self.frame.width / rippleView.frame.width
            rippleView.transform = CGAffineTransform(scaleX: widthRatio * scale, y: widthRatio * scale)
        }
        
        let fadeAnimation = { rippleView.alpha = endOpacity }
        
        // start scale animation
        UIView.animate(withDuration: scaleAnimateDuration, animations: scaleAnimation, completion: { completion in
            
            guard completion else { return }
            
            // start fade animation
            UIView.animate(withDuration: fadeAnimateDuration, animations: fadeAnimation, completion: { completion in
                guard completion else { return }
                rippleView.removeFromSuperview()
                completionHandler?()
            })
        })
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
