//
//  UITableView++.swift
//  Shella
//
//  Created by fanyebo on 2023/7/5.
//

import UIKit

extension UITableView {

    public func register<T: UITableViewCell>(_ cellClass: T.Type) {
        register(cellClass, forCellReuseIdentifier: String(describing: T.self))
    }

    public func registerNib<T: UITableViewCell>(cellClass: T.Type) {
        let nib = UINib(nibName: String(describing: T.self), bundle: nil)
        register(nib, forCellReuseIdentifier: String(describing: T.self))
    }

    public func register<T: UITableViewHeaderFooterView>(_ viewClass: T.Type) {
        register(viewClass, forHeaderFooterViewReuseIdentifier: String(describing: T.self))
    }

    public func registerNib<T: UITableViewHeaderFooterView>(_ forHeaderFooterViewClass: T.Type) {
        let nib = UINib(nibName: String(describing: T.self), bundle: nil)
        register(nib, forHeaderFooterViewReuseIdentifier: String(describing: T.self))
    }

    public func dequeueReusableCell<T: UITableViewCell>(_ cellClass: T.Type) -> T {
        let cell = dequeueReusableCell(withIdentifier: String(describing: T.self))
        guard let cellType = cell as? T else {
            fatalError("Unable to dequeue:\(cellClass)")
        }
        return cellType
    }

    public func dequeueReusableCell<T: UITableViewCell>(_ cellClass: T.Type, indexPath: IndexPath) -> T {
        let cell = dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath)
        guard let cellType = cell as? T else {
            fatalError("Unable to dequeue:\(cellClass)")
        }
        return cellType
    }

    public func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_ viewClass: T.Type) -> T {
        let view = dequeueReusableHeaderFooterView(withIdentifier: String(describing: T.self))
        guard let viewType = view as? T else {
            fatalError("Unable to dequeue:\(viewClass)")
        }
        return viewType
    }
}

