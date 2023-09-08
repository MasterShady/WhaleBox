//
//  SinglePicker.swift
//  ferental
//
//  Created by 刘思源 on 2022/12/28.
//

import Foundation

class SinglePicker<DataType:Equatable> : BasePicker<DataType,DataType>, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var titleForDatum: (DataType) -> String
    var data: [DataType]
    
    init(title:NSAttributedString,data: [DataType], selectedHandler: @escaping (SelectedType)->(), titleForDatum: @escaping (DataType) -> String) {
        self.data = data
        self.titleForDatum = titleForDatum
        super.init(title: title, selectedHandler: selectedHandler)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configSubviews() {
        super.configSubviews()
        addSubview(picker)
        picker.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom)
            make.left.right.bottom.equalTo(self)
        }
    }
    
    override func setSelectedData(_ data: SelectedType) {
        super.setSelectedData(data)
        picker.selectRow(self.data.firstIndex(of: data)!, inComponent: 0, animated: false)
    }
    
    
    lazy var picker: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self;
        return picker
    }()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        data.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let datum = data[row]
        return titleForDatum(datum)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //self.selectedData = data[row]
        super.setSelectedData(data[row])
    }
}


