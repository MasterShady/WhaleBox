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
import FTPopOverMenu_Swift

class PostBlackListManager {
    
    static var blackList : [Int] {
        return UserDefaults.standard.array(forKey: "PostBlackList") as? [Int] ?? [Int]()
    }
    
    static func addPost(id : Int){
        var list = self.blackList
        list.append(id)
        UserDefaults.standard.set(list, forKey: "PostBlackList")
        UserDefaults.standard.synchronize()
    }
}

extension UIImageView {
    func configImageWithString(image: String){
        if image.isBase64String {
            self.image = image.toImage()
        }else{
            self.kf.setImage(with: URL(subPath: image))
        }
    }
}

extension String {
    
    var isBase64String : Bool {
        if self.count == 0 {return false}
        let base64Pattern = #"^[A-Za-z0-9+/]*={0,2}$"#

        if let regex = try? NSRegularExpression(pattern: base64Pattern, options: []) {
            let range = NSRange(location: 0, length: self.utf16.count)
            if regex.firstMatch(in: self, options: [], range: range) != nil {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
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
            return avatar.toImage()!.byResize(to: CGSize(width: size, height: size))!.byRoundCornerRadius(size/2)!
        }else{
            return .init(named: "user_avatar")!.byResize(to: CGSizeMake(size, size))!.byRoundCornerRadius(size/2)!
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

class PostCell: UITableViewCell, UIAdaptivePresentationControllerDelegate{
    var titleLabel : UILabel!
    var contentLabel : UILabel!
    var userAvatar : UIButton!
    var timeLabel: UILabel!
    
    var menuClickHandler : IntBlock?
    
    
    
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
                    //make.right.equalTo(-14)
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
                    imageView.configImageWithString(image: image)
                    
                    
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
//                    if !hasImage{
//                        make.right.equalTo(-14)
//                    }
                }
                contentLabel.snp.remakeConstraints { make in
                    make.left.equalTo(titleLabel)
                    make.top.equalTo(titleLabel.snp.bottom).offset(12)
                    if !hasImage{
                        make.right.equalTo(-14)
                        make.height.lessThanOrEqualTo(150)
                    }else{
                        make.bottom.lessThanOrEqualTo(self.singleImageView)
                    }
                }
                if (hasImage) {
                    singleImageView.snp.remakeConstraints { make in
                        make.top.equalTo(contentLabel)
                        make.right.equalTo(-14)
                        make.left.equalTo(titleLabel.snp.right).offset(10)
                        make.left.equalTo(contentLabel.snp.right).offset(10)
                        make.width.height.equalTo(kImageWH)
                        make.bottom.lessThanOrEqualTo(self.timeLabel.snp.top).offset(-14)
                    }
                    //singleImageView.image = post.images[0].toImage()
                    singleImageView.configImageWithString(image: post.images[0])
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
            
//            if let avatar = post.userInfo.avatar{
//                let data = Data(base64Encoded: avatar, options: .ignoreUnknownCharacters)!
//                let image = UIImage(data: data)?.resizeImageToSize(size: CGSize(width: 30, height: 30))
//                userAvatar.chain.normalImage(image).normalTitle(text: post.userInfo.nickname)
//                userAvatar.setImagePosition(.left, spacing: 8)
//            }else{
//                let image = UIImage(named: "user_avatar")?.resizeImageToSize(size: CGSize(width: 30, height: 30))
//                userAvatar.chain.normalImage(image).normalTitle(text: post.userInfo.nickname)
//                userAvatar.setImagePosition(.left, spacing: 8)
//            }
            
            userAvatar.chain.normalImage(post.userAvatar()).normalTitle(text: post.userInfo.nickname)
            userAvatar.setImagePosition(.left, spacing: 8)
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
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        let moreBtn = UIButton()
        contentView.addSubview(moreBtn)
        moreBtn.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(8)
            make.right.equalTo(-14)
            make.width.equalTo(40)
            make.height.equalTo(20)
        }
        moreBtn.chain.normalImage(.init(named: "more")).corner(radius: 10).clipsToBounds(true).border(color: .kSepLineColor).border(width: 1)
        moreBtn.imageView?.contentMode = .center
        
        moreBtn.addTarget(self, action: #selector(clickMore(sender:)), for: .touchUpInside)
        
        
        
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
    
    @objc func clickMore(sender: UIButton){
        let configuration = FTConfiguration()
        configuration.textAlignment = .center
        
        FTPopOverMenu.showForSender(sender: sender,
                                    with: ["举报", "不喜欢"],
                                    config: configuration,
                                    done: {[weak self] (selectedIndex) -> () in
            
            self?.menuClickHandler?(selectedIndex)
        }) {
            
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
           return UIModalPresentationStyle.none
       }

       
       func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
           return UIModalPresentationStyle.none
       }
}

class PostListVC: BaseVC {
    let cat: String
    //var userAvatar : UIButton!
    var tableView: UITableView!
    
    var posts = [PostModel]()
    
    init(cat: String) {
        self.cat = cat
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configNavigationBar() {
        self.navigationItem.title = self.cat
//        userAvatar = UIButton(frame: CGRectMake(0, 0, 32, 32))
//        userAvatar.snp.makeConstraints { make in
//            make.width.height.equalTo(32)
//        }
//        userAvatar.chain.corner(radius: 16).clipsToBounds(true)
//        let item = UIBarButtonItem(customView: userAvatar)
//        userAvatar.addBlock(for: .touchUpInside) {[weak self] _ in
//            UserStore.checkLoginStatusThen {
//                self?.navigationController?.pushViewController(MineVC(), animated: true)
//            }
//        }
//
//        self.navigationItem.rightBarButtonItem = item
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUserInfo()
    }
    
    
    func updateUserInfo(){
//        if UserStore.isLogin{
//            userAvatar.chain.normalImage(UserStore.currentUser?.avatarImage)
//        }else{
//            userAvatar.chain.normalImage(.init(named: "user_avatar"))
//        }
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
        userService.request(.postList(type: 0, atype: cat.toGameCat)) {[weak self] result in
            self?.tableView.mj_header?.endRefreshing()
            result.hj_map2(PostModel.self) { body, error in
                guard let body = body else {return}
                self?.posts = body.decodedObjList!.filter({ post in
                    !PostBlackListManager.blackList.contains(post.id)
                })
                self?.tableView.reloadData()
            }
        }
    }
    

}

extension PostListVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(PostCell.self)
        let post = posts[indexPath.row]
        cell.post = post
        cell.menuClickHandler = { [weak self] index in
            if index == 0{
                //举报
                let reportView = ReportView()
                reportView.dismissHandler = { result in
                    if result{
                        PostBlackListManager.addPost(id: post.id)
                        "感谢您的反馈,我们将进行审核".hint()
                        self?.posts = self?.posts.filter({ post in
                            return !PostBlackListManager.blackList.contains(post.id)
                        }) ?? .init()
                        tableView.reloadData()
                    }
                }
                reportView.popView(fromDirection: .center, tapToDismiss: false)
            }else{
                //不喜欢
                PostBlackListManager.addPost(id: post.id)
                "感谢您的反馈,我们将减少此类推荐".hint()
                self?.posts = self?.posts.filter({ post in
                    !PostBlackListManager.blackList.contains(post.id)
                }) ?? .init()
                tableView.reloadData()
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = PostDetailVC(post:posts[indexPath.row])
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}
