//
//  UIButton+Chain.swift
//  ChainKit
//
//  Created by umisky on 2020/5/23.
//  Copyright © 2020 chenshu. All rights reserved.
//

import UIKit

extension Chain where Base: UIButton {
    
    @discardableResult
    public func transform(_ transform: CGAffineTransform) -> Self {
        base.transform = transform
        return self
    }
    
    @discardableResult
    public func content(edgeInsets: UIEdgeInsets) -> Self {
        base.contentEdgeInsets = edgeInsets
        return self
    }
    
    @discardableResult
    public func title(edgeInsets: UIEdgeInsets) -> Self {
        base.titleEdgeInsets = edgeInsets
        return self
    }
    
    @discardableResult
    public func reversesTitleShadowWhenHighlighted(_ reversesTitleShadowWhenHighlighted: Bool) -> Self {
        base.reversesTitleShadowWhenHighlighted = reversesTitleShadowWhenHighlighted
        return self
    }
    
    @discardableResult
    public func image(edgeInsets: UIEdgeInsets) -> Self {
        base.imageEdgeInsets = edgeInsets
        return self
    }
    
    @discardableResult
    public func adjustsImageWhenHighlighted(_ adjustsImageWhenHighlighted: Bool) -> Self {
        base.adjustsImageWhenHighlighted = adjustsImageWhenHighlighted
        return self
    }
    
    @discardableResult
    public func adjustsImageWhenDisabled(_ adjustsImageWhenDisabled: Bool) -> Self {
        base.adjustsImageWhenDisabled = adjustsImageWhenDisabled
        return self
    }
    
    @discardableResult
    public func showsTouchWhenHighlighted(_ showsTouchWhenHighlighted: Bool) -> Self {
        base.showsTouchWhenHighlighted = showsTouchWhenHighlighted
        return self
    }
    
    @discardableResult
    public func tintColor(_ tintColor: UIColor!) -> Self {
        base.tintColor = tintColor
        return self
    }
    
    @discardableResult
    public func title(text: String?, for state: UIControl.State) -> Self {
        base.setTitle(text, for: state)
        return self
    }
    
    @discardableResult
    public func normalTitle(text: String?) -> Self {
        base.setTitle(text, for: .normal)
        return self
    }
    
    
    @discardableResult
    public func selectedTitle(text: String?) -> Self {
        base.setTitle(text, for: .selected)
        return self
    }
    

    
    @discardableResult
    public func titleColor(color: UIColor?, for state: UIControl.State) -> Self {
        base.setTitleColor(color, for: state)
        return self
    }
    

    @discardableResult
    public func normalTitleColor(color: UIColor?) -> Self {
        base.setTitleColor(color, for: .normal)
        return self
    }
    
    @discardableResult
    public func disabledTitleColor(color: UIColor?) -> Self {
        base.setTitleColor(color, for: .disabled)
        return self
    }
    
    @discardableResult
    public func normalTitleColor(string: String) -> Self {
        let color = UIColor(hexColor:string)
        base.setTitleColor(color, for: .normal)
        return self
    }
    
    @discardableResult
    public func selectedTitleColor(color: UIColor?) -> Self {
        base.setTitleColor(color, for: .selected)
        return self
    }
    
    @discardableResult
    public func selectedTitleColor(string: String) -> Self {
        let color = UIColor(hexColor:string)
        base.setTitleColor(color, for: .selected)
        return self
    }

    
    
    @discardableResult
    public func title(shadowColor: UIColor?, for state: UIControl.State) -> Self {
        base.setTitleShadowColor(shadowColor, for: state)
        return self
    }
    
    @discardableResult
    public func image(_ image: UIImage?, for state: UIControl.State) -> Self {
        base.setImage(image, for: state)
        return self
    }
    
    @discardableResult
    public func normalImage(_ image: UIImage?) -> Self {
        base.setImage(image, for: .normal)
        return self
    }
    
    @discardableResult
    public func selectedImage(_ image: UIImage?) -> Self {
        base.setImage(image, for: .selected)
        return self
    }
    
    @discardableResult
    public func disabledImage(_ image: UIImage?) -> Self {
        base.setImage(image, for: .disabled)
        return self
    }
    
    @discardableResult
    public func backgroundImage(_ backgroundImage: UIImage?, for state: UIControl.State) -> Self {
        base.setBackgroundImage(backgroundImage, for: state)
        return self
    }
    
    
    @discardableResult
    public func normalBackgroundImage(_ backgroundImage: UIImage?) -> Self {
        base.setBackgroundImage(backgroundImage, for: .normal)
        return self
    }
    
    
    @discardableResult
    public func selectedBackgroundImage(_ backgroundImage: UIImage?) -> Self {
        base.setBackgroundImage(backgroundImage, for: .selected)
        return self
    }
    
    
    @discardableResult
    public func highlightedBackgroundImage(_ backgroundImage: UIImage?) -> Self {
        base.setBackgroundImage(backgroundImage, for: .highlighted)
        return self
    }
    
    @discardableResult
    public func disabledBackgroundImage(_ backgroundImage: UIImage?) -> Self {
        base.setBackgroundImage(backgroundImage, for: .disabled)
        return self
    }
    
    
    @discardableResult
    public func attributedTitle(_ attributedTitle: NSAttributedString?, for state: UIControl.State) -> Self {
        base.setAttributedTitle(attributedTitle, for: state)
        return self
    }
    
    @discardableResult
    public func normalAttributedTitle(_ attributedTitle: NSAttributedString?) -> Self {
        base.setAttributedTitle(attributedTitle, for: .normal)
        return self
    }
    
    @discardableResult
    public func selectedAttributedTitle(_ attributedTitle: NSAttributedString?) -> Self {
        base.setAttributedTitle(attributedTitle, for: .selected)
        return self
    }
    
    
    @discardableResult
    public func title(front: UIFont) -> Self {
        base.titleLabel?.font = front
        return self
    }
    
    @discardableResult
    public func font(_ front: UIFont) -> Self {
        base.titleLabel?.font = front
        return self
    }
}
