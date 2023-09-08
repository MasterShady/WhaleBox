//
//  MineVC.swift
//  WhaleBox
//
//  Created by 刘思源 on 2023/9/7.
//

import UIKit
import CLImagePickerTool
import Kingfisher

class MineVC: BaseVC {
    
    var userAvatar : UIButton!
    var userNameBtn : UIButton!
    
    var stackView: UIStackView!
    var logoutBtn: UIButton!
    var deregisterCell: UIView!

    
    lazy var header : UIView = {
        let header = UIView()
        header.layer.contents = UIImage(named: "header_bg")?.cgImage
        userAvatar = UIButton()
        header.addSubview(userAvatar)
        userAvatar.snp.makeConstraints { make in
            make.top.equalTo(24 + kNavBarMaxY)
            make.left.equalTo(24)
            make.width.height.equalTo(56)
        }
        userAvatar.chain.corner(radius: 28).clipsToBounds(true).border(color: .kSepLineColor).border(width: 1)
        userAvatar.addBlock(for: .touchUpInside) {[weak self] _ in
            UserStore.checkLoginStatusThen {
                //更换图片
                self?.updateUserAvatar()
            }
        }
        
        userNameBtn = UIButton()
        header.addSubview(userNameBtn)
        userNameBtn.snp.makeConstraints { make in
            make.left.equalTo(userAvatar.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        userNameBtn.chain.font(.semibold(20)).normalTitleColor(color: .kTextBlack)

        userNameBtn.addBlock(for: .touchUpInside) {[weak self] _ in
            UserStore.checkLoginStatusThen {
                self?.updateUserName()
            }
        }

        return header
    }()
    
    lazy var imagePickTool : CLImagePickerTool = {
        let imagePickTool = CLImagePickerTool.init()
        imagePickTool.isHiddenVideo = true
        imagePickTool.cameraOut = true //设置相机选择在外部
        imagePickTool.singleImageChooseType = .singlePicture //单选模式
        imagePickTool.singleModelImageCanEditor = true //设置单选模式下图片可以编辑涂鸦
        return imagePickTool
    }()
    
    
    func updateUserAvatar(){
        //使用asset来转化自己想要的指定压缩大小的图片，cutImage只有在单选剪裁的情况下才返回,其他情况返回nil
        imagePickTool.cl_setupImagePickerWith(MaxImagesCount: 1, superVC: self) {[weak self] (assets, cutImage) in
            guard let image = cutImage else { return }
            
            let base64Avatar = image.jpegData(compressionQuality: 0.1)!.base64EncodedString()
            
            userService.request(.updateUser(nickname: UserStore.currentUser!.nickname, avatar: base64Avatar)) { result in
                result.hj_map2 { body, error in
                    if let error = error{
                        error.msg.hint()
                        return
                    }
                    "修改成功".hint()
                    UserStore.currentUser?.avatar = base64Avatar
                }
            }
        }
    }
    
    func updateUserName(){
        
    }

//    override func viewWillAppear(_ animated: Bool) {
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        self.navigationController?.setNavigationBarHidden(false, animated: true)
//    }
    
    override func configSubViews() {
        self.title = "我的"
        self.navBarBgAlpha = 0
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = .all
        
        
        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        
        
        header.snp.makeConstraints { make in
            make.height.equalTo(280)
            make.width.equalTo(kScreenWidth)
        }
        stackView.addArrangedSubview(header)
        
        let items = [
            ("我的收藏", { [weak self] in
                let vc = MyCollectionVC()
                self?.navigationController?.pushViewController(vc, animated: true)
            }),
            ("我的帖子", { [weak self] in
                let vc = MyPostVC()
                self?.navigationController?.pushViewController(vc, animated: true)
            }),
            ("清除缓存", {
                let alert = AEAlertView(style: .defaulted, title: "", message: "确定清楚缓存吗?")
                alert.addAction(action: .init(title: "确定", handler: {[weak alert] action in
                    alert?.dismiss()
                    ImageCache.default.clearMemoryCache()
                    ImageCache.default.cleanExpiredDiskCache()
                }))
                
                alert.addAction(action: .init(title: "取消", style: .cancel, handler: {[weak alert] action in
                    alert?.dismiss()
                }))
                alert.show()
            }),
            ("注销账号", {
                let alert = AEAlertView(style: .defaulted, title: "", message: "注销后数据不可恢复,确定要注销吗?")
                alert.addAction(action: .init(title: "确定", handler: {[weak alert] action in
                    userService.request(.deregister) { result in
                        result.hj_map2 { body, error in
                            if let error = error{
                                error.msg.hint()
                                return
                            }
                            alert?.dismiss()
                            "注销成功".hint()
                        }
                    }
                    UserStore.logout()

                }))
                
                alert.addAction(action: .init(title: "再想想", style: .cancel, handler: {[weak alert] action in
                    alert?.dismiss()
                }))
                alert.show()
            })
        ]
        
        
        for (title, action) in items{
            let cell = UIButton()
            cell.snp.makeConstraints { make in
                make.height.equalTo(44)
                make.width.equalTo(kScreenWidth)
            }
            
            let titleLabel = UILabel()
            cell.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.left.equalTo(14)
                make.centerY.equalToSuperview()
            }
            titleLabel.chain.text(title).text(color: .kTextBlack).font(.semibold(14))
            
            if title == "我的收藏" || title == "我的帖子"{
                let arrowImage = UIImage.init(named: "settings_arrow")?.withTintColor(.kTextBlack)
                let arrow = UIImageView(image: arrowImage)
                cell.addSubview(arrow)
                arrow.snp.makeConstraints { make in
                    make.right.equalTo(-14)
                    make.centerY.equalToSuperview()
                }
            }
            
            if title == "注销账号" {
                deregisterCell = cell
            }
           
            
            cell.addBlock(for: .touchUpInside) { _ in
                action()
            }
            
            stackView.addArrangedSubview(cell)
        }
        
        logoutBtn = UIButton()
        logoutBtn.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(44)
        }
        logoutBtn.chain.normalTitle(text: "退出登录").font(.systemFont(ofSize: 14)).normalTitleColor(color: .kTextLightGray)
        logoutBtn.addBlock(for: .touchUpInside) { _ in
            let alert = AEAlertView(style: .defaulted, title: "", message: "确定退出登录吗?")
            alert.addAction(action: .init(title: "确定", handler: {[weak alert] action in
                UserStore.logout()
                alert?.dismiss()
            }))
            
            alert.addAction(action: .init(title: "手滑了", style: .cancel, handler: {[weak alert] action in
                alert?.dismiss()
            }))
            alert.show()
        }
        
        stackView.addSpacing(30)
        stackView.addArrangedSubview(logoutBtn)
        
        updateUserStatus()
    
    }
    

    
    override func onUserChanged() {
        updateUserStatus()
    }
    
    func updateUserStatus(){
        
        if UserStore.isLogin {
            userAvatar.chain.normalImage(UserStore.currentUser!.avatarImage)
            userNameBtn.chain.normalTitle(text: UserStore.currentUser!.nickname)
        }else{
            userAvatar.chain.normalImage(.init(named: "user_avatar"))
            userNameBtn.chain.normalTitle(text: "去登录")
        }
        
        logoutBtn.isHidden = !UserStore.isLogin
        deregisterCell.isHidden = !UserStore.isLogin
        
        
        
        
        
    }

}
