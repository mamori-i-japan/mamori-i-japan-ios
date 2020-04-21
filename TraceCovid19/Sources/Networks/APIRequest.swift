//
//  APIRequest.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/16.
//

import Foundation

enum APIRequestError: Error {
    case statusCodeError(statusCode: Int?, data: Data?, error: Error?)
    case error(detail: Error?)
}

enum APIRequestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol APIRequestProtocol: CustomStringConvertible {
    associatedtype Response: Decodable

    var scheme: String { get }
    var method: APIRequestMethod { get }
    var host: String { get }
    var basePath: String { get }
    var path: String { get }
    var urlString: String { get }
    var headers: [String: String] { get }
    var parameters: [String: Any] { get }
    var decoder: JSONDecoder? { get }
    var acceptableStatusCode: Range<Int> { get }
    var isNeedAuthentication: Bool { get }
}

extension APIRequestProtocol {
    var scheme: String {
        return "https://"
    }
    var host: String {
        // TODO: 環境わけ
        return "35111ugog3.execute-api.ap-northeast-1.amazonaws.com"
    }
    var basePath: String {
        // TODO: 環境わけ
        return "/dev"
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
