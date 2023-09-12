//
//  NetworkBridge.swift
//  WhaleBox
//
//  Created by 刘思源 on 2023/9/11.
//

import UIKit
import HandyJSON

@objcMembers class OCBridge: NSObject {
    @objc static func likeVideo(json:String){
        UserStore.checkLoginStatusThen {
            userService.request(.collectVideo(json: json)) { result in
    //            result.hj_map2 { body, error in
    //                if let error = error {
    //                    error.msg.hint()
    //                    return
    //                }
    //            }
            }
        }
    }
}
  

//class SVideo: GKDYVideoModel,HandyJSON{
//    required override init() {
//        super.init()
//    }
//}


class VideoModelWrapper : HandyJSON{
    var video_info: GKDYVideoModel!
    var uid : Int!
    var create_time: String!
    var business_id : Int!
    
    required init() {
        
    }
    
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.video_info <-- TransformOf<GKDYVideoModel, [String: Any]>(fromJSON: { json in
            return GKDYVideoModel.model(withJSON: json as! Any)
        }, toJSON: { model in
            return model!.modelToJSONObject() as? [String: Any]
        })
    }
}

//class VideoModel : HandyJSON{
//    var video_id: String!
//    var title: String!
//    var poster_small: String!
//    var poster_big: String!
//    var poster_pc: String!
//    var source_name: String!
//    var play_url: String!
//    var duration: String!
//    var url: String!
//    var show_tag: String!
//    var publish_time: String!
//    var is_pay_column: String!
//    var like: String!
//    var comment: String!
//    var playcnt: String!
//    var fmplaycnt: String!
//    var fmplaycnt_2: String!
//    var outstand_tag: String!
//    var previewUrlHttp: String!
//    var third_id: String!
//    var vip: String!
//    var author_avatar: String!
//    var isLike = false
//
//    required init() {
//
//    }
//}
