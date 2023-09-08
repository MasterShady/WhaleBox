//
//  CircleVC.swift
//  WhaleBox
//
//  Created by 刘思源 on 2023/9/4.
//

import UIKit
import Kingfisher
import HandyJSON
import MJRefresh
import YYKit

extension String {
    func toImage() -> UIImage?{
        let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters)!
        let image = UIImage(data: data)
        return image
    }
}


class PostModel: HandyJSON{
    var id : Int!
    var title: String!
    var content: String!
    var images = [String]()
    var create_time: String!
    var userInfo: UserInfo!
    var is_collect = false
    
    func userAvatar(size: CGFloat = 30) -> UIImage{
        if let avatar = userInfo.avatar{
            return avatar.toImage()!.byResize(to: CGSize(width: size, height: size))!
        }else{
            return .init(named: "user_avatar")!.byResize(to: CGSizeMake(size, size))!
        }
    }
    
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.images <-- StringToArrayTransform()
    }
    
    required init() {
        
    }
}



struct UserInfo: HandyJSON{
    var id: Int!
    var nickname: String!
    var phone: String!
    var avatar: String?
}


private let kImagespacing = 20.0
private let kImageWH = (kScreenWidth - 14 * 2 - kImagespacing * 2) / 3

class PostCell: UITableViewCell{
    var titleLabel : UILabel!
    var contentLabel : UILabel!
    var userAvatar : UIButton!
    var timeLabel: UILabel!
    lazy var singleImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.chain.corner(radius: 5).clipsToBounds(true).contentMode(.scaleAspectFit).backgroundColor(.kExLightGray)
        return imageView
    }()
    
    lazy var imageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = kImagespacing
        return stackView
    }()
    
    var post: PostModel? {
        didSet{
            guard let post = post else {return}
            if post.images.count > 1{
                singleImageView.removeFromSuperview()
                imageStackView.removeAllSubviews()
                contentView.addSubview(imageStackView)
                titleLabel.snp.remakeConstraints { make in
                    make.top.equalTo(8)
                    make.left.equalTo(14)
                    make.right.equalTo(-14)
                }
                contentLabel.snp.remakeConstraints { make in
                    make.left.equalTo(titleLabel)
                    make.top.equalTo(titleLabel.snp.bottom).offset(12)
                    make.right.equalTo(-14)
                    make.height.lessThanOrEqualTo(50)
                }
                
                imageStackView.snp.remakeConstraints { make in
                    make.top.equalTo(contentLabel.snp.bottom).offset(10)
                    make.height.equalTo(kImageWH)
                    make.left.equalTo(14)
                }
                
                userAvatar.snp.remakeConstraints { make in
                    make.height.equalTo(30)
                    make.top.equalTo(imageStackView.snp.bottom).offset(10)
                    make.left.equalTo(14)
                    make.bottom.equalTo(-8)
                }
                
                for image in post.images{
                    let imageView = UIImageView()
                    imageView.snp.makeConstraints { make in
                        make.width.height.equalTo(kImageWH)
                    }
                    imageView.image = image.toImage()
                    imageView.chain.corner(radius: 5).clipsToBounds(true).contentMode(.scaleAspectFit).backgroundColor(.kExLightGray)
                    
                    imageStackView.addArrangedSubview(imageView)
                }
                
            }else{
                let hasImage = post.images.count == 1
                
                imageStackView.removeFromSuperview()
                if hasImage{
                    contentView.addSubview(singleImageView)
                }else{
                    singleImageView.removeFromSuperview()
                }
                titleLabel.snp.remakeConstraints { make in
                    make.top.equalTo(8)
                    make.left.equalTo(14)
                    if !hasImage{
                        make.right.equalTo(-14)
                    }
                }
                contentLabel.snp.remakeConstraints { make in
                    make.left.equalTo(titleLabel)
                    make.top.equalTo(titleLabel.snp.bottom).offset(12)
                    make.bottom.lessThanOrEqualTo(self.singleImageView)
                    if !hasImage{
                        make.right.equalTo(-14)
                    }
                }
                if (hasImage) {
                    singleImageView.snp.makeConstraints { make in
                        make.top.equalTo(titleLabel)
                        make.right.equalTo(-14)
                        make.left.equalTo(titleLabel.snp.right).offset(10)
                        make.left.equalTo(contentLabel.snp.right).offset(10)
                        make.width.height.equalTo(kImageWH)
                    }
                    singleImageView.image = post.images[0].toImage()
                }
                

                userAvatar.snp.makeConstraints { make in
                    make.height.equalTo(30)
                    make.top.equalTo(contentLabel.snp.bottom).offset(10)
                    make.left.equalTo(14)
                    make.bottom.equalTo(-8)
                }
            }
            
            titleLabel.text = post.title
            contentLabel.text = post.content
            
            if let avatar = post.userInfo.avatar{
                let data = Data(base64Encoded: avatar, options: .ignoreUnknownCharacters)!
                let image = UIImage(data: data)?.resizeImageToSize(size: CGSize(width: 30, height: 30))
                userAvatar.chain.normalImage(image).normalTitle(text: post.userInfo.nickname)
                userAvatar.setImagePosition(.left, spacing: 8)
            }else{
                let image = UIImage(named: "user_avatar")?.resizeImageToSize(size: CGSize(width: 30, height: 30))
                userAvatar.chain.normalImage(image).normalTitle(text: post.userInfo.nickname)
                userAvatar.setImagePosition(.left, spacing: 8)
            }
            timeLabel.text = post.create_time

        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configSubviews(){
        self.selectionStyle = .none
        titleLabel = UILabel()
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.left.equalTo(14)
            
        }
        titleLabel.chain.text(color: .kTextBlack).font(.semibold(16)).numberOfLines(2)
        
        contentLabel = UILabel()
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            
        }
        contentLabel.chain.text(color: .kTextBlack).font(.systemFont(ofSize: 14)).numberOfLines(0)
        
        userAvatar = UIButton()
        contentView.addSubview(userAvatar)
        userAvatar.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(10)
            make.left.equalTo(14)
            make.bottom.equalTo(-8)
        }
        userAvatar.chain.normalTitleColor(color: .kTextBlack).font(.systemFont(ofSize: 14))
        
        timeLabel = UILabel()
        contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.right.equalTo(-14)
            make.centerY.equalTo(userAvatar)
        }
        timeLabel.chain.text(color: .kTextLightGray).font(.systemFont(ofSize: 14))
        
        let sep = UIView()
        contentView.addSubview(sep)
        sep.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.height.equalTo(0.5)
            make.bottom.equalTo(0)
        }
        sep.backgroundColor = .kSepLineColor
    }
}

