//
//  AutoProgressHUD.swift
//  Dylan.Lee
//
//  Created by Dylan on 2017/11/6.
//  Copyright © 2017年 Dylan.Lee. All rights reserved.
//

import UIKit
//import MBProgressHUD

//class AutoProgressHUD {
//
//    static var makeHud: MBProgressHUD {
//        let topWindow: UIWindow = UIViewController.topmostVisiableWindow()
//		let hud = MBProgressHUD(view: topWindow)
//        topWindow.addSubview(hud)
//		return hud
//    }
//
//	class func showAutoHud(_ msg: String) {
//        DispatchQueue.main.async {
//            let hud = makeHud
//            hud.label.text = msg
//            hud.mode = .text
//            hud.label.textColor = .darkGray
//            hud.superview?.bringSubviewToFront(hud)
//            hud.show(animated: true)
//            hud.hide(animated: true, afterDelay: 2.0)
//        }
//	}
//
//    class func showHud(_ msg: String) {
//        DispatchQueue.main.async {
//            let hud = makeHud
//            hud.label.text = msg
//            hud.mode = .indeterminate
//            hud.label.textColor = .darkGray
//            hud.superview?.bringSubviewToFront(hud)
//            hud.show(animated: true)
//        }
//    }
//
//    class func hideHud() {
//        DispatchQueue.main.async {
//            makeHud.hide(animated: true)
//        }
//    }
//
//    class func showHud(hideTrgger:(@escaping Block)->()) {
//        let targetView = UIViewController.topmostVisiableWindow()!
//        MBProgressHUD.showAdded(to:targetView , animated: true)
//        hideTrgger({
//            MBProgressHUD.hide(for: targetView, animated: true)
//        })
//    }
//
//}
