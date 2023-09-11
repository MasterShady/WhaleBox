//
//  CreatePostVC.swift
//  WhaleBox
//
//  Created by 刘思源 on 2023/9/6.
//

import UIKit
import RxCocoa
import RxSwift
import CLImagePickerTool
import Moya

class CreatePostVC: BaseVC {
    let disposeBag = DisposeBag()
    
    var titleField : UITextField!
    var imageStackView : UIStackView!
    var imagesRelay = BehaviorRelay(value: [UIImage]())
    var gameCatRelay = BehaviorRelay(value: "")
    
    lazy var pickerTool : CLImagePickerTool = {
        let pickerTool = CLImagePickerTool.init()
        pickerTool.isHiddenVideo = true
        pickerTool.cameraOut = true //设置相机选择在外部
        pickerTool.singleImageChooseType = .singlePicture //单选模式
        pickerTool.singleModelImageCanEditor = true //设置单选模式下图片可以编辑涂鸦
        return pickerTool
    }()
    
    
    override func configNavigationBar() {
        
        let dismissBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 32))
        dismissBtn.chain.normalTitle(text: "取消").normalTitleColor(color: .kTextBlack).font(.semibold(14)).backgroundColor(.white).corner(radius: 5).clipsToBounds(true)
        dismissBtn.addBlock(for: .touchUpInside) {[weak self] _ in
            self?.dismiss(animated: true)
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissBtn)
    }
    
    
    override func configSubViews() {
        
        view.backgroundColor = .kExLightGray
        
        let gameCatView = UIButton()
        view.addSubview(gameCatView)
        gameCatView.snp.makeConstraints { make in
            make.top.equalTo(20 + kNavBarMaxY)
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.height.equalTo(44)
        }
        gameCatView.chain.corner(radius: 6).clipsToBounds(true).backgroundColor(.white)
        
        let gameCatLabel = UILabel()
        gameCatView.addSubview(gameCatLabel)
        gameCatLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
        }
        gameCatLabel.chain.text(color: .kTextBlack).font(.semibold(16)).text("游戏种类:")
        
        let gameCatValueLabel = UILabel()
        gameCatView.addSubview(gameCatValueLabel)
        gameCatValueLabel.snp.makeConstraints { make in
            make.left.equalTo(gameCatLabel.snp.right).offset(20)
            make.centerY.equalToSuperview()
        }
        
        gameCatView.rx.tap.subscribe {[weak self] _ in
            guard let self = self else {return}
            let vc = CircleCatVC()
            vc.didSelectedCat = {[weak vc] cat in
                self.gameCatRelay.accept(cat)
                vc?.popOrDismiss()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
        
        gameCatRelay.map { value in
            if value.count == 0{
                return NSAttributedString("请选择", color: .kTextLightGray, font: .semibold(16))
            }
            return NSAttributedString(value, color: .kTextBlack, font: .semibold(16))
        }.bind(to: gameCatValueLabel.rx.attributedText).disposed(by: disposeBag)
        

        
        
        titleField = UITextField()
        view.addSubview(titleField)
        titleField.snp.makeConstraints { make in
            make.top.equalTo(gameCatView.snp.bottom).offset(20)
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.height.equalTo(44)
        }
        titleField.chain.corner(radius: 6).clipsToBounds(true).backgroundColor(.white)
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        let leftTitle = UILabel(frame: CGRect(x: 16, y: 0, width: 80, height: 44))
        leftTitle.chain.text(color: .kTextBlack).font(.semibold(16)).text("帖子标题:")
        leftView.addSubview(leftTitle)
        
        titleField.leftView = leftView
        titleField.leftViewMode = .always
        titleField.chain.text(color: .kTextBlack).font(.systemFont(ofSize: 16))
        titleField.attributedPlaceholder = NSAttributedString("请输入标题~", color: .kTextLightGray, font: .semibold(16))
        
        
        let textContainer = UIView()
        view.addSubview(textContainer)
        textContainer.snp.makeConstraints { make in
            make.top.equalTo(titleField.snp.bottom).offset(20)
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.height.equalTo(200)
        }
        textContainer.chain.backgroundColor(.white).corner(radius: 5).clipsToBounds(true)
        
        let contentTextView = YYTextView()
        textContainer.addSubview(contentTextView)
        contentTextView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14))
        }
        
        contentTextView.textColor = .kTextBlack
        contentTextView.font = .systemFont(ofSize: 16)
        contentTextView.placeholderAttributedText = NSAttributedString("请输入内容,50字以上~", color: .kTextLightGray, font: .semibold(16))
        
        
        
        let charCountLabel = UILabel()
        textContainer.addSubview(charCountLabel)
        charCountLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        let contentInput = contentTextView.rx.observe(\.text)
        
        _ = contentInput.map { text in
            let notEmptyText = text ?? ""
            let raw = "\(notEmptyText.count)/50"
            let text = NSMutableAttributedString(raw, color: .kTextBlack, font: .systemFont(ofSize: 10))
            if notEmptyText.count > 50{
                text.setAttributes(
                    [
                        .font : UIFont.systemFont(ofSize: 10),
                        .foregroundColor : UIColor.green
                    ], range: (raw as NSString).range(of:"\(notEmptyText.count)"))
                return text
            }
            text.setAttributes(
                [
                    .font : UIFont.systemFont(ofSize: 10),
                    .foregroundColor : UIColor.red
                ], range: (raw as NSString).range(of:"\(notEmptyText.count)"))
            return text
        }.bind(to: charCountLabel.rx.attributedText).disposed(by: disposeBag)
        
        
        let imageContainer = UIView()
        view.addSubview(imageContainer)
        imageContainer.snp.makeConstraints { make in
            make.top.equalTo(textContainer.snp.bottom).offset(20)
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.height.equalTo(150)
        }
        
        imageContainer.chain.backgroundColor(.white).corner(radius: 6).clipsToBounds(true)
        let imageTitleLabel = UILabel()
        imageContainer.addSubview(imageTitleLabel)
        imageTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.left.equalTo(14)
        }
        imageTitleLabel.font = .semibold(16)
        imageTitleLabel.textColor = .kTextBlack
        imageTitleLabel.text = "图片(可选)"
        
        let imgWH = (kScreenWidth - 56 - 20 * 2) / 3
        
        imageStackView = UIStackView()
        imageStackView.axis = .horizontal
        imageStackView.spacing = 20
        imageContainer.addSubview(imageStackView)
        imageStackView.snp.makeConstraints { make in
            make.top.equalTo(imageTitleLabel.snp.bottom).offset(10)
            make.left.equalTo(14)
            
            make.height.equalTo(imgWH)
            make.bottom.equalTo(-8)
        }
        
        
        let contentValid = contentInput.map { text in
            return text?.count ?? 0 > 50
        }
        
        let titleValid = titleField.rx.text.map { text in
            return text?.count ?? 0 > 0
        }
        
        let catValid = gameCatRelay.map { text in
            return text.count > 0
        }
        
        let postValid = Observable.combineLatest(contentValid, titleValid, catValid).map {
            return $0.0 && $0.1 && $0.2
        }
        
        
       
        
        _ = imagesRelay.subscribe {[weak self] value in
            guard let self = self else {return}
            self.imageStackView.removeAllSubviews()
            
            let loopCount = min(3, value.element!.count + 1)
            for i in 0..<loopCount {
                let imageView = UIImageView()
                imageView.snp.makeConstraints { make in
                    make.width.height.equalTo(imgWH)
                }
                imageView.isUserInteractionEnabled = true
                imageView.contentMode = .scaleAspectFit
                imageView.clipsToBounds = true

                var action = {
                    let alert = AEAlertView(style: .defaulted, title: "", message: "确定删除该照片吗?")
                    alert.addAction(action: .init(title: "删除", handler: { action in
                        var array = value.element!
                        array.removeLast()
                        self.imagesRelay.accept(array)
                        alert.dismiss()
                    }))
                    alert.addAction(action: .init(title: "取消", handler: { action in
                        alert.dismiss()
                    }))
                    alert.show()

                }
                if i == loopCount - 1{
                    if i == value.element!.count - 1 {
                        //最后一个,是照片
                        imageView.image = value.element![i]
                    }else{
                        //添加照片的+好
                        let image = UIImage(named: "add-image")?.resizeImageToSize(size: CGSize(width: 50, height: 50))
                        imageView.image = image
                        imageView.contentMode = .center
                        imageView.size = CGSize(width: imgWH, height: imgWH)
                        imageView.addDashLine(with: .kTextLightGray, width: 1, lineDashPattern: [5,5], cornerRadius: 5)

                        action = {
                            self.pickerTool.cl_setupImagePickerWith(MaxImagesCount: 1, superVC: self) {[weak self] (assets, cutImage) in
                                guard let self = self else {return}
                                guard let image = cutImage else { return }
                                var raw = self.imagesRelay.value
                                raw.append(image)
                                self.imagesRelay.accept(raw)

                            }
                        }
                    }
                }else{
                    imageView.image = value.element![i]
                }
                let tap = UITapGestureRecognizer { _ in
                    action()
                }
                imageView.addGestureRecognizer(tap)
                imageStackView.addArrangedSubview(imageView)
            }
            
        }.disposed(by: disposeBag)
        
        let commitBtn = UIButton()
        view.addSubview(commitBtn)
        commitBtn.snp.makeConstraints { make in
            make.top.equalTo(imageContainer.snp.bottom).offset(30)
            make.size.equalTo(CGSize(width: 120, height: 44))
            make.centerX.equalToSuperview()
        }
        commitBtn.chain.normalBackgroundImage(.init(color: .kThemeColor)).disabledBackgroundImage(.init(color: .kTextLightGray)).font(.semibold(16)).normalTitle(text: "提交").normalTitleColor(color: .kTextBlack).disabledTitleColor(color: .white).corner(radius: 8).clipsToBounds(true)
        
        _ = postValid.bind(to: commitBtn.rx.isEnabled)
        let a = Observable.combineLatest(gameCatRelay ,titleField.rx.text, contentTextView.rx.observe(\.text), imagesRelay)
        
        
        
        let _ =  commitBtn.rx.tap.withLatestFrom(a).take(until: rx.deallocated).flatMapLatest { (type, title, content, images) in
            let imageBase64List = images.map{ image in
                return image.jpegData(compressionQuality: 0.1)!.base64EncodedString()
            }.joined(separator: ",")
            return userService.rx.request(.makePost(type:type,title: title!, content: content!, images: imageBase64List)).catch({ error in
                let error = error as NSError
                let data = try! NSKeyedArchiver.archivedData(withRootObject: error, requiringSecureCoding: false)
                return Single.just(Response(statusCode: 6666, data:data))
            })
        }.asObservable().mapToBody().subscribe {[weak self] body, error in
            if let error = error{
                error.msg.hint()
            }else{
                "发帖成功".hint()
                self?.dismiss(animated: true)
            }
        }
        
        
    }
}
