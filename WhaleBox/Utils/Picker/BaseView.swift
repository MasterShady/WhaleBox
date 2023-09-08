//
//  BaseView.swift
//  gerental
//
//  Created by 刘思源 on 2022/12/9.
//

import UIKit
import SnapKit

class BaseView: UIView {
    
    var needRelayout = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        configSubviews()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        DispatchQueue.main.async {
            self.decorate()
        }
    }
    
    func decorate(){}
    
    var expectWidth: CGFloat {
        return .zero
    }
    
    var expectHeight: CGFloat {
        return .zero
    }
    
    func configSubviews() {
        
    }

}
