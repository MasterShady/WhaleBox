//
//  Moya++.swift
//  ferental
//
//  Created by 刘思源 on 2023/1/5.
//

import Foundation
import Moya
import HandyJSON
import JavaScriptCore
import RxSwift



let rc4Key = "ADri+vAy6v/5SOuFptOMl89+4IVZ1H3BDXvLqmyUJ+8=".aes256decode()
//自定义domain
let kNetworkDomain = "com.whaleBox.networkDomain"

let aid = "500180041"


//公共参数
public extension MoyaProvider {
    final class func customEndpointMapping(for target: Target) -> Endpoint {
        let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
        
        switch defaultEndpoint.task {
        case .requestParameters(let params, let encoding):
            //添加共用参数
            var publicParams = params
            if UserStore.isLogin{
                publicParams["uid"] = UserStore.currentUser?.uid
            }
            return  Endpoint(url: defaultEndpoint.url, sampleResponseClosure: defaultEndpoint.sampleResponseClosure, method: defaultEndpoint.method, task: .requestParameters(parameters: publicParams, encoding: encoding), httpHeaderFields: ["aid" : aid])
        case .requestPlain:
            var publicParams = [String:Any]()
            if UserStore.isLogin{
                publicParams["uid"] = UserStore.currentUser?.uid
            }
            return Endpoint(url: defaultEndpoint.url, sampleResponseClosure: defaultEndpoint.sampleResponseClosure, method: defaultEndpoint.method, task: .requestParameters(parameters: publicParams, encoding: JSONEncoding.default), httpHeaderFields: ["aid" : aid])
        default:
            break
        }
        return defaultEndpoint
    }
}



//自定义解析
#if DEBUG
let moyaPlugins: [PluginType] = [
    RC4DecodePlugin(),
    NetworkLoggerPlugin(configuration: .init(formatter: .init(responseData: JSONResponseDataFormatter),
                                             logOptions: .verbose)),
]
#else
let moyaPlugins: [PluginType] = [
    RC4DecodePlugin()]
#endif


//Json解析
func JSONResponseDataFormatter(_ data: Data) -> String {
    do {
        let rawString = String(data: data, encoding: .utf8)!
        let decodedString = RC4Tool.rc4Decode(rawString, key: rc4Key)
        let jsonData = decodedString.data(using: .utf8)!
        let dataAsJSON = try JSONSerialization.jsonObject(with: jsonData)
        let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return String(data: prettyData, encoding: .utf8) ?? String(data: data, encoding: .utf8) ?? ""
    } catch {
        return String(data: data, encoding: .utf8) ?? ""
    }
}





