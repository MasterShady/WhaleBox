//
//  RegisterVC.swift
//  FRMall
//
//  Created by 刘思源 on 2023/8/7.
//

import UIKit
import RxSwift
import YYKit

class RegisterVC: BaseVC {
    
    var userNameFiled: UITextField!
    var passwordFiled: UITextField!
    var checkbox: UIButton!

    let disposeBag = DisposeBag()
    
    override func configSubViews() {
        //self.navBarBgAlpha = 0
        let bgView = UIImageView(image: .init(named: "login_bg"))
        self.view.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.left.right.top.equalTo(0)
            make.height.equalTo(450)
        }
        
        let titleLabel = UILabel()
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(81 + kNavBarMaxY)
            make.left.equalTo(30)
        }
        titleLabel.chain.text("账密注册").font(.semibold(28)).text(color: .kBlack)
        
        userNameFiled = UITextField(frame: .zero)
        view.addSubview(userNameFiled)
        userNameFiled.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.height.equalTo(50)
        }
        
        userNameFiled.chain.corner(radius: 12).clipsToBounds(true).backgroundColor(.white)
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 22, height: 50))
        userNameFiled.leftView = leftView
        userNameFiled.leftViewMode = .always
        userNameFiled.attributedPlaceholder = .init("请输入用户名/手机号码", color: .init(hexColor: "#D4D5DB"), font: .medium(15))
        userNameFiled.textColor = .black
        
        let 哈基米 = UIImageView(image: .init(named: "哈基米"))
        view.addSubview(哈基米)
        哈基米.snp.makeConstraints { make in
            make.top.equalTo(userNameFiled.snp.top).offset(-40)
            make.right.equalTo(userNameFiled.snp.right).offset(-7)
        }
        
        
        passwordFiled = UITextField(frame: .zero)
        view.addSubview(passwordFiled)
        passwordFiled.snp.makeConstraints { make in
            make.top.equalTo(userNameFiled.snp.bottom).offset(20)
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.height.equalTo(50)
        }
        
        passwordFiled.chain.corner(radius: 12).clipsToBounds(true).backgroundColor(.white)
        
        let leftView2 = UIView(frame: CGRect(x: 0, y: 0, width: 22, height: 50))
        let phoneIcon2 = UIImageView(image: .init(named: "login_password"))
        passwordFiled.leftView = leftView2
        passwordFiled.leftViewMode = .always
        passwordFiled.attributedPlaceholder = .init("请输入密码", color: .init(hexColor: "#D4D5DB"), font: .medium(15))
        passwordFiled.textColor = .black
        
        let rigitView = UIView(frame: CGRect(x: 0, y: 0, width: 54, height: 50))
        let eyeButton = UIButton(frame: CGRect(x: 0, y: 12, width: 26, height: 26))
        rigitView.addSubview(eyeButton)
        eyeButton.chain.normalImage(.init(named: "login_eye_closed")).selectedImage(.init(named: "login_eye_open"))

        eyeButton.rx.tap.map { _ in
            return !eyeButton.isSelected
        }.startWith(true).bind(to: eyeButton.rx.isSelected, passwordFiled.rx.isSecureTextEntry).disposed(by: disposeBag)
        
        passwordFiled.rightView = rigitView
        passwordFiled.rightViewMode = .always
        
        let promotionCodeField = UITextField(frame: .zero)
        view.addSubview(promotionCodeField)
        promotionCodeField.snp.makeConstraints { make in
            make.top.equalTo(passwordFiled.snp.bottom).offset(20)
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.height.equalTo(50)
        }
        
        promotionCodeField.chain.corner(radius: 25).clipsToBounds(true).backgroundColor(.white)
        
        let leftView3 = UIView(frame: CGRect(x: 0, y: 0, width: 22, height: 50))
        promotionCodeField.leftView = leftView3
        promotionCodeField.leftViewMode = .always
        promotionCodeField.attributedPlaceholder = .init("推广码（选填）", color: .init(hexColor: "#D4D5DB"), font: .systemFont(ofSize: 15))
        promotionCodeField.textColor = .black
        
        
        let loginBtn = UIButton()
        view.addSubview(loginBtn)
        loginBtn.snp.makeConstraints { make in
            make.top.equalTo(promotionCodeField.snp.bottom).offset(40)
            make.left.equalTo(28)
            make.right.equalTo(-28)
            make.height.equalTo(50)
        }
        loginBtn.chain.normalTitle(text: "注册").normalTitleColor(color: .white).font(.medium(16)).backgroundColor(.kBlack).corner(radius: 25).clipsToBounds(true)
        
        checkbox = UIButton()
        
        view.addSubview(checkbox)
        checkbox.snp.makeConstraints { make in
            make.top.equalTo(loginBtn.snp.bottom).offset(15)
            make.left.equalTo(34)
        }
        checkbox.chain.normalImage(.init(named: "login_checkbox")).selectedImage(.init(named: "login_checkbox_enable"))
        checkbox.addBlock(for: .touchDown) {
            ($0 as! UIButton).isSelected.toggle()
        }
        
        
        
        let policyLabel = YYLabel()
        view.addSubview(policyLabel)
        policyLabel.snp.makeConstraints { make in
            make.left.equalTo(checkbox.snp.right).offset(4)
            make.centerY.equalTo(checkbox)
            make.right.equalTo(-35)
        }
        policyLabel.numberOfLines = 0
        policyLabel.preferredMaxLayoutWidth = kScreenWidth - 35 - 54
        
        
        let t1 = "平台服务协议"
        
        let t2 = "隐私政策"
        
        let raw = "注册登录即表示同意 \(t1) 和 \(t2) 并授权获取本机号码"
        
        let text = NSMutableAttributedString(raw, color: .init(hexColor: "#A1A0AB"), font: .normal(12))
        text.setAttributes([
            .foregroundColor: UIColor.kTextBlack
        ], range: (raw as NSString).range(of: t1))
        
        text.setAttributes([
            .foregroundColor: UIColor.kTextBlack
        ], range: (raw as NSString).range(of: t2))
        
        policyLabel.attributedText = text
        policyLabel.textTapAction = {[weak self] _,_,range,_  in
            if ((raw as NSString).range(of: t1).intersection(range) != nil) {
                UIApplication.shared.open(URL(string: "https://www.freeprivacypolicy.com/live/b10fc3b9-b0c1-4ba2-8082-84f33afdda3d")!)
            }else if (raw as NSString).range(of: t2).intersection(range) != nil{
                UIApplication.shared.open(URL(string: "https://www.freeprivacypolicy.com/live/b10fc3b9-b0c1-4ba2-8082-84f33afdda3d")!)
            }
        }
        
        
        loginBtn.addTarget(self, action: #selector(registerUser), for: .touchUpInside)
        
        
    }
    
    @objc func registerUser(){
        if userNameFiled.text?.count == 0{
            "请输入手机号".hint()
            return
        }
        
        if passwordFiled.text?.count == 0{
            "请输入密码".hint()
            return
        }
        
        if checkbox.isSelected == false{
            "请先勾选协议".hint()
            return
        }
        
        userService.request(.register(mobile: userNameFiled.text!, passwd: passwordFiled.text!)) { result in
            result.hj_map2(UserAccount.self) { body, error in
                if let error = error{
                    error.msg.hint()
                    return
                }
                UserStore.currentUser = body?.decodedObj
                self.popToViewControllerAhead(by: 2)
            }
        }
    }
    

}
