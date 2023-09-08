//
//  NewsDetailVC.swift
//  WhaleBox
//
//  Created by 刘思源 on 2023/9/6.
//

import UIKit
import Kingfisher
import JXPhotoBrowser

class NewsDetailVC: BaseVC {
    
    let news: News
    
    init(news: News) {
        self.news = news
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let stackView = UIStackView()
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(kScreenWidth)
        }
        stackView.axis = .vertical
        stackView.alignment = .leading
        
        stackView.addSpacing(30)
        
        let insets = UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 16)
        
        let titleLabel = UILabel()
        titleLabel.chain.text(color: .kTextBlack).font(.semibold(32)).numberOfLines(0)
        stackView.addArrangedSubview(titleLabel.wrappedBy(insets))
        titleLabel.text = news.title
        
        stackView.addSpacing(20)
        
        let authorLabel = UILabel()
        authorLabel.chain.text(color: .kTextDrakGray).font(.systemFont(ofSize: 12)).text("南方+客户端")
        stackView.addArrangedSubview(authorLabel.wrappedBy(insets))
        
        stackView.addSpacing(10)
        
        let timeLabel = UILabel()
        timeLabel.chain.text(color: .kTextDrakGray).font(.systemFont(ofSize: 12))
        timeLabel.text = news.publish_time
        stackView.addArrangedSubview(timeLabel.wrappedBy(insets))
        
        stackView.addSpacing(30)
        
        let coverImageView = UIImageView()
        coverImageView.snp.makeConstraints { make in
            make.width.equalTo(kScreenWidth)
            make.height.equalTo(kScreenWidth * 0.6)
        }
        stackView.addArrangedSubview(coverImageView)
        coverImageView.kf.setImage(with: URL(subPath: news.img_url)) { resutl in
            if case .success(let result) = resutl{
                coverImageView.snp.updateConstraints { make in
                    make.height.equalTo(result.image.size.height/result.image.size.width * kScreenWidth)
                }
            }
        }
        
        stackView.addSpacing(30)
        
        let contentLabel = UILabel()
        contentLabel.chain.font(.systemFont(ofSize: 16)).text(color: .kTextBlack).numberOfLines(0)
        stackView.addArrangedSubview(contentLabel.wrappedBy(insets))
        
        let ps = NSMutableParagraphStyle()
        ps.lineSpacing = 8
        
        let text = NSMutableAttributedString(news.detail_content, color: .kTextBlack, font: .systemFont(ofSize: 16))
        text.setAttributes([
            .paragraphStyle: ps
        ], range: text.range)
        
        contentLabel.attributedText = text
        
        for image in news.detail_imgs {
            stackView.addSpacing(10)
            let imageView = UIImageView()
            imageView.snp.makeConstraints { make in
                make.width.equalTo(kScreenWidth)
                make.height.equalTo(kScreenWidth * 0.6)
            }
            
            imageView.kf.setImage(with: URL(subPath: image)) { resutl in
                if case .success(let result) = resutl{
                    coverImageView.snp.updateConstraints { make in
                        make.height.equalTo(result.image.size.height/result.image.size.width * kScreenWidth)
                    }
                }
            }
            stackView.addArrangedSubview(imageView)
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(UITapGestureRecognizer(actionBlock: {[weak self] _ in
                guard let self = self else {return}
                let browser = JXPhotoBrowser()
                // 浏览过程中实时获取数据总量
                browser.numberOfItems = { [weak self] in
                    guard let self = self else {return 0}
                    return self.news.detail_imgs.count
                }
                // 刷新Cell数据。本闭包将在Cell完成位置布局后调用。
                browser.reloadCellAtIndex = { [weak self] context in
                    guard let self = self else {return}
                    let browserCell = context.cell as? JXPhotoBrowserImageCell
                    browserCell?.imageView.kf.setImage(with: URL(subPath: self.news.detail_imgs[context.index]))
                }
                browser.pageIndex = self.news.detail_imgs.indexOf(image)!
                browser.show()
            }))
        }
    }
}
