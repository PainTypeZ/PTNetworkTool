//
//  PTNetworkTool.swift
//  PTPackage
//
//  Created by PainTypeZ on 2020/11/16.
//

import Foundation
import Moya
import SwiftyJSON

public struct PTNetworkTool {
    public typealias Success<Model> = (_ object: Model) -> Void
    public typealias Failure = (_ errorMessage: String) -> Void
    public typealias Completed = () -> Void
    /// 域名
    public static var baseURLString: String = ""
    /// 登录token
    public static var signInToken: String = ""
    /// 请求头
    public static var header: [String: String] {
        if !signInToken.isEmpty {
            return ["Content-Type": "application/json", "token": signInToken]
        }
        return ["Content-Type": "application/json"]
    }
    
    /// 返回结果转换为 Model<Codable> 的请求
    /// - Parameters:
    ///   - target: 自定义的target
    ///   - success: 请求成功闭包
    ///   - failure: 请求失败或解析失败闭包
    ///   - completed: 请求完成(包括成功和失败)闭包，默认不处理
    public static func request<Target: TargetType, Model: Codable>(target: Target,
                                                            success: @escaping Success<Model>,
                                                            failure: @escaping Failure,
                                                            completed: @escaping Completed = {}) {
        MoyaProvider<Target>().request(target) { result in
            completed()
            switch result {
            case let .success(response):
                do {
                    let model = try JSONDecoder().decode(Model.self, from: response.data)
                    success(model)
                } catch let error {
                    failure(error.localizedDescription)
                }
            case .failure(let error):
                failure(error.localizedDescription)
            }
        }
    }
    
    /// 返回结果转换为 Model<JSONable> 的请求
    /// - Parameters:
    ///   - target: 自定义的target
    ///   - success: 请求成功闭包
    ///   - failure: 请求失败或解析失败闭包
    ///   - completed: 请求完成(包括成功和失败)闭包，默认不处理
    public static func request<Target: TargetType, Model: JSONable>(target: Target,
                                                             success: @escaping Success<Model>,
                                                             failure: @escaping Failure,
                                                             completed: @escaping Completed = {}) {
        MoyaProvider<Target>().request(target) { result in
            completed()
            switch result {
            case let .success(response):
                do {
                    let json = try JSON(data: response.data)
                    let model = Model(json)
                    success(model)
                } catch let error {
                    failure(error.localizedDescription)
                }
            case .failure(let error):
                failure(error.localizedDescription)
            }
        }
    }
    /// 返回结果转换为 Model<Codable> 的上传文件请求
    /// - Parameters:
    ///   - target: 自定义的target
    ///   - success: 请求成功闭包
    ///   - failure: 请求失败或解析失败闭包
    ///   - completed: 请求完成(包括成功和失败)闭包，默认不处理
    public static func upload<Target: TargetType, Model: Codable>(target: Target,
                                                           success: @escaping Success<Model>,
                                                           failure: @escaping Failure,
                                                           progressCallback: @escaping (ProgressResponse) -> Void,
                                                           completed: @escaping Completed = {}) {
        MoyaProvider<Target>().request(target, callbackQueue: nil, progress: {
            progressCallback($0)
        }, completion: { result in
            completed()
            switch result {
            case let .success(response):
                do {
                    let model = try JSONDecoder().decode(Model.self, from: response.data)
                    success(model)
                } catch let error {
                    failure(error.localizedDescription)
                }
            case let .failure(failureContent):
                let failureMessage = failureContent.errorDescription
                failure(failureMessage ?? "")
            }
        })
    }
    
    /// 返回结果转换为 Model<JSONable> 的上传文件请求
    /// - Parameters:
    ///   - target: 自定义的target
    ///   - success: 请求成功闭包
    ///   - failure: 请求失败或解析失败闭包
    ///   - completed: 请求完成(包括成功和失败)闭包，默认不处理
    public static func upload<Target: TargetType, Model: JSONable>(target: Target,
                                                            success: @escaping Success<Model>,
                                                            failure: @escaping Failure,
                                                            progressCallback: @escaping (ProgressResponse) -> Void,
                                                            completed: @escaping Completed = {}) {
        MoyaProvider<Target>().request(target, callbackQueue: nil, progress: {
            progressCallback($0)
        }, completion: { result in
            completed()
            switch result {
            case let .success(response):
                do {
                    let json = try JSON(data: response.data)
                    let model = Model(json)
                    success(model)
                } catch let error {
                    failure(error.localizedDescription)
                }
            case let .failure(failureContent):
                let failureMessage = failureContent.errorDescription
                failure(failureMessage ?? "")
            }
        })
    }
}

public protocol JSONable {
    init(_ json: JSON)
}
/**
 给定默认实现，自定义Target一般只需要按请求方式实现method
 */
public extension TargetType {
    var baseURL: URL {
        return URL.init(string: PTNetworkTool.baseURLString)!
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var headers: [String: String]? {
        return PTNetworkTool.header
    }
}
