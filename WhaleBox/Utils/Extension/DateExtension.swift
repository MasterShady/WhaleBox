//
//  DateExtension.swift
//  gerental
//
//  Created by 刘思源 on 2022/12/23.
//

import Foundation
import YYKit

extension Date{
    static func makeDate(year:Int,month:Int,day:Int) -> Date{
        let calendar = Calendar.current
        let dateComponents = DateComponents(calendar: calendar, year: year, month: month, day: day)
        return calendar.date(from: dateComponents)!
    }
    
    var year: Int{
        Calendar.current.component(.year, from: self)
    }
    
    var month: Int{
        Calendar.current.component(.month, from: self)
    }
    
    var day: Int{
        Calendar.current.component(.day, from: self)
    }
    
    var weekOfYear: Int{
        Calendar.current.component(.weekOfYear, from: self)
    }
}

public class DateManager: NSObject {
    @objc public static var shared = DateManager()
    
    private override init() {
        sharedDateFormatter = DateFormatter.init()
        sharedDateFormatter.locale = Locale.init(identifier: "zh_CN")
    }
    
    @objc public private(set) var sharedDateFormatter: DateFormatter
}

public extension Date {
    
    init?(string: String, format: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        guard let date = dateFormatter.date(from: string) else {
            return nil
        }
        self = date
    }
    
    static var cnZeroDate: Date {
        return Date.init(timeIntervalSince1970: 0)
    }
    
    static var currentTimeStamp: Int { // 秒级 时间戳
        return Int(Date().timeIntervalSince1970)
    }
    
    static var currentMillTimeStamp: Int { // 毫秒 时间戳
        let time = Date().timeIntervalSince1970
        return Int(time * 1000)
    }
    
    var isZero: Bool {
        return isZeroDate()
    }
    
    func isZeroDate() -> Bool {
        if self.timeIntervalSince1970 == 0 {
            return true
        } else {
            return false
        }
    }
    
    func isSameDay(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let unitFlags: Set<Calendar.Component> = [.year, .month, .day]
        let comp1 = calendar.dateComponents(unitFlags, from: date)
        let comp2 = calendar.dateComponents(unitFlags, from: self)
        return comp1.day == comp2.day && comp1.month == comp2.month && comp1.year == comp2.year
    }
    
    func isSameMonth(_ date: Date) -> Bool{
        return self.year == date.year && self.month == date.month
    }
    
    func isSameWeak(_ date: Date) -> Bool{
        return self.year == date.year && self.weekOfYear == date.weekOfYear
    }
    
    // --:--
    func dateString(withFormat dateFormatString: String = "yyyy-MM-dd") -> String {
        if isZeroDate() {
            return ""
        }
        DateManager.shared.sharedDateFormatter.dateFormat = dateFormatString
        return DateManager.shared.sharedDateFormatter.string(from: self)
    }
    
    func dateString(withFormat dateFormatString: String, timeZone: TimeZone) -> String? {
        if isZeroDate() {
            return ""
        }
        DateManager.shared.sharedDateFormatter.dateFormat = dateFormatString
        let lastTimeZone = DateManager.shared.sharedDateFormatter.timeZone
        DateManager.shared.sharedDateFormatter.timeZone = timeZone
        let result = DateManager.shared.sharedDateFormatter.string(from: self as Date)
        DateManager.shared.sharedDateFormatter.timeZone = lastTimeZone
        return result
    }
    
    /// 时间戳转换成字符串
    static func dateString(fromInterval interval: Int, withFormat dateFormatString: String = "yyyy-MM-dd") -> String {
        DateManager.shared.sharedDateFormatter.dateFormat = dateFormatString
        let date = Date.init(timeIntervalSince1970: TimeInterval(interval / 1000))
        return DateManager.shared.sharedDateFormatter.string(from: date)
    }
    
    func dateStringTodayFlag() -> String {
        if isZero {
            return "--:--"
        }
        if isSameDay(Date()) {
            DateManager.shared.sharedDateFormatter.dateFormat = "HH:mm"
        } else {
            DateManager.shared.sharedDateFormatter.dateFormat = "HH:mm(dd)"
        }
        return DateManager.shared.sharedDateFormatter.string(from: self)
    }
    
    var hour: Int {
        let calendar = Calendar.current
        return calendar.component(.hour, from: self)
    }
    
    var minute: Int {
        let calendar = Calendar.current
        return calendar.component(.minute, from: self)
    }
    
    var second: Int {
        let calendar = Calendar.current
        return calendar.component(.second, from: self)
    }
    
    static func create(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0, second: Int = 0) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        
        let date = Calendar.current.date(from: components)
        return date
    }
    
    static func stringToDate(withString dateString: String, format: String = "yyyy-MM-dd") -> Date? {
        if dateString.isEmpty {
            return nil
        }
        
        DateManager.shared.sharedDateFormatter.dateFormat = format
        return DateManager.shared.sharedDateFormatter.date(from: dateString)
    }
    
    func getNearDay(offsetSecond: Int = 0, offsetMinute: Int = 0, offsetHour: Int = 0, offsetDay: Int = 0, offsetMonth: Int = 0, offsetYear: Int = 0) -> Date? {
        var offsetComponents = DateComponents()
        offsetComponents.second = offsetSecond
        offsetComponents.minute = offsetMinute
        offsetComponents.hour = offsetHour
        offsetComponents.day = offsetDay
        offsetComponents.month = offsetMonth
        offsetComponents.year = offsetYear
        return Calendar.current.date(byAdding: offsetComponents, to: self)
    }
    
    // 计算两个日期的间隔
    func getDateInterval(date: Date) -> DateComponents {
        let calendar = Calendar.current
        let cmps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self, to: date)
        return cmps
    }
    
    var fisrtDayOfMonth: Date{
        let calendar = Calendar.current
        // 获取当前月份的第一天
        let firstDayComponents = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: firstDayComponents)!
    }
    

    
    var lastDayOfMonth: Date{
        let calendar = Calendar.current
        // 获取当前月份的第一天
        let firstDayComponents = calendar.dateComponents([.year, .month], from: self)
        let lastDayComponents = DateComponents(year: firstDayComponents.year, month: firstDayComponents.month! + 1, day: 0)
        return calendar.date(from: lastDayComponents)!
    }
    
    var firstDayOfYear: Date{
        let calendar = Calendar.current
        // 获取当前月份的第一天
        let firstDayComponents = calendar.dateComponents([.year], from: self)
        return calendar.date(from: firstDayComponents)!
    }
    
    var lastDayOfYear: Date{
        let calendar = Calendar.current
        // 获取当前月份的第一天
        let firstDayComponents = calendar.dateComponents([.year], from: self)
        let lastDayComponents = DateComponents(year: firstDayComponents.year! + 1, day: 0)
        return calendar.date(from: lastDayComponents)!
    }
    
    var firstDateOfWeek: Date{
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
    }
    
    var lastDateOfWeek: Date{
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
        return calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
    }
    
    
    var weekdayString: String {
        ["星期日","星期一","星期二","星期三","星期四","星期五","星期六"][(self as NSDate).weekday - 1]
    }
    
    var totalDayCountOfCurrentMonth : Int{
        // 创建一个 Calendar 实例
        let calendar = Calendar.current
        
        // 获取当前日期所在月份的年份和月份
        let year = calendar.component(.year, from: self)
        let month = calendar.component(.month, from: self)
        
        // 使用 DateComponents 获取当前月份的第一天
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        
        let firstDayOfMonth = calendar.date(from: components)!
        // 使用 Range 获取当前月份的日期范围
        let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!
        return range.count
    }
}


