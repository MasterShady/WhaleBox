//
//  GamePicker.swift
//  ferental
//
//  Created by 刘思源 on 2022/12/29.
//

import Foundation


class MultiplePicker<DataType:Equatable>: BasePicker<DataType,[DataType]> {
    var titleForDatum: (DataType) -> String
    var data: [DataType] {
        didSet{
            layoutItems()
        }
    }
    
    private var scrollView = UIScrollView()

    init(title:NSAttributedString,data: [DataType], selectedHandler: @escaping ([DataType])->(), titleForDatum: @escaping (DataType) -> String){
        self.titleForDatum = titleForDatum
        self.data = data
        super.init(title: title, selectedHandler: selectedHandler)
        self.selectedData = []
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelectedData(_ data: [DataType]) {
        super.setSelectedData(data)
        layoutItems()
    }
    
    
    override func configSubviews() {
        super.configSubviews()
        
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        layoutItems()
        
    }
    
    func layoutItems() {
        let insets = UIEdgeInsets.init(top: 16, left: 16, bottom: 16, right: 16)
        let layoutW = kScreenWidth - insets.left - insets.right
        let countPerRow = 3
        let HSpacing = 26.0
        let VSpacing = 16.0
        
        let rowCount =  Int(ceil(Double(self.data.count) / Double(countPerRow)))
        let itemW = (layoutW - (countPerRow - 1) * HSpacing)/countPerRow
        let itemH = 34.0
        
        scrollView.subviews.forEach{
                if $0 is UIButton{
                    $0.removeFromSuperview()
                }
            }
        
        let ContentH = rowCount * itemH + (rowCount - 1) * VSpacing
        scrollView.contentSize = CGSize(width: layoutW, height: ContentH)
        scrollView.contentInset = insets
        
        for  (i,datum) in data.enumerated() {
            let row = i / countPerRow
            let line = i % countPerRow
            
            let btn = UIButton()
            let title = self.titleForDatum(datum)
            

            
            let normalAttrTitle = NSAttributedString(string: title, attributes: [
                .font : UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor : UIColor(hexColor: "#585960")
            ])
            
            let selectedAttrTitle = NSAttributedString(string: title, attributes: [
                .font : UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor : UIColor.init(hexColor: "#111111")
            ])
            //.init(hexColor: "#00FF98"), .init(hexColor: "#00FFED")
            let selectedBackImage = UIImage(color: .gradient(colors: [.init(hexColor: "#00FF98"), .init(hexColor: "#00FFED")], from: .zero, to: .init(x: 1, y: 1), size: .init(width: itemW, height: itemH)))
            
            btn.chain.normalAttributedTitle(normalAttrTitle).selectedAttributedTitle(selectedAttrTitle).normalBackgroundImage(.init(color: .kExLightGray)).selectedBackgroundImage(selectedBackImage).corner(radius: 3).clipsToBounds(true)
            
            scrollView.addSubview(btn)
            
            
            btn.x = line * (itemW + HSpacing)
            btn.y = row * (itemH + VSpacing)
            btn.size = CGSize(width: itemW, height: itemH)
            btn.addBlock(for: .touchUpInside) {[weak self] sender in
                if let sender = sender as? UIButton {
                    sender.isSelected = !sender.isSelected
                    if sender.isSelected{
                        self?.selectedData?.append(datum)
                    }else{
                        self?.selectedData?.remove(datum)
                    }
                }
            }
            if let selectedData = selectedData{
                if selectedData.contains(datum){
                    btn.isSelected = true
                }
            }
        }
    }
}
