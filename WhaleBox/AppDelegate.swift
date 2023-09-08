//
//  AppDelegate.swift
//  WhaleBox
//
//  Created by 刘思源 on 2023/9/4.
//

import UIKit
import IQKeyboardManagerSwift

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



}

