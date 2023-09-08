//
//  BasePicker.swift
//  ferental
//
//  Created by 刘思源 on 2023/1/6.
//

import Foundation


protocol PickerProtocol{
    associatedtype DataType where DataType : Equatable
    
    //选中的类型, 单选 = DataType 多选 = [DataType]
    associatedtype SelectedType
    
    var title: NSAttributedString { get set }
    var selectedHandler: (SelectedType) -> () { get set }
    
    //子类重写该方法来更新选中项
    func setSelectedData(_ data:SelectedType)
}

class BasePicker<DataType: Equatable, SelectedType> : BaseView, PickerProtocol{
    typealias DataType = DataType
    typealias SelectedType = SelectedType
    var title: NSAttributedString
    var selectedHandler: (SelectedType) -> ()
    var selectedData: SelectedType?
    
    
    func setSelectedData(_ data:SelectedType){
        selectedData = data
    }
    
    init(title:NSAttributedString,selectedHandler:@escaping (SelectedType) -> ()) {
        self.title = title
        self.selectedHandler = selectedHandler
        super.init(frame: .zero)
        self.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configSubviews() {
        addSubview(header)
        header.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(52)
        }
    }
    
    override func layoutSubviews() {
        addCornerRect(with: [.topLeft,.topRight], radius: 12)
        header.addBorder(with: UIColor(hexColor:"eeeeee"), width: 1, borderType: .bottom)
    }
    
    lazy var header: UIView = {
        let header = UIView()
        let cancelBtn = UIButton()
        header.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(22)
            make.centerY.equalToSuperview()
        }
        cancelBtn.chain.normalTitle(text: "取消").font(.boldSystemFont(ofSize: 14)).normalTitleColor(color: .init(hexColor: "#585960"))
        cancelBtn.addBlock(for: .touchUpInside) { [weak self] _ in
            self?.popDismiss()
        }
        
        let comfirmBtn = UIButton()
        header.addSubview(comfirmBtn)
        comfirmBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-22)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 44, height: 28))
        }
        comfirmBtn.chain.normalTitle(text: "完成").font(.boldSystemFont(ofSize: 14)).normalTitleColor(color: .white).backgroundColor(.init(hexColor: "#2B2B2B")).corner(radius: 6).clipsToBounds(true)
        comfirmBtn.addBlock(for: .touchUpInside) { [weak self] _ in
            if let self = self{
                self.selectedHandler(self.selectedData!)
            }
        }
        
        
        let titleLabel = UILabel()
        header.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        titleLabel.attributedText = self.title
        
        return header
    }()
}
