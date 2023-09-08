//
//  MonthPicker.swift
//  Whale
//
//  Created by 刘思源 on 2023/8/23.
//

import UIKit

class MonthPicker: BasePicker<Date,Date> {
    
    var fromDate: Date
    var toDate: Date
    lazy var datesByYearMonthDay : [Int: [Int]] = [:]
    
    
    init(title:NSAttributedString,fromDate:Date, toDate:Date, selectedHandler:@escaping (Date) -> ()) {
        self.fromDate = fromDate
        self.toDate = toDate
        super.init(title: title, selectedHandler: selectedHandler)
        self.selectedData = fromDate
        prepareData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelectedData(_ data: Date) {
        //找到并选中
        selectedData = data
        let yearIndex = datesByYearMonthDay.keys.sorted().indexOf(data.year)!
        let monthIndex = datesByYearMonthDay[data.year]!.indexOf(data.month)!
        self.picker.selectRow(yearIndex, inComponent: 0, animated: true)
        self.picker.selectRow(monthIndex, inComponent: 1, animated: true)
    }
    
    func prepareData(){
        let calendar = Calendar.current
        var date = fromDate
        while date <= toDate {
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            
            if datesByYearMonthDay[year] == nil {
                datesByYearMonthDay[year] = .init()
            }
    
            datesByYearMonthDay[year]!.append(month)
            date = calendar.date(byAdding: .month, value: 1, to: date)!
        }
    }
    
    override func configSubviews() {
        super.configSubviews()
        addSubview(picker)
        picker.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom)
            make.left.right.bottom.equalTo(self)
        }
    }
    
    
    lazy var picker: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self;
        return picker
    }()
}

extension MonthPicker : UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0{
            return datesByYearMonthDay.keys.count
        }
        return datesByYearMonthDay[selectedData!.year]!.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0{
            
            return String(datesByYearMonthDay.keys.sorted()[row])
        }
        return String(datesByYearMonthDay[selectedData!.year]![row])
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let yearIndex = pickerView.selectedRow(inComponent: 0)
        let monthIndex = pickerView.selectedRow(inComponent: 1)
        
        selectedData = dateOfIndexs(yearIndex: yearIndex, monthIndex: monthIndex)
        if component == 0{
            pickerView.reloadAllComponents()
        }
    }
    
    
    func dateOfIndexs(yearIndex:Int, monthIndex:Int) -> Date{
        let year = datesByYearMonthDay.keys.sorted()[yearIndex]
        let months: [Int] = datesByYearMonthDay[year]!
        let month = months[min(monthIndex, months.count - 1)]
        return Date.makeDate(year: year, month: month, day: 1)
    }
    
}
