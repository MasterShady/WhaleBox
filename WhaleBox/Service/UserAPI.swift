//
//  LoginService.swift
//  gerental
//
//  Created by 刘思源 on 2022/12/21.
//

import UIKit
import Moya
import HandyJSON
import Alamofire

let kUserChanged = Notification(name: .init("kUserChanged"), object: nil)
let kUserMakeOrder = Notification(name: .init("kUserMakeOrder"), object: nil)


let userService = MoyaProvider<UserAPI>(endpointClosure:MoyaProvider.customEndpointMapping, plugins:moyaPlugins)


public enum UserAPI {
    case collectVideoList
    case collectVideo(json:String)
    case deletePost(id: Int)
    case deregister
    case updateUser(nickname:String, avatar: String)
    case collectList
    case collectPost(postId:Int, collect:Bool)
    /*
     type = 0 全部帖子, 1 我的帖子
     atype 用来筛选category
     瓦罗兰特帖子 1
     永劫无间  2
     PC游戏   3
     博德之门  4
     */
    case postList(type: Int = 0, atype: Int? = nil)
    case commentList(id: Int)
    case makePost(type:Int, title:String, content:String, images:String)
    case makeComment(pid: Int, content: String)
    case getNewsList(Int)
    case login(mobile:String, passwd: String)
    case register(mobile:String, passwd: String)
    case getAddressList
    case deleteAddress(id: Int)
    case addAddress(uname: String, phone: String, address_area: String, address_detail:String, is_default: Bool)
    case updateAddress(id:Int ,uname: String, phone: String, address_area: String, address_detail:String, is_default: Bool)
    case makeOrder(id: Int, day: Int)
    case cancelOrder(id: Int)
    case getLikes
    case getFootprints
    case like(id:Int)
    case dislike(id: Int)
}

extension UserAPI: TargetType {
    public var baseURL: URL {
        switch self {
        case .postList, .makePost, .commentList, .collectPost, .login, .register, .makeComment, .updateUser, .deregister, .collectList, .deletePost, .collectVideoList, .collectVideo:
            return URL(string:kPostHost)!
        default:
            return URL(string:kRequestHost)!
        }
    }
    
    public var path: String {
        switch self {
        case .collectVideoList:
            return "getVideoList"
        case .collectVideo:
            return "saveVideo"
        case .deletePost:
            return "delArticle"
        case .deregister:
            return "delUser"
        case .updateUser:
            return "saveUserInfo"
        case .collectList:
            return "userCollect"
        case .collectPost:
            return "setCollect"
        case .commentList:
            return "commentList"
        case .postList:
            return "index"
        case .makePost, .makeComment:
            return "release"
        case .getNewsList(_):
            return "newsList"
        case .login(_,_):
            return "login"
        case .register:
            return "register"
        case .getAddressList:
            return "addressList"
        case .deleteAddress:
            return "delAddress"
        case .addAddress:
            return "addAddress"
        case .updateAddress:
            return "updateAddress"
        case .makeOrder:
            return "addOrder"
        case .cancelOrder:
            return "orderCancel"
        case .getLikes:
            return "userCollect"
        case .like, .dislike:
            return "setCollect"
        case .getFootprints:
            return "userFootprint"

        }
        
        

    }
    public var method: Moya.Method { .post }

