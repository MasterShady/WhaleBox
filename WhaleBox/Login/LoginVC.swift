//
//  LoginVC.swift
//  FRMall
//
//  Created by 刘思源 on 2023/8/7.
//

import UIKit
@_exported import RxSwift
@_exported import RxCocoa
@_exported import YYKit
@_exported import Toaster
import Moya
import MBProgressHUD







class ValidateService{
    static let shared = ValidateService()
    let minPasswordCount = 6
    func validateUsername(_ username: String) -> ValidationResult {
        if username.isEmpty {
            return .empty
        }

        // this obviously won't be
        if username.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil {
            return .failed(message: "Username can only contain numbers or digits")
        }
        
        return .ok(message: "Username acceptable")
    }
    
    func validatePassword(_ password: String) -> ValidationResult {
        let numberOfCharacters = password.count
        if numberOfCharacters == 0 {
            return .empty
        }
        
        if numberOfCharacters < minPasswordCount {
            return .failed(message: "Password must be at least \(minPasswordCount) characters")
        }
        
        return .ok(message: "Password acceptable")
    }
}


enum ValidationResult {
    case ok(message: String)
    case empty
    case validating
    case failed(message: String)
    
    var isValid: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
}

class LoginViewModel {
//    let policyAgreed : Driver<Bool>
    let signupEnabled: Driver<Bool>
    let validatedUsername: Driver<ValidationResult>
    let validatedPassword: Driver<ValidationResult>
    //用户是否登录
    
    let signedIn: Observable<(ResponseBody<UserAccount>?, ResponseError?)>
    
    init(input:(
        username: Driver<String>,
        password: Driver<String>,
        agreedDriver :Driver<Bool>,
        loginTaps: Signal<()>
    )) {
        
        let validationService = ValidateService.shared
        
        validatedUsername = input.username
            .map { username in
                return validationService.validateUsername(username)
            }
        
        validatedPassword = input.password
            .map { password in
                return validationService.validatePassword(password)
            }
        
        signupEnabled = Driver.combineLatest(validatedUsername,validatedPassword, input.agreedDriver){
            username, passwd, agreed in
            username.isValid &&
            passwd.isValid && agreed
        }.startWith(false)
        let usernameAndPassword = Driver.combineLatest(input.username, input.password)
        signedIn = input.loginTaps.withLatestFrom(usernameAndPassword).asObservable().flatMapLatest { username, password in
            return userService.rx.request(.login(mobile: username, passwd: password)).catch({ error in
                let error = error as NSError
                let data = try! NSKeyedArchiver.archivedData(withRootObject: error, requiringSecureCoding: false)
                return Single.just(Response(statusCode: 6666, data:data))
            })
            .asObservable().mapToBody(type: UserAccount.self)
        }
    }

}


class LoginVC: BaseVC {
    
    let disposeBag = DisposeBag()
    
    var userNameFiled : UITextField!
    var passwordFiled : UITextField!
    
    
    override func configNavigationBar() {
        let rigisterItem = UIBarButtonItem(title: "注册", style: .plain, target: nil, action: nil)
        rigisterItem.rx.tap.subscribe(onNext: { [weak self] in
            self?.navigationController?.pushViewController(RegisterVC(), animated: true)
        }).disposed(by: disposeBag)
        self.navigationItem.rightBarButtonItem = rigisterItem
    }
    
    override func configSubViews() {
        self.navBarBgAlpha = 0
        let bgView = UIImageView(image: .init(named: "header_bg"))
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
        titleLabel.chain.text("账密登录").font(.semibold(28)).text(color: .kBlack)
        
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
        
//        let 哈基米 = UIImageView(image: .init(named: "哈基米"))
//        view.addSubview(哈基米)
//        哈基米.snp.makeConstraints { make in
//            make.top.equalTo(userNameFiled.snp.top).offset(-40)
//            make.right.equalTo(userNameFiled.snp.right).offset(-7)
//        }
        
        
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
        
        let forgetPassword = UIButton()
        view.addSubview(forgetPassword)
        forgetPassword.snp.makeConstraints { make in
            make.right.equalTo(-47)
            make.top.equalTo(passwordFiled.snp.bottom).offset(14)
        }
        forgetPassword.chain.normalTitle(text: "忘记密码").normalTitleColor(color: .init(hexColor: "#999999")).font(.normal(12)).isHidden(true)
        
        let loginBtn = UIButton()
        view.addSubview(loginBtn)
        loginBtn.snp.makeConstraints { make in
            make.top.equalTo(forgetPassword.snp.bottom).offset(52)
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.height.equalTo(50)
        }
        loginBtn.chain.normalTitle(text: "登录").normalTitleColor(color: .white).font(.medium(16)).normalBackgroundImage(.init(color: .init(hexColor: "#2A2E30"))).disabledBackgroundImage(.init(color: .lightGray)).corner(radius: 25).clipsToBounds(true).titleColor(color: .white, for: .disabled)
        loginBtn.addBlock(for: .touchUpInside) {[weak self] _ in
            guard let self = self else {return}
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        
        
        let checkbox = UIButton()
        view.addSubview(checkbox)
        checkbox.snp.makeConstraints { make in
            make.top.equalTo(loginBtn.snp.bottom).offset(16)
            make.left.equalTo(36)
        }
        checkbox.chain.normalImage(.init(named: "login_checkbox")).selectedImage(.init(named: "login_checkbox_enable"))
        
        
        let selectedDriver = checkbox.rx.tap.map { _ in
            return checkbox.isSelected
        }.asDriver(onErrorJustReturn: false)
        
        
        checkbox.rx.tap
                    .map {
                        return !checkbox.isSelected
                    }
                    .bind(to: checkbox.rx.isSelected)
                    .disposed(by: disposeBag)
        
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
        
       
        
        
        let viewModel = LoginViewModel(input: (
            username: userNameFiled.rx.text.orEmpty.asDriver(),
            password: passwordFiled.rx.text.orEmpty.asDriver(),
            agreedDriver: selectedDriver,
            loginTaps: loginBtn.rx.tap.asSignal()
        ))
        
        
        
        viewModel.signupEnabled.drive(loginBtn.rx.isEnabled).disposed(by: disposeBag)
        viewModel.signedIn.subscribe {[weak self] (body , error) in
            guard let self = self else {return}
            MBProgressHUD.hide(for: self.view, animated: true)
            if let error = error{
                error.msg.hint()
                return
            }
            UserStore.currentUser = body?.decodedObj
            self.navigationController?.popViewController(animated: true)
        } .disposed(by: disposeBag)
    }
}
