//
//  NavVC.swift
//  gerental
//
//  Created by 刘思源 on 2022/12/14.
//

import UIKit

extension UINavigationBar {

    
    func updateAppearance(_ update:(UINavigationBarAppearance)->()){
        let appearance = self.standardAppearance
        update(appearance)
        self.standardAppearance = appearance
        self.compactAppearance = appearance
        self.scrollEdgeAppearance = appearance
        if #available(iOS 15.0, *) {
            self.compactScrollEdgeAppearance = appearance
        }
    }
}

class NavVC: UINavigationController {
    static let navBarDefault: Void = {
        let appearance = themeAppearance
        UINavigationBar.appearance().tintColor = UIColor.kBlack
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.kTextBlack,
            .font: UIFont.semibold(18)
        ]

        appearance.buttonAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.kTextBlack,
            .font: UIFont.semibold(15)
        ]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance

        if #available(iOS 15.0, *) {
            UINavigationBar.appearance().compactScrollEdgeAppearance = appearance
        }
    }()
//
//
    static let themeAppearance: UINavigationBarAppearance = {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.shadowColor = .clear
        appearance.shadowImage = nil
        appearance.backgroundColor = .kThemeColor
        appearance.backgroundImage = UIImage(color: .kThemeColor)
        return appearance
    }()
    
    static let emptyAppearance: UINavigationBarAppearance = {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.shadowColor = .clear
        appearance.shadowImage = nil
        appearance.backgroundColor = .clear

        return appearance
    }()
    
    
    private let initializer: Void = NavVC.navBarDefault
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.modalPresentationStyle = .fullScreen
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if (self.viewControllers.count >= 1){
            viewController.hidesBottomBarWhenPushed = true
            let item = UIBarButtonItem(image: .init(named: "nav_back")?.withRenderingMode(.alwaysOriginal), style: .plain, target: nil, action: nil)
            item.actionBlock = {[weak viewController, weak self] _ in
                if let action = viewController?.sy_popAction {
                    action()
                }else{
                    self?.popViewController(animated: true)
                }
            }
        
            viewController.navigationItem.leftBarButtonItem = item
        }
        super.pushViewController(viewController, animated: animated)
    }

    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }

}
