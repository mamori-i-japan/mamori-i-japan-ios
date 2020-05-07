//
//  APIRequest.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/16.
//

import Foundation

enum APIRequestError: Error {
    case statusCodeError(statusCode: Int?, data: Data?, error: Error?)
    case authzError
    case network
    case error(detail: Error?)
}

enum APIRequestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

enum ParameterEncodingType {
    case url
    case json

    var contentType: String {
        switch self {
        case .url:
            return "application/x-www-form-urlencoded"
        case .json:
            return "application/json; charset=utf-8"
        }
    }
}

protocol APIResponseType {
}

protocol DecodableAPIResponseType: APIResponseType, Decodable {
}

struct EmpytResponse: APIResponseType {
}

struct ErrorResponse: Decodable {
    let statusCode: Int
    let error: String?
    let message: String?
}

protocol APIRequestProtocol: CustomStringConvertible {
    associatedtype Response: APIResponseType

    var scheme: String { get }
    var method: APIRequestMethod { get }
    var host: String { get }
    var basePath: String { get }
    var path: String { get }
    var urlString: String { get }
    var headers: [String: String] { get }
    var parameters: [String: Any] { get }
    var encodingType: ParameterEncodingType { get }
    var decoder: JSONDecoder? { get }
    var acceptableStatusCode: Range<Int> { get }
    var isNeedAuthentication: Bool { get }
}

extension APIRequestProtocol {
    var scheme: String {
        return "https://"
    }
    var host: String {
        #if DEV
        return "api-dev.mamori-i.jp"
        #elseif STG
        return "api-stg.mamori-i.jp"
        #elseif PROD
        return "api.mamori-i.jp"
        #else
        fatalError("環境の指定がおかしい")
        #endif
    }
    var basePath: String {
        return ""
    }
    var urlString: String {
        return scheme + host + basePath + path
    }
    var headers: [String: String] {
        return [:]
    }
    var parameters: [String: Any] {
        return [:]
    }
    var encodingType: ParameterEncodingType {
        switch method {
        case .get, .delete:
            return .url
        case .post, .put, .patch:
            return .json
        }
    }
    var acceptableStatusCode: Range<Int> {
        return 200..<300
    }
    var decoder: JSONDecoder? {
        return nil
    }
}

extension APIRequestProtocol {
    func creaetHeaders(accessToken: String? = nil) -> [String: String] {
        var result: [String: String] = headers
        // 共通設定
        result["Content-Type"] = encodingType.contentType

        // Token付与
        if let accessToken = accessToken, isNeedAuthentication {
            result["Authorization"] = "Bearer \(accessToken)"
        }
        return result
    }
}

extension APIRequestProtocol {
    var description: String {
        return "[\(method.rawValue)] \(urlString)"
    }
}
