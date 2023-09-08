//
//  UIViewController++.swift
//  Shella
//
//  Created by fanyebo on 2023/7/5.
//

import UIKit

extension UIViewController {
    /// 是否是push 进入
    var isPushed: Bool {
        if navigationController == nil || navigationController?.viewControllers.first == self {
            return false
        }
        return true
    }

    var isRootOfNavigation: Bool {
        guard let `parent` = parent else { return false }
        if !parent.isKind(of: UINavigationController.self) && parent.children.contains(self) {
            return true
        }
        return false
    }
}