extension Response {
    private struct AssociatedKeys {
        static var jsonKey = "jsonKey"
    }
    var jsonObj: [String:Any] {
        get {
            if let value = objc_getAssociatedObject(self, &AssociatedKeys.jsonKey) as? [String:Any] {
                return value
            }
            let value = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let value = value as? [String:Any]{
                objc_setAssociatedObject(self, &AssociatedKeys.jsonKey, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return value
            }
            let emptyValue = [String:Any]()
            objc_setAssociatedObject(self, &AssociatedKeys.jsonKey, emptyValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return emptyValue
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.jsonKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}


struct RC4DecodePlugin: PluginType {
    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        switch result {
        case let .success(response):
            let rawString = String(data: response.data, encoding: .utf8)!
            let decodedString = RC4Tool.rc4Decode(rawString, key: rc4Key)
            let jsonData = decodedString.data(using: .utf8)!
            let jsonObj = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
            if let jsonObj = jsonObj as? [String:Any]{
                response.jsonObj = jsonObj
            }
            return .success(response)
        case let .failure(error):
            print("Request error: \(error)")
        }
        return result
    }
}





//时间戳毫秒解析为Date
class TimeStampMsTransform : DateTransform{
    open override func transformFromJSON(_ value: Any?) -> Date? {
        if let timeInt = value as? Double {
            return Date(timeIntervalSince1970: TimeInterval(timeInt / 1000))
        }
        
        if let timeStr = value as? String {
            return Date(timeIntervalSince1970: TimeInterval(atof(timeStr) / 1000))
        }
        
        return nil
    }
    
    open override func transformToJSON(_ value: Date?) -> Double? {
        if let date = value {
            return Double(date.timeIntervalSince1970 * 1000)
        }
        return nil
    }
}




//MARK: Moya的各种模型转换, 依赖HandJSON, 推荐使用 `hj_map2` 方法
typealias ResponseCallBack<D> = (Result<D,MoyaError>)->()
typealias ResponseBodyCallBack<DecodedType:HandyJSON> = (ResponseBody<DecodedType>?, ResponseError?) ->()

public enum ResponseError: Swift.Error {
    //请求错误
    case requestFailedError(MoyaError)
    //下面都是解析错误
    case mapJsonError(MoyaError)
    case bodyHasNoData
    case dataFormmatError
    case bodyDecode
    case bodyIsNotDictionary
    case keyPathError
    case notSuccess(ResponseBodyProtocol)
    
    var msg: String{
        switch self {
        case .requestFailedError(let moyaError):
            return moyaError.localizedDescription
        case .mapJsonError(let moyaError):
            return moyaError.localizedDescription
        case .bodyHasNoData:
            return "返回data为空"
        case .dataFormmatError:
            return "返回data结构错误"
        case .bodyDecode:
            return "body解析错误"
        case .bodyIsNotDictionary:
            return "body结构错误"
        case .keyPathError:
            return "解析路径错误"
        case .notSuccess(let responseBody):
            return responseBody.msg ?? "服务器未知错误"
        }
    }
}

public protocol ResponseBodyProtocol {
    var msg: String? { get set }
    var status: String! { get set }
    var data: Any? { get set }
    var code: Int! {get set}
}




public struct ResponseBody<DecodedType:HandyJSON>: HandyJSON, ResponseBodyProtocol{
    public var status: String!
    public var msg: String?
    public var code : Int!
    public var data: Any?
    public var decodedObj: DecodedType?
    public var decodedObjList: [DecodedType]?
    mutating public func mapping(mapper: HelpingMapper) {
        mapper >>> self.decodedObj
        mapper >>> self.decodedObjList
        //mapper <<< self.success <-- "success"
        
    }
    public init(){
        
    }
}


public struct IgnoreData: HandyJSON{
    public init() {
        
    }
}



extension Result where Success : Moya.Response , Failure == MoyaError{
    
    
    /// Edition 2, 别搞枚举抛出了, 写的累, 这是根据具体项目的返回数据接口来设计的. 适用性不如原版本.
    /// - Parameters:
    ///   - type: 解析的数据类型
    ///   - keyPath: 解析的数据相对于data的路径,
    ///   - failsOnEmptyData: mapJSON 参数
    ///   - responseCallBack: 回调
    func hj_map2<D: HandyJSON>(_ type:D.Type = IgnoreData.self, atKeyPath keyPath:String? = nil,responseCallBack:ResponseBodyCallBack<D>){
        switch self {
        case let .success(response):
            if var responseBody = ResponseBody<D>.deserialize(from: response.jsonObj){
                //服务端返回success 为false 直接当错误处理
                if responseBody.code != 0{
                    responseCallBack(nil, .notSuccess(responseBody))
                    return
                }
                if let data = responseBody.data as? NSDictionary{
                    //字典需要判断keyPath
                    var rawObj:Any? = data
                    if let keyPath = keyPath {
                        rawObj = data.value(forKeyPath: keyPath)
                    }
                    if let rawDic = rawObj as? NSDictionary {
                        //字典
                        responseBody.decodedObj = D.deserialize(from: rawDic)
                        responseCallBack(responseBody,nil)
                    }else if let rawArray = rawObj as? NSArray{
                        //数组
                        responseBody.decodedObjList = [D].deserialize(from: rawArray)?.compactMap({$0})
                        responseCallBack(responseBody,nil)
                    }else{
                        //TODO: 处理Json字符串
                        responseCallBack(nil,.keyPathError)
                    }
                }else if let rawArray = responseBody.data as? NSArray{
                    //数组就不判断keyPath了
                    responseBody.decodedObjList = [D].deserialize(from: rawArray)?.compactMap({$0})
                    responseCallBack(responseBody,nil)
                    
                }else{
                    //data不是数组和字典, 属于格式错误
                    responseCallBack(nil,.dataFormmatError)
                }
            }else{
                //body解码错误
                responseCallBack(nil,.bodyDecode)
            }
            
        case let .failure(error):
            responseCallBack(nil, .requestFailedError(error))
            break
        }
    }
    
    /** Moya 风格的API,  解析完成的数据模型或者错误,通过Result的关联的Tupple对象返回,  这是1.0版写的 感觉写起来不是很方便, 推荐用hj_map2 */
    func hj_map<D: HandyJSON>(_ type:D.Type, atKeyPath keyPath: String,failsOnEmptyData: Bool = true) -> Result<(D,Moya.Response),MoyaError>{
        switch self {
        case let .success(response):
            do {
                let obj = try response.hj_map(type, atKeyPath: keyPath, failsOnEmptyData: failsOnEmptyData)
                return .success((obj, response))
            } catch let error as MoyaError{
                return .failure(error)
            } catch let otherError{
                return .failure(.underlying(otherError, response))
            }
        case let .failure(error):
            return .failure(error)
        }
    }
    
    
    func hj_map<D: HandyJSON>(_ type:D.Type, atKeyPath keyPath: String,failsOnEmptyData: Bool = true,responseCallBack:ResponseCallBack<(D,Moya.Response)>){
        switch self {
        case let .success(response):
            do {
                let obj = try response.hj_map(type, atKeyPath: keyPath ,failsOnEmptyData: failsOnEmptyData)
                responseCallBack(.success((obj, response)))
            } catch let error as MoyaError{
                responseCallBack(.failure(error))
            } catch let otherError{
                responseCallBack(.failure(.underlying(otherError, response)))
            }
            
        case let .failure(error):
            responseCallBack(.failure(error))
            break
        }
    }
    
    
    func hj_mapArray<D: HandyJSON>(_ type: D.Type, atKeyPath keyPath: String,failsOnEmptyData: Bool = true) -> Result<([D],Moya.Response),MoyaError>{
        switch self {
        case let .success(response):
            do {
                let obj = try response.hj_mapArray(type, atKeyPath: keyPath, failsOnEmptyData: failsOnEmptyData)
                return .success((obj, response))
            } catch let error as MoyaError{
                return .failure(error)
            } catch let otherError{
                return .failure(.underlying(otherError, response))
            }
        case let .failure(error):
            return .failure(error)
        }
    }
    
    func hj_mapArray<D: HandyJSON>(_ type:D.Type, atKeyPath keyPath: String,failsOnEmptyData: Bool = true,responseCallBack: ResponseCallBack<([D],Moya.Response)>){
        switch self {
        case let .success(response):
            do {
                let obj = try response.hj_mapArray(type, atKeyPath: keyPath ,failsOnEmptyData: failsOnEmptyData)
                responseCallBack(.success((obj, response)))
            } catch let error as MoyaError{
                responseCallBack(.failure(error))
            } catch let otherError{
                responseCallBack(.failure(.underlying(otherError, response)))
            }
            
        case let .failure(error):
            responseCallBack(.failure(error))
            break
        }
    }
    
    
}

extension Response{
    func hj_map3<D:HandyJSON>(_ type:D.Type, atKeyPath keyPath:String?, responseCallBack:ResponseBodyCallBack<D>? = nil) {
        if var responseBody = ResponseBody<D>.deserialize(from: self.jsonObj){
            //服务端返回success 为false 直接当错误处理
            if responseBody.code != 0{
                responseCallBack?(nil, .notSuccess(responseBody))
                return
            }
            if let data = responseBody.data as? NSDictionary{
                //字典需要判断keyPath
                var rawObj:Any? = data
                if let keyPath = keyPath {
                    rawObj = data.value(forKeyPath: keyPath)
                }
                if let rawDic = rawObj as? NSDictionary {
                    //字典
                    responseBody.decodedObj = D.deserialize(from: rawDic)
                    responseCallBack?(responseBody,nil)
                }else if let rawArray = rawObj as? NSArray{
                    //数组
                    responseBody.decodedObjList = [D].deserialize(from: rawArray)?.compactMap({$0})
                    responseCallBack?(responseBody,nil)
                }else{
                    //TODO: 处理Json字符串
                    responseCallBack?(nil,.keyPathError)
                }
            }else if let rawArray = responseBody.data as? NSArray{
                //数组就不判断keyPath了
                responseBody.decodedObjList = [D].deserialize(from: rawArray)?.compactMap({$0})
                responseCallBack?(responseBody,nil)
                
            }else{
                //data不是数组和字典, 属于格式错误
                responseCallBack?(nil,.dataFormmatError)
            }
        }else{
            //body解码错误
            responseCallBack?(nil,.bodyDecode)
        }
        
    }
    
    
    
    func hj_map<D: HandyJSON>(_ type: D.Type, atKeyPath keyPath: String, failsOnEmptyData: Bool = true) throws -> D {
        
        //Moya 中的 map 方法要求 对象实现 Decodable 协议. 我们这里用的是HandyJSON来做转换
        
        guard let success = self.jsonObj["success"] as? Bool else{
            //服务端没返回success字段
            let error = NSError(domain: kNetworkDomain, code: 1001, userInfo: [
                NSLocalizedFailureErrorKey: "data formmat error"
            ])
            throw MoyaError.underlying(error, self)
        }
        
        if !success{
            //返回success == false
            let error = NSError(domain: kNetworkDomain, code: 1002, userInfo: [
                NSLocalizedFailureErrorKey:"服务端返回错误,前端无法判断原因,需要服务端添加字段来提示用户"
            ])
            throw MoyaError.underlying(error, self)
        }
        
        if let obj = type.deserialize(from: self.jsonObj,designatedPath: keyPath){
            return obj
        }else{
            let error = NSError(domain: kNetworkDomain, code: 1000, userInfo: [
                NSLocalizedFailureErrorKey: "模型解析错误"
            ])
            throw MoyaError.underlying(error, self)
        }
    }
    
    
    
    
    func hj_mapArray<D: HandyJSON>(_ type: D.Type, atKeyPath keyPath: String, failsOnEmptyData: Bool = true) throws -> [D] {
        do{
            guard let array = jsonObj[keyPath] as? NSArray else {
                throw MoyaError.stringMapping(self)
            }
            if let obj = [D].deserialize(from: array)?.compactMap({$0}){
                return obj
            }else{
                let error = NSError(domain: kNetworkDomain, code: 1000)
                throw MoyaError.underlying(error, self)
            }
            
        }
        catch(let error){
            throw error
        }
    }
    
    func mapNSArray() throws -> NSArray {
        let any = try self.mapJSON()
        guard let array = any as? NSArray else {
            throw MoyaError.jsonMapping(self)
        }
        return array
    }
}


extension ObservableType where Element == Moya.Response {
    public func mapToBody<T: HandyJSON>(type: T.Type = IgnoreData.self) -> Observable<(ResponseBody<T>?, ResponseError?)> {
        return flatMap { response -> Observable<(ResponseBody<T>?, ResponseError?)> in
            if response.statusCode == 6666{
                let error = try! NSKeyedUnarchiver.unarchivedObject(ofClass: NSError.self, from: response.data)!
                return Observable.just((nil, ResponseError.requestFailedError(.underlying(error, nil))))
            }
            
            return Observable.just(response.mapToBody(T.self))
        }
    }
}


/// json数据 转 模型
extension Moya.Response {
    func mapToBody<T: HandyJSON>(_ type: T.Type = IgnoreData.self)  -> (ResponseBody<T>?,ResponseError?){
        if var body = ResponseBody<T>.deserialize(from: self.jsonObj){
            if body.code != 0{
                return (nil, ResponseError.notSuccess(body))
            }
            if let data = body.data as? NSDictionary{
                body.decodedObj = T.deserialize(from: data)
            }else if let rawArray = body.data as? NSArray{
                body.decodedObjList = [T].deserialize(from: rawArray)?.compactMap({$0})
            }
            return (body, nil)
        }
         return (nil, ResponseError.bodyDecode)
    }
}


//public struct EmptyHandyJSON: HandyJSON{
//    public init() {
//
//    }
//}
