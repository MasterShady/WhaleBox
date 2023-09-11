//
//  DFTabbar.swift
//  WhaleBox
//
//  Created by 刘思源 on 2023/9/4.
//

import Foundation

import UIKit

private let kButtonWH = 56.0


class DFTabbar: UITabBar {
    var roundButtonClickHandler : (()->())?
    var roundButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        roundButton = UIButton()
        roundButton.frame = frame
        backgroundColor = UIColor.white
        roundButton.backgroundColor = .kThemeColor
        roundButton.chain.normalTitle(text: "发布").font(.semibold(16)).normalTitleColor(color: .kTextBlack).corner(radius: kButtonWH/2).clipsToBounds(true)
        roundButton.addTarget(self, action: #selector(roundBtnClicked), for: .touchUpInside)
        addSubview(roundButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func roundBtnClicked() {
        roundButtonClickHandler?()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let centerX = bounds.size.width * 0.5
        let centerY = bounds.size.height * 0.5
        roundButton.frame = CGRect(x: centerX - 30, y: centerY - 50, width: kButtonWH, height: kButtonWH)
        
        let tabBarButtonClass: AnyClass? = NSClassFromString("UITabBarButton")
        var index = 0
        let tabWidth = bounds.size.width / 5
        
        for view in subviews {
            if view.isKind(of: tabBarButtonClass!) {
                var rect = view.frame
                rect.origin.x = CGFloat(index) * tabWidth
                rect.size.width = tabWidth
                view.frame = rect
                index += 1
                
                if index == 2 {
                    index += 1
                }
            }
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !isHidden {
            if touchPointInsideCircle(center: roundButton.center, radius: kButtonWH/2, targetPoint: point) {
                return roundButton
            }
        }
        return super.hitTest(point, with: event)
    }
    
    func touchPointInsideCircle(center: CGPoint, radius: CGFloat, targetPoint: CGPoint) -> Bool {
        let distance = sqrt(pow(targetPoint.x - center.x, 2) + pow(targetPoint.y - center.y, 2))
        return distance <= radius
    }
}
