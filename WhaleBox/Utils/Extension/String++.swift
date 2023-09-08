//
//  File.swift
//  CallRecorderSwift
//
//  Created by 写童话的云天明 on 2020/4/2.
//  Copyright © 2020 Wade. All rights reserved.
//

import UIKit


//
//  VerifyHelp.swift
//  FBSnapshotTestCase
//  Created by 350541732 on 11/26/2019.
//  Copyright (c) 2019 350541732. All rights reserved.
//

public class VerifyHelp: NSObject {
    
    
}

extension String {
    
    static func timeStringForTimeInterval(_ timeInterval: Double) -> String {
        let ti = Int(ceil(timeInterval))
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        
        if (hours > 0) {
            return String(format: "%02li:%02li:%02li", hours, minutes, seconds)
        }else{
            return String(format: "%02li:%02li", minutes, seconds)
        }
    }
    
    static func stringWithTimestamp(_ timeInterval: Double) -> String? {
        let fileCreateDate = Date.init(timeIntervalSince1970: timeInterval / 1000.0)
        let formatter = DateFormatter.init()
        formatter.locale = Locale.init(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.init(identifier: "UTC")
        formatter.dateFormat = "MMM dd, yyyy 'at' hh:mm a"
        let string = formatter.string(from: fileCreateDate)
        return string
    }
    
    /// 字符串的匹配范围
    /// - Parameters:
    ///    - matchStr: 要匹配的字符串
    /// - Returns: 返回所有字符串范围
    @discardableResult
    public func matchStrRanges(_ matchStr: String) -> [NSRange] {
        var selfStr = self as NSString
        var withStr = Array(repeating: "X", count: (matchStr as NSString).length).joined(separator: "") //辅助字符串
        if matchStr == withStr { withStr = withStr.lowercased() } //临时处理辅助字符串差错
        var allRange = [NSRange]()
        while selfStr.range(of: matchStr).location != NSNotFound {
            let range = selfStr.range(of: matchStr)
            allRange.append(NSRange(location: range.location,length: range.length))
            selfStr = selfStr.replacingCharacters(in: NSMakeRange(range.location, range.length), with: withStr) as NSString
        }
        return allRange
    }
}

extension String {
    
    func sizeWith(font: UIFont, maxW: CGFloat = .greatestFiniteMagnitude) -> CGSize {
        let text: NSString = self as NSString
        let maxSize: CGSize = CGSize.init(width: maxW, height: 1000)
        let atts = [NSAttributedString.Key.font : font]
        return text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: atts, context: nil).size
    }
    
    func sizeWith(attrs: [NSAttributedString.Key : Any], maxW: CGFloat = .greatestFiniteMagnitude) -> CGSize {
        let text: NSString = self as NSString
        let maxSize: CGSize = CGSize.init(width: maxW, height: 1000)
        return text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: attrs, context: nil).size
    }
    
    //去除字符串两端的空白字符
    func trimWhitespaces() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    func subString(to: Int) -> String {
        var to = to
        if to > self.count {
            to = self.count
        }
        return String(self.prefix(to))
    }

    func subString(from: Int) -> String {
        if from >= self.count {
            return ""
        }
        let startIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.endIndex
        return String(self[startIndex..<endIndex])
    }

    func subString(start: Int, end: Int) -> String {
        if start < end {
            let startIndex = self.index(self.startIndex, offsetBy: start)
            let endIndex = self.index(self.startIndex, offsetBy: end)
            
            return String(self[startIndex..<endIndex])
        }
        return ""
    }
    
    func firstLetter() -> String? {
        if let char = first {
            return String(char)
        }
        return nil
    }
    
    func toPinYin() -> String {
        let mutableString = NSMutableString(string: self)
        //把汉字转为拼音
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        //去掉拼音的音标
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        let string = String(mutableString)
        //去掉空格
        return string.replacingOccurrences(of: " ", with: "")
    }
    
    func isLetter() -> Bool {
        return !isEmpty && range(of: "[^a-zA-Z]", options: .regularExpression) == nil
    }
    
}


extension String {
    
    //将原始的url编码为合法的url
    func urlEncoded() -> String {
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed)
        return encodeUrlString ?? ""
    }
    
    //将编码后的url转换回原始的url
    func urlDecoded() -> String {
        return self.removingPercentEncoding ?? ""
    }
    
}

extension NSAttributedString {
    /// 富文本转换为 HTML文本
    ///
    /// - Parameter attribute  富文本
    /// - Returns: html文本
    func toHTML() -> String {
        let options: [NSAttributedString.DocumentAttributeKey: Any] = [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.html,NSAttributedString.DocumentAttributeKey.characterEncoding: String.Encoding.utf8.rawValue]
        let data = try! self.data(from: NSMakeRange(0, self.length), documentAttributes: options)
        return String(data: data, encoding: .utf8)!
    }

}


extension String {
    var isPhone: Bool {
        if self.count == 0 {
            return false
        }
        let mobile = "^(13[0-9]|15[0-9]|18[0-9]|17[0-9]|147)\\d{8}$"
        let regexMobile = NSPredicate(format: "SELF MATCHES %@",mobile)
        return regexMobile.evaluate(with: self)
    }
    
    var isIdentityCard: Bool{
        if self.count == 0 {
            return false
        }
        let number = "^(\\d{14}|\\d{17})(\\d|[xX])$"
        let regexNumber = NSPredicate(format: "SELF MATCHES %@",number)
        return regexNumber.evaluate(with: self)
    }
    
    var isPositiveInteger: Bool{
        if self.count == 0 {
            return false
        }
        let integer = "^([1-9][0-9]*){1,3}$"
        let regex = NSPredicate(format: "SELF MATCHES %@",integer)
        return regex.evaluate(with: self)
    }
    
    
    var isEmail: Bool{
        if self.count == 0{
            return false
        }
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
    
    var isPureNumber: Bool {
        let pattern = #"^[+-]?\d+(\.\d+)?$"#
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex.firstMatch(in: self, range: range) != nil
    }
}
