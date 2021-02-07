//
//  NetworkModel.swift
//  PTNetworkTool
//
//  Created by Develop on 2021/2/5.
//

import Foundation
import SwiftyJSON

/**
 若使用SwiftyJSON解析json，要给自定义类型写类似Array的JSONable扩展
 */
extension Array: JSONable where Element: JSONable {
    public init(_ json: JSON) {
        self = json.arrayValue.map { Element($0) }
    }
}

extension JSON: JSONable {
    public init(_ json: JSON) {
        self = json
    }
}

/// 通用请求结果模型，实际使用时如跟后端不一致，按照此格式编写对应当前业务的model
public struct RequestResult<T: JSONable> {
    public let code: Int
    
    public let message: String
    
    public let result: Bool
    
    public let data: T
}

extension RequestResult: JSONable {
    public init(_ json: JSON) {
        result = json["result"].boolValue
        code = json["code"].intValue
        message = json["message"].stringValue
        data = T(json["data"])
    }
}
