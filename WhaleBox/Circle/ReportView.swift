//
//  GameHiveHomeReportView.swift
//  GameHive
//
//  Created by genggy on 2023/8/8.
//

import UIKit
import RxCocoa
import RxSwift

extension UILabel{
    static func createSameLbl(text:String,color:UIColor,font:UIFont) -> UILabel{
        let lbl = UILabel()
        lbl.text = text
        lbl.textColor = color
        lbl.font = font
        return lbl
    }
}

@objcMembers
class ReportView: UIView {
    
    
    var tid: Int = 0
    var reason: String = ""
    
    private var reasons = [String]()
    private var btns = [UIButton]()
    private var isShield: Bool = true
    private let dBag = DisposeBag()
    
    var dismissHandler: BoolBlock?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addUI()
    }
    
    convenience init(_isShield: Bool) {
        self.init(frame: UIScreen.main.bounds)
        isShield = _isShield
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addUI() {
        var titStr = "请选择您举报的理由"
        if isShield {
            titStr = "请选择您举报的理由"
            reasons = ["涉及色情暴力信息", "内容引起不适", "大量重复恶意刷帖", "内容涉嫌侵权"]
        } else {
            reasons = ["涉及色情暴力信息", "涉及政治敏感信息", "包含歧视、辱骂等不友善信息", "内容涉嫌侵权", "包含垃圾或广告信息"]
        }
        
//        addSubview(fullBgView)
//        fullBgView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
        
        self.snp.makeConstraints { make in
            make.width.equalTo(305.rw)
            make.height.greaterThanOrEqualTo(300)
        }
        
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()

        }
        
        titLab.text = titStr
        contentView.addSubview(titLab)
        titLab.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualToSuperview()
        }
        
        
        
        let tipsLab = UILabel.createSameLbl(text: "很抱歉为您展示了您不喜欢的内容，请您选择一下原因，我们会全力的为您提供最优质的内容。", color: .kTextBlack, font: UIFont.normal(14))
        tipsLab.numberOfLines = 0
        contentView.addSubview(tipsLab)
        tipsLab.snp.makeConstraints { make in
            make.top.equalTo(titLab.snp.bottom).offset(20)
            make.left.equalTo(25.rw)
            make.right.equalTo(-25.rw)
            make.height.greaterThanOrEqualTo(22)
        }
        
        let h = 34
        for (index, rea) in reasons.enumerated() {
            let btn = UIButton(type: .custom)
            btn.setImage(UIImage(named: "circle_unselected"), for: .normal)
            btn.setImage(UIImage(named: "circle_selected"), for: .selected)
            btn.tag = index
            contentView.addSubview(btn)
            let originY = 7.0 + h * index
            btn.snp.makeConstraints { make in
                make.left.equalTo(tipsLab)
                make.top.equalTo(tipsLab.snp.bottom).offset(originY)
                make.width.height.equalTo(h)
            }
            
            let reasonLab = UILabel.createSameLbl(text: rea, color: .kTextBlack, font: UIFont.normal(14))
            contentView.addSubview(reasonLab)
            reasonLab.snp.makeConstraints { make in
                make.left.equalTo(btn.snp.right).offset(5)
                make.centerY.equalTo(btn)
                make.right.equalTo(-5)
            }
            
            btn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] _ in
                guard let `self` = self else {return}
                for item in self.btns {
                    item.isSelected = false
                }
                btn.isSelected = true
                self.reason = self.reasons[index]
            }).disposed(by: dBag)
            
            btns.append(btn)
        }
        
        let lastBtn = btns.last
        let sureBtn = UIButton(type: .custom)
        sureBtn.setTitle("确定", for: .normal)
        sureBtn.setTitleColor(.white, for: .normal)
        sureBtn.titleLabel?.font = UIFont.medium(15)
        sureBtn.layer.cornerRadius = 22.5
        sureBtn.layer.masksToBounds = true
        sureBtn.backgroundColor = .kThemeColor
        contentView.addSubview(sureBtn)
        sureBtn.snp.makeConstraints { make in
            make.top.equalTo(lastBtn!.snp.bottom).offset(13)
            make.left.right.equalTo(tipsLab)
            make.height.equalTo(45)
        }
        
        let cancelBtn = UIButton(type: .custom)
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.setTitleColor(.kTextBlack, for: .normal)
        cancelBtn.titleLabel?.font = UIFont.medium(15)
        cancelBtn.layer.cornerRadius = 22.5
        cancelBtn.layer.masksToBounds = true
        cancelBtn.layer.borderColor = UIColor.kSepLineColor.cgColor
        cancelBtn.layer.borderWidth = 1
        contentView.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { make in
            make.top.equalTo(sureBtn.snp.bottom).offset(14)
            make.left.right.height.equalTo(sureBtn)
            make.bottom.equalTo(contentView).offset(-20)
        }
        
        cancelBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] _ in
            self?.popDismiss(completedHandler: {
                self?.dismissHandler?(false)
            })
        }).disposed(by: dBag)
        
        sureBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            let str = (self.isShield ? "未选择屏蔽原因" : "未选择举报原因")
            if self.reason.count == 0 {
                str.hint()
                return
            }
            self.popDismiss(completedHandler: {
                self.dismissHandler?(true)
            })
        }).disposed(by: dBag)
    }
    

    
    lazy var contentView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 12
        v.layer.masksToBounds = true
        return v
    }()
    
    lazy var titLab: UILabel = {
        let lab = UILabel.createSameLbl(text: "", color: .kTextBlack, font: UIFont.semibold(18))
        return lab
    }()
}
