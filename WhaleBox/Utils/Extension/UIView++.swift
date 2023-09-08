//
//  UIView++.swift
//  ferental
//
//  Created by 刘思源 on 2022/12/27.
//

import Foundation
@_exported import SnapKit

extension UIStackView{
    func addSpacing(_ spacing: CGFloat){
        let spacingView = UIView()
        spacingView.snp.makeConstraints { make in
            if self.axis == .vertical{
                make.height.equalTo(spacing)
            }else{
                make.width.equalTo(spacing)
            }
        }
        self.addArrangedSubview(spacingView)
    }
}

extension UIView{
    func wrappedBy(_ insets: UIEdgeInsets, color: UIColor = .clear) -> UIView{
        let container = UIView()
        container.addSubview(self)
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(insets)
        }
        container.backgroundColor = color
        return container
    }
}

extension UIView{
    
    var x: CGFloat {
        set {
            self.frame.origin.x = newValue
        }
        get {
            return self.frame.origin.x
        }
    }
    
    var y: CGFloat {
        set {
            self.frame.origin.y = newValue
        }
        get {
            return self.frame.origin.y
        }
    }
    
    var width: CGFloat {
        set {
            self.frame.size.width = newValue
        }
        get {
            return self.frame.size.width
        }
    }
    
    var height: CGFloat {
        set {
            self.frame.size.height = newValue
        }
        get {
            return self.frame.size.height
        }
    }
    
    var centerX: CGFloat {
        set {
            self.center.x = newValue
        }
        get {
            return self.center.x
        }
    }
    
    var centerY: CGFloat {
        set {
            self.center.y = newValue
        }
        get {
            return self.center.y
        }
    }

    func firstViewController()->UIViewController?{
        for view in sequence(first: self.superview, next: {$0?.superview}){

            if let responder = view?.next{

                if responder.isKind(of: UIViewController.self){

                    return responder as? UIViewController
                }
            }
        }
        return nil
    }
    
    func renderImage(scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, scale)
        // Draw view in that context
        if let ctx = UIGraphicsGetCurrentContext() {
            layer.render(in: ctx)
        }
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func roundCorners(corners: UIRectCorner, rect: CGRect, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func removeSubviews() {
        subviews.forEach({ $0.removeFromSuperview() })
    }
    
    func addTransitionAnimation(duration: Double = 0.25, type: CATransitionType = .fade) {
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = type
        layer.add(transition, forKey: "transition")
    }
    
    func getPositionAnimation(path: UIBezierPath, duration: Double) -> CAKeyframeAnimation {
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        pathAnimation.duration = duration
        pathAnimation.path = path.cgPath
        pathAnimation.fillMode = .forwards
        pathAnimation.isRemovedOnCompletion = false
        return pathAnimation
    }
    
    func addOuterShadow(shadowColor: UIColor, shadowOpacity: Float, shadowRadius: CGFloat, shadowOffset: CGSize) {
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.shadowOffset = shadowOffset
    }
    
    func addInnerShadow(shadowColor: UIColor, shadowOpacity: Float, shadowRadius: CGFloat, shadowOffset: CGSize) {
        layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
        
        let innerShadow = CALayer()
        innerShadow.frame = bounds
        
        // Shadow path (1pt ring around bounds)
        let radius = self.layer.cornerRadius
        let path = UIBezierPath(roundedRect: innerShadow.bounds.insetBy(dx: 2, dy:2), cornerRadius:radius)
        let cutout = UIBezierPath(roundedRect: innerShadow.bounds, cornerRadius:radius).reversing()
        
        path.append(cutout)
        innerShadow.shadowPath = path.cgPath
        innerShadow.masksToBounds = true
        
        // Shadow properties
        innerShadow.shadowColor = shadowColor.cgColor
        innerShadow.shadowOffset = shadowOffset
        innerShadow.shadowOpacity = shadowOpacity
        innerShadow.shadowRadius = shadowRadius
        innerShadow.cornerRadius = self.layer.cornerRadius
        layer.addSublayer(innerShadow)
    }
}





