//
//  GEPopTool.swift
//  gerental
//
//  Created by 刘思源 on 2022/12/19.
//

import UIKit


extension UIView{
    func popFromViewBottom(fromView view: UIView){
        self.autoresizingMask = []
        self.layoutIfNeeded()
        view.addSubview(self)
        self.top = view.bottom
        view.centerX = view.centerX
        UIView.animate(withDuration: 0.3) {
            view.bottom = view.bottom
            //view.center = CGPointMake(self.popWindow.size.width/2, self.popWindow.height - view.height/2);
        } completion: { _ in
            
        }
    }
    
    func dismissFromView(fromView view: UIView){
        UIView.animate(withDuration: 0.3) {
            self.top = view.bottom
        } completion: { completed in
            if completed{
                self.removeFromSuperview()
            }
        }
    }
}

enum GEPopDirection: NSInteger{
    case bottom
    case center
    case top
}

extension UIView{
    @objc func popFromBottom(withMask:Bool = true, tapToDismiss:Bool = false){
        GEPopTool.popViewFormBottom(view: self, withMask: withMask, tapToDismss: tapToDismiss)
    }
    
    @objc func popDismiss(completedHandler: Block? = nil){
        GEPopTool.dismissPopView(completedHandler: completedHandler)
    }
    
    @objc func popFromCenter(withMask mask: Bool = true, tapToDismiss: Bool = true){
        GEPopTool.popView(view: self, fromDirection: .center, withMask: mask, tapToDismiss: tapToDismiss)
    }
    
    func popView(fromDirection direction: GEPopDirection = .bottom, withMask mask: Bool = true, tapToDismiss: Bool = true){
        GEPopTool.popView(view: self, fromDirection: direction, withMask: mask, tapToDismiss: tapToDismiss)
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
        var popDiretion = GEPopDirection.bottom
        
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
    
    static func popView(view: UIView, fromDirection direction: GEPopDirection = .bottom, withMask mask : Bool = true, tapToDismiss: Bool = true){
        let topPopItem = GEPopItem(view: view,tapToDismiss: tapToDismiss)
        topPopItem.popDiretion = direction
        if popItems.contains(topPopItem){
            //同一个视图不能重复弹窗.
            print("already poped")
            return
        }
        
        popItems.append(topPopItem)
        popWindow.backgroundColor = .kDeepBlack.alpha(mask ? 0.5 : 0)
        popWindow.isHidden = false
        popWindow.addSubview(view)
        tapGuesture.isEnabled = tapToDismiss
        
        view.autoresizingMask = []
        view.layoutIfNeeded()
        
        switch direction {
        case .bottom:
            view.top = popWindow.bottom
            view.centerX = popWindow.centerX
            UIView.animate(withDuration: 0.3) {
                view.bottom = self.popWindow.bottom
                //view.center = CGPointMake(self.popWindow.size.width/2, self.popWindow.height - view.height/2);
            } completion: { _ in
                
            }
            return
        case .center:
            view.center = popWindow.center
            view.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            UIView.animate(withDuration: 0.3) {
                view.transform = CGAffineTransformIdentity
            } completion: { _ in
                
            }
        case .top:
            view.bottom = popWindow.top
            view.centerX = popWindow.centerX
            UIView.animate(withDuration: 0.3) {
                view.top = self.popWindow.top
            } completion: { _ in
                
            }
        }
        
    }
    
    
    static func dismissPopView(completedHandler: Block? = nil){
        if let popItem = topPopItem{
            popItem.isShow = false
            tapGuesture.isEnabled = popItem.tapToDissmiss
            UIView.animate(withDuration: 0.3) {
                switch popItem.popDiretion{
                case .top:
                    popItem.view.bottom = self.popWindow.top
                    break
                case .bottom:
                    popItem.view.top = self.popWindow.bottom
                    break
                case .center:
                    popItem.view.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                    break
                }
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
            switch item.popDiretion{
            case .top:
                if item.isShow{
                    item.view.top = self.popWindow.top
                }else{
                    item.view.bottom = self.popWindow.top
                }
                break
            case .bottom:
                if item.isShow{
                    item.view.bottom = self.popWindow.bottom
                }else{
                    item.view.top = self.popWindow.bottom
                }
                break
            case .center:
                item.view.center = self.popWindow.center
                break;
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