class CircleVC: BaseVC {
    var userAvatar : UIButton!
    var tableView: UITableView!
    
    var posts = [PostModel]()
    
    override func configNavigationBar() {
        self.navigationItem.title = "圈子"
        userAvatar = UIButton(frame: CGRectMake(0, 0, 32, 32))
        userAvatar.snp.makeConstraints { make in
            make.width.height.equalTo(32)
        }
        userAvatar.chain.corner(radius: 16).clipsToBounds(true)
        let item = UIBarButtonItem(customView: userAvatar)
        userAvatar.addBlock(for: .touchUpInside) {[weak self] _ in
            UserStore.checkLoginStatusThen {
                self?.navigationController?.pushViewController(MineVC(), animated: true)
            }
        }
        
        self.navigationItem.rightBarButtonItem = item
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUserInfo()
    }
    
    
    func updateUserInfo(){
        if UserStore.isLogin{
            userAvatar.chain.normalImage(UserStore.currentUser?.avatarImage)
        }else{
            userAvatar.chain.normalImage(.init(named: "user_avatar"))
        }
    }

    override func configData() {
        tableView = UITableView()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.register(PostCell.self)
        
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.loadPosts()
        })
    }
    
    override func networkRequest() {
        tableView.mj_header?.beginRefreshing()
    }
    
    func loadPosts(){
        userService.request(.postList()) {[weak self] result in
            self?.tableView.mj_header?.endRefreshing()
            result.hj_map2(PostModel.self) { body, error in
                guard let body = body else {return}
                self?.posts = body.decodedObjList!
                self?.tableView.reloadData()
            }
        }
    }
    

}

extension CircleVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(PostCell.self)
        cell.post = posts[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = PostDetailVC(post:posts[indexPath.row])
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}
