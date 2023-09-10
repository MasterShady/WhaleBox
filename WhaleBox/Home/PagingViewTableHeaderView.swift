//
//  PagingViewTableHeaderView.swift
//  JXPagingView
//
//  Created by jiaxin on 2018/5/28.
//  Copyright © 2018年 jiaxin. All rights reserved.
//

import UIKit

class PagingViewTableHeaderView: UIView {
    var imageView: UIImageView!
    var imageViewFrame: CGRect!

    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView = UIImageView(image: UIImage(named: "header_bg"))
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        self.addSubview(imageView)

        imageViewFrame = imageView.frame
        
        let cardView = UIImageView()
        addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.top.equalTo(kStatusBarHeight + 20)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.width.equalTo(cardView.snp.height).multipliedBy(2)
        }
        cardView.chain.backgroundColor(.yellow).corner(radius: 12).clipsToBounds(true)
        
        let searchBar = UIButton()
        addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.left.equalTo(cardView).offset(20)
            make.right.equalTo(cardView).offset(-20)
            make.centerY.equalTo(cardView.snp.bottom)
            make.height.equalTo(44)
        }
        searchBar.chain.backgroundColor(.white).corner(radius: 22).clipsToBounds(true)
        searchBar.addBlock(for: .touchUpInside) { _ in
            let vc = SearchVC()
            UIViewController.getCurrentNav().pushViewController(vc, animated: true)
        }
        
        let icon = UIImageView()
        searchBar.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.centerY.equalToSuperview()
        }
        icon.chain.image(.init(named: "search_icon")!.byResize(to: CGSize(width: 20, height: 20)))
        
        let placeholder = UILabel()
        searchBar.addSubview(placeholder)
        placeholder.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(14)
            make.centerY.equalToSuperview()
        }
        placeholder.chain.text(color:.kTextLightGray).font(.systemFont(ofSize: 14)).text("请输入关键词")
        
        let rightArrow = UIImageView()
        searchBar.addSubview(rightArrow)
        rightArrow.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.right.equalTo(-5)
            make.size.equalTo(CGSize(width: 34, height: 34))
        }
        
        let rightArrowIcon = UIImage(named: "right_arrow")!.withTintColor(.white).byResize(to: CGSize(width: 20, height: 20))
        rightArrow.chain.backgroundColor(.black).image(rightArrowIcon).contentMode(.center).corner(radius: 17).clipsToBounds(true)
        

    }

    func scrollViewDidScroll(contentOffsetY: CGFloat) {
        var frame = imageViewFrame!
        frame.size.height -= contentOffsetY
        frame.origin.y = contentOffsetY
        imageView.frame = frame
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
