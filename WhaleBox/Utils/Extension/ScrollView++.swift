//
//  ScrollViewExtension.swift
//  BrainV2
//
//  Created by 云天明 on 2021/12/13.
//  Copyright © 2021 Wade. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    func screenshot(_ bottomPadding : CGFloat = 0) -> UIImage? {
        // begin image context
        UIGraphicsBeginImageContextWithOptions(CGSize.init(width: contentSize.width, height: contentSize.height - bottomPadding), false, 0.0)
        // save the orginal offset & frame
        let savedContentOffset = contentOffset
        let savedFrame = frame
        // end ctx, restore offset & frame before returning
        defer {
            UIGraphicsEndImageContext()
            contentOffset = savedContentOffset
            frame = savedFrame
        }
        // change the offset & frame so as to include all content
        contentOffset = .zero
        frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height - bottomPadding)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return nil
        }
        layer.render(in: ctx)
        let image = UIGraphicsGetImageFromCurrentImageContext()

        return image
    }
    
}

extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        guard let layoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect) else { return [] }
        return layoutAttributes.map { $0.indexPath }
    }
}
