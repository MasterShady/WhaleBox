//
//  News.swift
//  WhaleBox
//
//  Created by 刘思源 on 2023/9/5.
//

import Foundation
import HandyJSON

let nameTransform = TransformOf<String, String>(fromJSON: { raw in
    return raw?.replacingOccurrences(of: "博德之门", with: "刀锋之影")
}, toJSON: { string in
    return string
})

open class StringToArrayTransform: TransformType {
    public typealias Object = [String]
    public typealias JSON = String
    
    open func transformFromJSON(_ value: Any?) -> [String]? {
        if let raw = value as? String {
            if raw.count == 0{
                return []
            }
            return raw.components(separatedBy: ",")
        }
        return []
    }
    
    open func transformToJSON(_ value: [String]?) -> String? {
        if let array = value {
            return array.joined(separator:",")
        }
        return nil
    }
}



struct News : HandyJSON{
    var id = 0
    var business_id = 0
    var title : String?
    var img_url = ""
    var description : String?
    var detail_url : String?
    var detail_content = ""
    var detail_imgs : [String] = []
    var publish_time : String?
    var comment_num = 0
    var type = 0
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper <<< self.detail_imgs <-- StringToArrayTransform()
        mapper <<< self.title <-- nameTransform
        mapper <<< self.detail_content <-- nameTransform
    }
}
