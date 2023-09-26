//
//  Constants.swift
//  StoryMaker
//
//  Created by Park on 2022/1/9.
//  Copyright © 2020 mayqiyue. All rights reserved.
//

import UIKit
import Toaster



// MARK: - 常量 & 通知


//网络重连0
let kBundleName = Bundle.main.infoDictionary!["CFBundleName"] as? String ?? ""
let kCachesPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
let kDocumentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
let kTempPath = NSTemporaryDirectory()
let kNameSpage = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
let kAppVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
let kBuildNumber = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
let kAppName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? ""


@objcMembers public class GlobalContext : NSObject{
    static let kUserReConnectedNetwork = Notification(name: Notification.Name("kUserReConnectedNetwork"), object: nil)
    
}



extension URL {
    init(subPath: String) {
        self.init(string: kHostUrl + subPath)!
    }
}

extension NSAttributedString {
    convenience init (_ string:String, color: UIColor, font:UIFont){
        self.init(string: string, attributes:[
            .foregroundColor: color,
            .font: font
        ])
    }
}



extension UIColor{
    static let kBlack = UIColor(hexColor:"333333")
    static let kLightGray = UIColor(hexColor:"989898")
    static let kBlue = UIColor(hexColor:"#3A7BC9")
    static let kExLightGray = UIColor(hexColor:"#F5F5F5")
    static let kTextLightGray = UIColor(hexColor:"#A1A0AB")
    static let kSepLineColor = UIColor(hexColor:"#EEEEEE")
    static let kDeepBlack = UIColor(hexColor:"111111")
    static let kTextBlack = UIColor(hexColor:"#333333")
    static let kTextPink = UIColor(hexColor:"#FC4FFC")
    static let kLightCyanColor = UIColor(hexColor: "#CAF7FE")
    static let kCyanColor = UIColor(hexColor: "#36F5FF")
    static let kTextDrakGray = UIColor(hexColor: "#9594A6")
    
    static let kThemeColor = UIColor(hexColor: "#FEF044")
    
    
}



// MARK: - Typealias
typealias Block = () -> Void
typealias BoolBlock = (Bool) -> Void
typealias IntBlock = (Int) -> Void
typealias DoubleBlock = (Double) -> Void
typealias CGFloatBlock = (Double) -> Void
typealias StringBlock = (String) -> Void
typealias ImageBlock = (UIImage) -> Void



//MARK: Layout

/*
 获取设备statusBar高度的方式
 方式一: UIApplication.sharedApplication.windows.firstObject.safeAreaInsets.top
 方式二: UIApplication.shared.statusBarFrame.height
 safeAreaInsets 说明:
 实际上这个top的值就是设备statusBar的高度. safeAreaInsets.top  == [[UIApplication sharedApplication] statusBarFrame].size.height
 不同型号设备值是不一样的, 下面为测试结果.
 (top = 44, left = 0, bottom = 34, right = 0) for iphoneX
 (50,0,34,0) for iphone12 mini
 (47,0,34,0) for 12 pro & 12 pro max
 (20,0,0,0) for normal device eg: iphone6.
 (24,0,20,0) for 4th iPad Air
 */
let kStatusBarHeight: CGFloat = UIApplication.shared.windows.first!.safeAreaInsets.top
let kNavBarHeight = 44.0
let kNavBarMaxY = kStatusBarHeight + kNavBarHeight

let kBottomSafeInset = UIApplication.shared.windows.first!.safeAreaInsets.bottom
public let kWindow: UIWindow? = UIApplication.shared.windows.last
let appdelegate = UIApplication.shared.delegate as! AppDelegate
let kScreenWidth = UIScreen.main.bounds.width
let kScreenHeight = UIScreen.main.bounds.height
let kTabbarHeight = 49 + kBottomSafeInset



public var kDFRentBundleName: String {
    guard let bundleName = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String else {
        return "unknown"
    }
    return bundleName
}

/// 命名空间
public var kNameSpace: String {
    guard let nameSpace = Bundle.main.infoDictionary!["CFBundleExecutable"] as? String else {
        return "unknown"
    }
    return nameSpace
}



/// keywindow
public var keyWindow: UIWindow? {
    var window: UIWindow?
    if #available(iOS 13.0, *) {
        // 初始化启动时, UIWindowScene 的状态是 foregroundInactive
        window = UIApplication.shared.connectedScenes.filter { $0.activationState == .foregroundActive }.compactMap { $0 as? UIWindowScene }.first?.windows.first(where: \.isKeyWindow)
        if window == nil {
            window = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first?.windows.first
        }
    } else {
        window = UIApplication.shared.keyWindow
    }
    if #available(iOS 15.0, *) {
        return window
    } else {
        return window ?? UIApplication.shared.windows.first
    }
}

// MARK: - 自定义日志输出函数 debug模式下有效 release模式下不打印
public func printLog<T>(_ message: T,
                 file: String = #file,
                 line: Int = #line) {
    print("~~ \((file as NSString).lastPathComponent)[\(line)]: \(message)")
}



extension Double {
    var rw : Double{
        kScreenWidth/375.0 * self
    }
}


extension Float{
    var rW: Float{
        return Float(375/kScreenWidth * self)
    }
}

extension CGRect{
    func centerIn(rect: CGRect) -> CGRect{

        return CGRect(x: self.width, y: self.height, width:CGRectGetMidX(rect) - width/2 , height: CGRectGetMaxY(rect) - height/2)
    }
    
    init(width: CGFloat, height: CGFloat, centerInRect: CGRect) {
        self.init(origin: CGPoint(x: CGRectGetMidX(centerInRect) - width/2, y: CGRectGetMidY(centerInRect) - height/2), size: CGSize(width: width, height: height))
        
    }
}

extension String{
    func hint(){
        let toast = Toast(text: self)
        toast.view.bottomOffsetPortrait = UIScreen.main.bounds.size.height/2
        toast.show()
    }
}

extension NSString{
    @objc func hint(){
        let toast = Toast(text: self as String)
        toast.view.bottomOffsetPortrait = UIScreen.main.bounds.size.height/2
        toast.show()
    }
}


//MARK: Log
public func track(_ message: String, file: String = #file, function: String = #function, line: Int = #line ) {
    print("\(message) called from \(function) \(file):\(line)")
}