    public var task: Task {
        switch self {
        case .collectVideoList:
            return .requestPlain
        case .collectVideo(let json):
            return .requestParameters(parameters: ["video_info":json], encoding: JSONEncoding.default)
        case .deletePost(let id):
            return .requestParameters(parameters: ["id":id], encoding: JSONEncoding.default)
        case .deregister:
            return .requestPlain
        case .updateUser(let nickname, let avatar):
            return .requestParameters(parameters: ["nickname":nickname, "avatar": avatar], encoding: JSONEncoding.default)
        case .makeComment(let pid, let content):
            return .requestParameters(parameters: ["pid":pid, "content": content], encoding: JSONEncoding.default)
        case .collectList:
            return .requestPlain
        case .collectPost(let postId, let collect):
            let collectInt = collect ? 1 : 0
            return .requestParameters(parameters: ["article_id":postId, "status": collectInt], encoding: JSONEncoding.default)
        case .postList(let type, let atype):
            var params = ["type":type] as [String: Any]
            if let atype = atype{
                params["atype"] = atype
            }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .commentList(let id):
            return .requestParameters(parameters: ["id": id], encoding: JSONEncoding.default)
        case .makePost(let type, let title, content: let content, images: let images):
            return .requestParameters(parameters: ["title": title, "content":content, "images": images, "type": type], encoding: JSONEncoding.default)
        case .getNewsList(let type):
            return .requestParameters(parameters: ["type": type], encoding: JSONEncoding.default)
        case .login(let userName, let passwd):
            return .requestParameters(parameters: ["phone": userName, "password": passwd], encoding: JSONEncoding.default)
        case .register(let mobile, let passwd):
            return .requestParameters(parameters: ["phone":mobile,"password":passwd], encoding: JSONEncoding.default)
        case .getAddressList:
            return .requestPlain
        case .deleteAddress(let id):
            return .requestParameters(parameters: ["address_id":id], encoding: JSONEncoding.default)
        case .addAddress(let uname, let phone, let address_area, let address_detail, let is_default):
            return .requestParameters(parameters: [
                "uname":uname,
                "phone":phone,
                "address_area":address_area,
                "address_detail": address_detail,
                "is_default": is_default
            ], encoding: JSONEncoding.default)
        case .updateAddress(id: let id, uname: let uname, phone: let phone, address_area: let address_area, address_detail: let address_detail, is_default: let is_default):
            return .requestParameters(parameters: [
                "address_id": id,
                "uname":uname,
                "phone":phone,
                "address_area":address_area,
                "address_detail": address_detail,
                "is_default": is_default
            ], encoding: JSONEncoding.default)
            
        case .makeOrder(let id, let day):
            let start_date: String = Date().dateString(withFormat: "yyyy-MM-dd")
            let end_date: String = Date().getNearDay(offsetDay: day)!.dateString(withFormat: "yyyy-MM-dd")
            return .requestParameters(parameters: [
                "goods_id": id,
                "order_day" : day,
                "start_date": start_date,
                "end_date": end_date
            ], encoding: JSONEncoding.default)
        case .getLikes:
            return .requestPlain
        case .like(let id):
            return .requestParameters(parameters: ["goods_id": id, "status" : 1], encoding: JSONEncoding.default)
        case .dislike(let id ):
            return .requestParameters(parameters: ["goods_id": id, "status" : 0], encoding: JSONEncoding.default)
        case .cancelOrder(id: let id):
            return .requestParameters(parameters: ["order_id":id], encoding: JSONEncoding.default)
        case .getFootprints:
            return .requestParameters(parameters: ["day_type":1], encoding: JSONEncoding.default)
        }
    }
    
    public var validationType: ValidationType {
        return .successCodes
    }
    public var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    public var headers: [String: String]? {
        [
            "Content-Type": "application/json",
        ]
    }
}


struct UserAccount: HandyJSON{
    var mobile: String!
    
    var nickname: String!
//    var foot_num: Int!
//    var collect_num: Int!
//    var bill_num: Int!
//    var is_sub_merchant: Bool!
    var uid: Int!
    var phone: String!
    var avatar: String?
    var avatarImage : UIImage {
        avatar?.toImage() ?? .init(named: "user_avatar")!
    }

//    required init(){
//
//    }
    
}


struct UserStore {
//    static var remained: Double {
//        get{
//            let double = UserDefaults.standard.object(forKey: "remained") as? NSNumber
//            guard let double = double else {return 200}
//            return double.doubleValue
//        }
//        set{
//            UserDefaults.standard.set(NSNumber(value: newValue), forKey: "remained")
//        }
//    }
    
    static var currentUser: UserAccount?{
        set{
            if let json = newValue?.toJSON(){
                UserDefaults.standard.set(json, forKey: "currentUser")
            }else{
                UserDefaults.standard.removeObject(forKey:"currentUser")
            }
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(kUserChanged)
        }
        get{
            if let json = UserDefaults.standard.dictionary(forKey: "currentUser"){
                let user = UserAccount.deserialize(from: json)!
                //loadCustomProperty(user: user)
                return user
            }
            return nil
        }
    }
    
    static func logout(){
        self.currentUser = nil
    }
    
//    static func loadCustomProperty(user: UserAccount){
//        if let userDefineProperties = UserDefaults.standard.dictionary(forKey: "\(String(describing: user.uid))_userDefineProperties"){
//            user.realname = userDefineProperties["realname"] as? String
//            user.birthday = userDefineProperties["birthday"] as? String
//            user.gender = userDefineProperties["gender"] as? String
//        }else{
//            user.realname = user.nickname
//            user.birthday = "2000-01-01"
//            user.gender = "男"
//        }
//
//        if let userDefinePhotoData = UserDefaults.standard.data(forKey: "\(String(describing: user.uid))_userDefinePhoto"){
//            user.photo = UIImage(data: userDefinePhotoData)
//        }else{
//            user.photo = .init(named: "user_avatar")
//        }
//    }
    
//    static func updateUserCutomProperties(_ user:UserAccount){
//        let dic = [
//            "realname": user.realname,
//            "birthday": user.birthday,
//            "gender": user.gender
//        ]
//        UserDefaults.standard.set(dic, forKey: "\(String(describing: user.uid))_userDefineProperties")
//        let data = user.photo.jpegData(compressionQuality: 1)
//        UserDefaults.standard.set(data, forKey:"\(String(describing: user.uid))_userDefinePhoto" )
//        UserDefaults.standard.synchronize()
//    }
    
    
    static var isLogin: Bool{
        return currentUser != nil
    }
    
    static func checkLoginStatusThen(_ block:()->()){
        if isLogin{
            block()
        }else{
            UIViewController.getCurrentNav().pushViewController(LoginVC(), animated: true)
        }
        
        
    }
    
}



