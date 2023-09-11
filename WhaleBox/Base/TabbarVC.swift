//
//  TabbarVC.swift
//  gerental
//
//  Created by 刘思源 on 2022/12/8.
//

import Foundation
import UIKit

extension UITabBar{
    func updateAppearance(_ update:(UITabBarAppearance)->()){
        let appearance = self.standardAppearance
        update(appearance)
        if #available(iOS 15.0, *) {
            self.scrollEdgeAppearance = appearance
        } else {
        
        }
    }
}

@objcMembers class TabbarVC : UITabBarController{
    
    
//    private let initializer: Void = {
//        let selectedAttributes: [NSAttributedString.Key: Any] = [
//            .font: UIFont.boldSystemFont(ofSize: 10),
//            .foregroundColor: UIColor.init(hexColor: "#333333")
//        ]
//        UITabBarItem.appearance().setTitleTextAttributes(selectedAttributes, for: .selected)
//
//        let normalAttributes: [NSAttributedString.Key: Any] = [
//            .font: UIFont.boldSystemFont(ofSize: 10),
//            .foregroundColor: UIColor.red
//        ]
//        UITabBarItem.appearance().setTitleTextAttributes(normalAttributes, for: .normal)
//
//
//    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tabbar = DFTabbar()
        tabbar.roundButtonClickHandler = {
            UserStore.checkLoginStatusThen {
                let vc = NavVC(rootViewController: CreatePostVC())
                self.present(vc, animated: true)
            }
        }
        self.setValue(tabbar, forKey: "tabBar")
        tabBar.isTranslucent = false
        tabBar.tintColor = .init(hexColor: "#333333")
        tabBar.shadowImage = nil
        
        
       
//        tabBar.updateAppearance {
//            $0.configureWithOpaqueBackground()
//            $0.backgroundColor = .kExLightGray
//        }
        
        self.addChilds()
    }
    
        func addChilds(){
            
            
            let player = GKDYPlayerViewController()
            player.tab = "youxi_new"
            
            let childs : [(String,String,UIViewController)] = [
                ("home_tabbar","首页",HomeVC()),
                ("video_tabbar","视频",player),
                ("circle_tabbar","圈子",CircleCatVC()),
                ("mine_tabbar","我的",MineVC())
            ]
            
//            if let classType = NSClassFromString("GKDYPlayerViewController") as? UIViewController.Type {
//                // 如果成功获取到类类型，则可以使用它来创建类的实例
//                let myObject = classType.init()
//                childs.insert(("video_tabbar","视频",myObject),at:1)
//            }
    
            for child in childs {
                let image =  UIImage(named: child.0)!.byResize(to: CGSize(width: 28, height: 28))!
                let vc = NavVC(rootViewController: child.2)
                vc.tabBarItem.image = image
                vc.tabBarItem.selectedImage = image.withRenderingMode(.alwaysOriginal)
                vc.tabBarItem.title = child.1
                self.addChild(vc)
    
            }
    
        }
    
    
    
}
