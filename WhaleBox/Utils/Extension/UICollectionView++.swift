//
//  UICollectionView++.swift
//  Shella
//
//  Created by zxiangy on 2023/7/7.
//

import Foundation
import UIKit

extension UICollectionView {

    public func register<T: UICollectionViewCell>(_ cellClass: T.Type) {
        register(cellClass, forCellWithReuseIdentifier: String(describing: T.self))
    }

    public func registerNib<T: UICollectionViewCell>(cellClass: T.Type) {
        let nib = UINib(nibName: String(describing: T.self), bundle: nil)
        register(nib, forCellWithReuseIdentifier: String(describing: T.self))
    }

    public func register<T: UICollectionReusableView>(_ viewClass: T.Type, _ forSupplementaryViewOfKind: String) {
        register(viewClass, forSupplementaryViewOfKind: forSupplementaryViewOfKind, withReuseIdentifier: String(describing: T.self))
    }

    public func registerNib<T: UICollectionReusableView>(_ viewClass: T.Type, _ forSupplementaryViewOfKind: String) {
        let nib = UINib(nibName: String(describing: T.self), bundle: nil)
        register(nib, forSupplementaryViewOfKind: forSupplementaryViewOfKind, withReuseIdentifier: String(describing: T.self))
    }

    public func dequeueReusableCell<T: UICollectionViewCell>(_ cellClass: T.Type, indexPath: IndexPath) -> T {
        let cell = dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath)
        guard let cellType = cell as? T else {
            fatalError("Unable to dequeue:\(cellClass)")
        }
        return cellType
    }

    public func dequeueReusableSupplementaryView<T: UICollectionReusableView>(_ viewClass: T.Type, _ forSupplementaryViewOfKind: String, _ indexPath: IndexPath) -> T {
        let view = dequeueReusableSupplementaryView(ofKind: forSupplementaryViewOfKind, withReuseIdentifier: String(describing: T.self), for: indexPath)
        guard let viewType = view as? T else {
            fatalError("Unable to dequeue:\(viewClass)")
        }
        return viewType
    }
}
