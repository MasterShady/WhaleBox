//
//  GEPopTool.swift
//  gerental
//
//  Created by 刘思源 on 2022/12/19.
//

import UIKit

extension UIView{
    func popFromBottom(withMask:Bool = true, tapToDismiss:Bool = false){
        GEPopTool.popViewFormBottom(view: self, withMask: withMask, tapToDismss: tapToDismiss)
    }
    
    func popDismiss(completedHandler: Block? = nil){
        GEPopTool.dismissPopView(completedHandler: completedHandler)
    }
    
}

class GEWindow: UIWindow{
    var layoutSubviewsHandler : Block?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutSubviewsHandler?()
    }
}

class GEPopTool: NSObject {
    
    fileprivate class GEPopItem : Equatable{
        let view: UIView
        var isShow: Bool = true
        let tapToDissmiss: Bool
        
        init(view: UIView, tapToDismiss: Bool) {
            self.view = view
            self.tapToDissmiss = true
        }
        
        static func == (lhs: GEPopItem, rhs: GEPopItem) -> Bool {
            return lhs.view == rhs.view
       }
    }
    
    fileprivate static var popItems = [GEPopItem]()
    
    fileprivate static var topPopItem: GEPopItem? {
        return popItems.last
    }
    
    
    

    static func popViewFormBottom(view:UIView, withMask:Bool = true, tapToDismss: Bool = false){
        let topPopItem = GEPopItem(view: view,tapToDismiss: tapToDismss)
        if popItems.contains(topPopItem){
            //同一个视图不能重复弹窗.
            print("already poped")
            return
        }
        
        popItems.append(topPopItem)
        popWindow.backgroundColor = .kDeepBlack.alpha(withMask ? 0.5 : 0)
        popWindow.isHidden = false
        popWindow.addSubview(view)
        
        
        tapGuesture.isEnabled = tapToDismss
        
        view.autoresizingMask = []
        view.layoutIfNeeded()
        view.top = popWindow.bottom
        view.centerX = popWindow.centerX
        UIView.animate(withDuration: 0.3) {
            view.bottom = self.popWindow.bottom
            //view.center = CGPointMake(self.popWindow.size.width/2, self.popWindow.height - view.height/2);
        } completion: { _ in
            
        }
    }
    
    static func dismissPopView(completedHandler: Block? = nil){
        if let popItem = topPopItem{
            popItem.isShow = false
            tapGuesture.isEnabled = popItem.tapToDissmiss
            UIView.animate(withDuration: 0.3) {
                popItem.view.top = self.popWindow.bottom
            } completion: { completed in
                if completed{
                    popItem.view.removeFromSuperview()
                    self.popItems.removeLast()
                    if self.popItems.count == 0{
                        self.popWindow.isHidden = true
                    }
                    completedHandler?()
                }
                
            }
        }
    }
    
    static func adjustSubViewsFrame(){
        self.popItems.forEach { item in
            if item.isShow{
                item.view.bottom = self.popWindow.bottom
            }else{
                item.view.top = self.popWindow.bottom
            }
            
        }
    }
    
    
    static var popWindow: UIWindow = {
        let window = GEWindow(frame: UIScreen.main.bounds)
        window.windowLevel = .init(1000)
        window.isHidden = true
        window.layoutSubviewsHandler = {
            adjustSubViewsFrame()
        }
        return window
    }()
    
    static var tapGuesture: UITapGestureRecognizer = {
        
        let tap = UITapGestureRecognizer {tap in
            if let topPopItem = topPopItem{
                let tap = tap as! UITapGestureRecognizer
                let ponit = tap.location(in: topPopItem.view)
                if !topPopItem.view.bounds.contains(ponit){
                    //点击不在最上层的子视图上.才能pop
                    dismissPopView()
                }
            }
        }
        popWindow.addGestureRecognizer(tap)
        return tap
    }()
    
}
