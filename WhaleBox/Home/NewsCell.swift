//
//  PagingListBaseCell.swift
//  JXSegmentedViewExample
//
//  Created by blue on 2020/6/19.
//  Copyright © 2020 jiaxin. All rights reserved.
//

import UIKit

class NewsCell: UITableViewCell {
    
    var titleLabel : UILabel!
    var contentLabel : UILabel!
    var timeLabel : UILabel!
    
    var model: News? {
        didSet{
            titleLabel.text = model?.title
            contentLabel.text = model?.detail_content
            timeLabel.text = model?.publish_time
        }
    }
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        self.selectionStyle = .none
        backgroundColor = .white
        titleLabel = UILabel()
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(12)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        titleLabel.chain.text(color: .kTextBlack).font(.semibold(16)).numberOfLines(0)
        
        contentLabel = UILabel()
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        contentLabel.chain.text(color: .kTextDrakGray).font(.systemFont(ofSize: 14)).numberOfLines(6)
        
        timeLabel = UILabel()
        contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.right.equalTo(-20)
            make.bottom.equalTo(-12)
            make.top.equalTo(contentLabel.snp.bottom).offset(8)
        }
        timeLabel.chain.text(color: .kTextDrakGray).font(.systemFont(ofSize: 14)).numberOfLines(0)
        timeLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        let sep = UIView()
        contentView.addSubview(sep)
        sep.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(2)
            make.bottom.equalTo(0)
        }
        sep.backgroundColor = .kSepLineColor
    }

}
