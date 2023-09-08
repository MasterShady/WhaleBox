//
//  UIFont++.swift
//  Shella
//
//  Created by zxiangy on 2023/7/6.
//

import Foundation
import UIKit

public enum FontAlias: String {
    case pfRegular  = "PingFangSC-Regular"
    case pfMedium   = "PingFangSC-Medium"
    case pfLight    = "PingFangSC-Light"
    case pfSemibold = "PingFangSC-Semibold"
    case hltRegular = "HelveticaNeue"
    case hltMedium  = "HelveticaNeue-Medium"
    case hltBold    = "HelveticaNeue-Bold"
    case dinRegular = "DIN Alternate"
    case dinBold    = "DINAlternate-Bold"
    case arialIMT   = "Arial-ItalicMT"
}

extension UIFont {
    
    // 普通
    class func normal(_ fontSize: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: fontSize)
    }
    
    // 中等加粗
    class func medium(_ fontSize: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: fontSize, weight: .medium)
    }
    
    // 最大加粗
    class func semibold(_ fontSize: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: fontSize, weight: .semibold)
    }
    
    class func font(_ fontSize: CGFloat, _ alias: FontAlias) -> UIFont {
        return UIFont(name: alias.rawValue, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
}
