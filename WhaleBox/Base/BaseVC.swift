//
//  BaseVC.swift
//  gerental
//
//  Created by 刘思源 on 2022/12/8.
//

import Foundation
import UIKit
import SnapKit
import ETNavBarTransparent

class BaseVC : UIViewController{
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .fullScreen
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = true
        view.backgroundColor = .white
        configData()
        configNavigationBar()
        configSubViews()
        networkRequest()
        DispatchQueue.main.async { [weak self] in
            self?.decorate()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(onReconnet), name: GlobalContext.kUserReConnectedNetwork.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUserChanged), name: kUserChanged.name, object: nil)
    }
    
    
    func configData(){
        //初始化数据
    }
    
    func configSubViews(){
        //子视图
    }
    
    func configNavigationBar(){
        //navigationBar操作
//        if (navigationController?.viewControllers.count ?? 0) > 1 {
//            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
//        }
    }
    
    func decorate(){
        //用于布局完成后的操作,这里可以认为controller的初始化视图已经完成自动布局frame有值
    }
    
    func networkRequest(){
        
    }
    
    @objc func onReconnet(){
        //网络重连
    }
    
    @objc func onUserChanged(){
        
    }
    
}
