//
//  UIColorExt.swift
//  Dylan.Lee
//
//  Created by Dylan on 2017/9/22.
//  Copyright © 2017年 Dylan.Lee. All rights reserved.
//

import UIKit

func UIColorFromRGB(_ red: Int,_ green: Int,_ blue: Int) -> UIColor {
    return UIColor.init(red: red, green: green, blue: blue, alpha: 1.0)
}

// MARK: 通过16进制初始化UIColor
public extension UIColor {
    
    convenience init(numberColor: Int, alpha: CGFloat = 1.0) {
        self.init(hexColor: String(numberColor, radix: 16), alpha: alpha)
    }
    
    convenience init(hexColor: String, alpha: CGFloat = 1.0) {
        var hex = hexColor.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if hex.hasPrefix("#") {
            hex.remove(at: hex.startIndex)
        }
        if hex.hasPrefix("0x") || hex.hasPrefix(("0X")) {
            hex.removeSubrange((hex.startIndex ..< hex.index(hex.startIndex, offsetBy: 2)))
        }
        
        guard let hexNum = Int(hex, radix: 16) else {
            self.init(red: 0, green: 0, blue: 0, alpha: 0)
            return
        }
        
        switch hex.count {
        case 3:
            self.init(red: CGFloat(((hexNum & 0xF00) >> 8).duplicate4bits) / 255.0,
                      green: CGFloat(((hexNum & 0x0F0) >> 4).duplicate4bits) / 255.0,
                      blue: CGFloat((hexNum & 0x00F).duplicate4bits) / 255.0,
                      alpha: alpha)
        case 6:
            self.init(red: CGFloat((hexNum & 0xFF0000) >> 16) / 255.0,
                      green: CGFloat((hexNum & 0x00FF00) >> 8) / 255.0,
                      blue: CGFloat((hexNum & 0x0000FF) >> 0) / 255.0,
                      alpha: alpha)
        default:
            self.init(red: 0, green: 0, blue: 0, alpha: 0)
        }
    }
    
    class func gradient(fromColors colors: [UIColor], size: CGSize) -> UIColor{
        return self.gradient(colors: colors, from: .init(x: 0, y: 0), to: .init(x: size.width, y: size.height), size: size)
    }
    
    
    class func gradient(colors: [UIColor], from: CGPoint, to: CGPoint, size: CGSize) -> UIColor{
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        let colorspace = CGColorSpaceCreateDeviceRGB()
        
        var cgColors: [AnyHashable] = []
        for color in colors {
            cgColors.append(color.cgColor)
        }
        var gradient: CGGradient? = nil
        
        if let aColors = cgColors as CFArray? {
            gradient = CGGradient(colorsSpace: colorspace, colors: aColors, locations: nil)
        }
        
        if let gradient = gradient {
            context?.drawLinearGradient(gradient, start: from, end: to, options: [])
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        
        UIGraphicsEndImageContext()
        return UIColor(patternImage: image!)
    }
}

private extension Int {
    var duplicate4bits: Int {
        return self << 4 + self
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        assert(alpha >= 0 && alpha <= 1, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(alpha))
    }
    
    convenience init(hex: String, alpha: CGFloat) {
        var rHex = hex
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            rHex = String(hex[start...])
        }
        
        let scanner = Scanner(string: rHex)
        scanner.scanLocation = 0
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(red: Int(r), green: Int(g), blue: Int(b), alpha: alpha)
    }
    
    static func random() -> UIColor {
        return UIColorFromRGB(Int(arc4random())%255, Int(arc4random())%255, Int(arc4random())%255)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)
    }
    
    func alpha(_ alpha: CGFloat) -> UIColor {
        return withAlphaComponent(alpha)
    }
}

