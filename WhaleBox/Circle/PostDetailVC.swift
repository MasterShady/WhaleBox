//
//  PostDetailVC.swift
//  WhaleBox
//
//  Created by 刘思源 on 2023/9/7.
//

import UIKit
import JXPhotoBrowser
import MJRefresh
import HandyJSON



extension UITextField {
    func setLeftSpacing(spacing: CGFloat){
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: 0))
        self.leftViewMode = .always
    }
}

class PostDetailVC: BaseVC {
    
    var commentField: UITextField!
    
    var scrollView: UIScrollView!
    var comments = [PostModel]() {
        didSet{
            updateComments()
        }
    }
    
    var post : PostModel
    var likeBtn : UIButton!
    
    init(post: PostModel) {
        self.post = post
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configNavigationBar() {
        likeBtn = UIButton()
        likeBtn.chain.normalImage(.init(named: "collect_normal")).selectedImage(.init(named: "collect_selected"))
        likeBtn.snp.makeConstraints { make in
            make.width.height.equalTo(32)
        }
        
        likeBtn.addBlock(for: .touchUpInside) {[weak self] _ in
            guard let self = self else {return}
            self.post.is_collect.toggle()
            self.likeBtn.isSelected = self.post.is_collect
            self.requestCollect()
        }
        likeBtn.isSelected = post.is_collect
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: likeBtn)
    }
    
    
    override func configSubViews() {
        view.backgroundColor = .white
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.left.right.equalTo(0)
        }
        scrollView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.loadComments()
        })
        
        
        view.addSubview(bottomBar)
        bottomBar.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom)
            make.left.right.bottom.equalTo(0)
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
        titleLabel.text = post.title
        
        stackView.addSpacing(20)
        
        let authorBtn = UIButton()
        let userAvatar = post.userAvatar()
        
        
        authorBtn.chain.normalTitleColor(color: .kTextDrakGray).font(.systemFont(ofSize: 12)).normalTitle(text: post.userInfo.nickname).normalImage(userAvatar)
        authorBtn.setImagePosition(.left, spacing: 10)
        stackView.addArrangedSubview(authorBtn.wrappedBy(insets))
        
        stackView.addSpacing(10)
        
        let timeLabel = UILabel()
        timeLabel.chain.text(color: .kTextDrakGray).font(.systemFont(ofSize: 12))
        timeLabel.text = post.create_time
        stackView.addArrangedSubview(timeLabel.wrappedBy(insets))
        
        stackView.addSpacing(30)

        
        let contentLabel = UILabel()
        contentLabel.chain.font(.systemFont(ofSize: 16)).text(color: .kTextBlack).numberOfLines(0)
        stackView.addArrangedSubview(contentLabel.wrappedBy(insets))
        
        let ps = NSMutableParagraphStyle()
        ps.lineSpacing = 8
        
        let text = NSMutableAttributedString(post.content, color: .kTextBlack, font: .systemFont(ofSize: 16))
        text.setAttributes([
            .paragraphStyle: ps
        ], range: text.range)
        
        contentLabel.attributedText = text
        
        for imageString in post.images {
            stackView.addSpacing(10)
            let imageView = UIImageView()
            if imageString.isBase64String {
                
                let image = imageString.toImage()!
                imageView.snp.makeConstraints { make in
                    make.width.equalTo(kScreenWidth)
                    make.height.equalTo(kScreenWidth * image.size.height/image.size.width)
                }
                imageView.image = image
            }else{
                
                imageView.kf.setImage(with: URL(subPath: imageString)) { result in
                    if case .success(let result) = result{
                        imageView.snp.updateConstraints { make in
                            make.height.equalTo(result.image.size.height/result.image.size.width * kScreenWidth)
                        }
                    }
                }
            }
            
            stackView.addArrangedSubview(imageView)
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(UITapGestureRecognizer(actionBlock: { [weak self] _ in
                guard let self = self else {return}
                let browser = JXPhotoBrowser()
                // 浏览过程中实时获取数据总量
                browser.numberOfItems = { [weak self] in
                    guard let self = self else { return 0 }
                    return self.post.images.count
                }
                // 刷新Cell数据。本闭包将在Cell完成位置布局后调用。
                browser.reloadCellAtIndex = { [weak self] context in
                    guard let self = self else {return}
                    let browserCell = context.cell as? JXPhotoBrowserImageCell
                    
                    browserCell?.imageView.image = self.post.images[context.index].toImage()
                }
                browser.pageIndex = self.post.images.indexOf(imageString)!
                browser.show()
            }))
        }
        
        stackView.addArrangedSubview(commentView)
    }
    
    override func networkRequest() {
        self.scrollView.mj_header?.beginRefreshing()
    }
    
    func loadComments(){
        userService.request(.commentList(id: post.id)) {[weak self] result in
            guard let self = self else {return}
            self.scrollView.mj_header?.endRefreshing()
            result.hj_map2(PostModel.self) { body, error in
                if let error = error{
                    error.msg.hint()
                    return
                }
                self.comments = body!.decodedObjList!
            }
        }
    }
    
    func requestCollect(){
        UserStore.checkLoginStatusThen {
            userService.request(.collectPost(postId: post.id, collect: self.post.is_collect)) {[weak self] result in
                guard let self = self else {return}
                result.hj_map2 { body, error in
                    if let error = error{
                        error.msg.hint()
                        return
                    }
                    
                }
                (self.post.is_collect ? "收藏成功!" : "取消成功").hint()
            }
        }
        
    }
    
    func updateComments(){
        commentStackView.removeSubviews()
        if comments.count > 0{
            for comment in comments{
                let commentCell = UIView()
                commentCell.snp.makeConstraints { make in
                    make.width.equalTo(kScreenWidth)
                }
                let userAvatar = UIImageView()
                commentCell.addSubview(userAvatar)
                userAvatar.snp.makeConstraints { make in
                    make.top.left.equalTo(14)
                    make.width.height.equalTo(30)
                }
                userAvatar.chain.corner(radius: 15).clipsToBounds(true)
                userAvatar.image = post.userAvatar(size: 100)
                
                let userNameLabel = UILabel()
                commentCell.addSubview(userNameLabel)
                userNameLabel.snp.makeConstraints { make in
                    make.left.equalTo(userAvatar.snp.right).offset(10)
                    make.centerY.equalTo(userAvatar)
                }
                userNameLabel.chain.text(post.userInfo.nickname).text(color: .kTextBlack).font(.systemFont(ofSize: 14))
                
                let contentLabel = UILabel()
                commentCell.addSubview(contentLabel)
                contentLabel.snp.makeConstraints { make in
                    make.top.equalTo(userNameLabel.snp.bottom).offset(10)
                    make.left.equalTo(userNameLabel)
                    make.right.equalTo(-14)
                }
                contentLabel.chain.text(color: .kTextBlack).font(.systemFont(ofSize: 14)).numberOfLines(0)
                contentLabel.text = comment.content
                
                let timeLabel = UILabel()
                commentCell.addSubview(timeLabel)
                timeLabel.snp.makeConstraints { make in
                    make.top.equalTo(contentLabel.snp.bottom).offset(10)
                    make.right.equalTo(-14)
                    make.bottom.equalTo(-14)
                }
                timeLabel.chain.text(comment.create_time).font(.systemFont(ofSize: 14)).text(color: .kTextDrakGray)
                
                let sep = UIView()
                commentCell.addSubview(sep)
                sep.snp.makeConstraints { make in
                    make.left.right.bottom.equalToSuperview()
                    make.height.equalTo(0.5)
                }
                sep.backgroundColor = .kSepLineColor
                commentStackView.addArrangedSubview(commentCell)
            }
        }else{
            let emptyView = UIStackView()
            emptyView.snp.makeConstraints { make in
                make.width.equalTo(kScreenWidth)
            }
            emptyView.axis = .vertical
            emptyView.alignment = .center
            emptyView.spacing = 20
            
            let imageView = UIImageView()
            imageView.image = .init(named: "no-comment")
            imageView.snp.makeConstraints { make in
                make.width.height.equalTo(100)
            }
            emptyView.addArrangedSubview(imageView)
            
            let titleLabel = UILabel()
            titleLabel.chain.text("暂无评论哦, 去抢沙发吧~").text(color: .kTextLightGray).font(.systemFont(ofSize: 14))
            emptyView.addArrangedSubview(titleLabel)
            
            commentStackView.addArrangedSubview(emptyView.wrappedBy(.init(top: 30, left: 0, bottom: 30, right: 0)))
            
        }
    }
    
    func makeComment(_ comment: String){
        userService.request(.makeComment(pid: post.id, content: comment)) { result in
            result.hj_map2 { body, error in
                if let error = error{
                    error.msg.hint()
                    return
                }
                "评论成功".hint()
                self.commentField.endEditing(true)
                self.commentField.text = nil
                self.scrollView.mj_header?.beginRefreshing()
            }
        }
    }
    
    
    lazy var bottomBar : UIView = {
        let bottomBar = UIView()
        bottomBar.snp.makeConstraints { make in
            make.height.equalTo(kBottomSafeInset + 50)
        }
        bottomBar.backgroundColor = .white
        
        let bottomCotainer = UIView()
        bottomBar.addSubview(bottomCotainer)
        bottomCotainer.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        let textFiled = UITextField()
        commentField = textFiled
        bottomCotainer.addSubview(textFiled)
        textFiled.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.left.equalTo(14)
            make.height.equalTo(34)
        }
        textFiled.chain.text(color: .kTextBlack).attributedPlaceholder(.init("留下你的睿评吧~", color: .kTextLightGray, font: .systemFont(ofSize: 16))).font(.systemFont(ofSize: 14)).corner(radius: 17).clipsToBounds(true).border(width: 1).border(color: .kSepLineColor)
        
        textFiled.setLeftSpacing(spacing: 10)
        
        let sendBtn = UIButton()
        bottomCotainer.addSubview(sendBtn)
        sendBtn.snp.makeConstraints { make in
            make.top.equalTo(9)
            make.right.equalTo(-14)
            make.width.equalTo(54)
            make.height.equalTo(34)
            make.left.equalTo(textFiled.snp.right).offset(14)
        }
        sendBtn.chain.backgroundColor(.kThemeColor).normalTitle(text: "发送").font(.semibold(16)).normalTitleColor(color: .kTextBlack).corner(radius: 17).clipsToBounds(true)
        sendBtn.addBlock(for: .touchUpInside) {[weak self] _ in
            if textFiled.text?.count ?? 0 > 0 {
                self?.makeComment(textFiled.text!)
            } else{
                "请输入评论哦~".hint()
            }
        }
        
        
        return bottomBar
    }()
    
    var commentStackView : UIStackView!
    
    lazy var commentView : UIView = {
        let commentView = UIView()
        let titleLabel = UILabel()
        commentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(14)
            make.left.equalTo(14)
        }
        titleLabel.chain.font(.semibold(16)).text(color: .kTextBlack).text("评论列表")
        
        commentStackView = UIStackView()
        commentStackView.axis = .vertical
        commentStackView.alignment = .center
        commentView.addSubview(commentStackView)
        commentStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.width.equalTo(kScreenWidth)
            make.bottom.equalToSuperview()
        }

        return commentView
    }()

}
