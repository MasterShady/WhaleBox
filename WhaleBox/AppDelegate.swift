//
//  AppDelegate.swift
//  WhaleBox
//
//  Created by 刘思源 on 2023/9/4.
//

import UIKit
import IQKeyboardManagerSwift
import ThinkingSDK

@main

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        if window == nil{
            window = UIWindow(frame: UIScreen.main.bounds)
        }
        window?.rootViewController = TabbarVC()
        window?.makeKeyAndVisible()
        
        return true
    }

    static func initThinkSDK(){
        ThinkingAnalyticsSDK.setLogLevel(.debug)
        ThinkingAnalyticsSDK.start(withAppId: "0f0d35332c244d18b7d7e200a6d20e61", withUrl: "https://bd-track.zuhaowan.cn/")
        let instance = ThinkingAnalyticsSDK.sharedInstance()!
        
        //app_version_name 表示移动端版本
        //app_version_code 表示前端版本
        //let app_version_name = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        
        instance.superProperty.registerSuperProperties([
            "app_id":"500180000",
            "app_channel": "appstore_",
            "app_version_name": "1.0.0.0",
            "is_jail_break": DeviceHelper.isJailBreak,
            "hasSimCard" : DeviceHelper.hasSIMCard
        ])
        
        instance.addWebViewUserAgent()
        instance.enableAutoTrack([.eventTypeAll])
    }
    


}

