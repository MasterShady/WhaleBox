//
//  UIImage++.swift
//  ferental
//
//  Created by 刘思源 on 2022/12/27.
//

import Foundation

extension UIImage{
    convenience init(safeNamed name: String, color: UIColor = .clear) {
        let image = UIImage(named: name)
        ?? .init(color: color)!
        self.init(cgImage: image.cgImage!)
    }
}

