//
//  APIRequest+Alamofire.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/16.
//

import Foundation
import Alamofire

import FirebaseAuth
import SwinjectStoryboard

extension APIRequestProtocol {
    func request(completionHandler: @escaping (Result<Response, APIRequestError>) -> Void) {
        // TODO: mobileSecretのいれかた
        let mobileSecret = SwinjectStoryboard.defaultContainer.resolve(KeychainService.self)!.randomToken!

        if isNeedAuthentication && Auth.auth().currentUser != nil {
            // TODO: Authのいれかた
            Auth.auth().currentUser!.getIDToken { token, _ in
                self._request(mobileSecret: mobileSecret, accessToken: token, completionHandler: completionHandler)
            }
            return
        }

        _request(mobileSecret: mobileSecret, completionHandler: completionHandler)
    }

    private func _request(mobileSecret: String, accessToken: String? = nil, completionHandler: @escaping (Result<Response, APIRequestError>) -> Void) {
        let response = AF.request(
            urlString,
            method: Alamofire.HTTPMethod(rawValue: method.rawValue),
            parameters: parameters,
            headers: HTTPHeaders(creaetHeaders(mobileSecret: mobileSecret, accessToken: accessToken))
        )

        let handler: (DataResponse<Response, AFError>) -> Void = { result in
            print("[API] \(String(describing: String(data: result.data ?? Data(), encoding: .utf8)))")

            // TODO: ログアウトする判定どうする？

            let statusCode = result.response?.statusCode
            guard self.acceptableStatusCode.contains(statusCode ?? -1) else {
                completionHandler(.failure(.statusCodeError(statusCode: statusCode, data: result.data, error: result.error)))
                return
            }

            guard let value = result.value, result.error == nil else {
                completionHandler(.failure(.error(detail: result.error)))
                return
            }
            completionHandler(.success(value))
        }

        if let decoder = self.decoder {
            // 指定のDecoderに切り替えてHandlerと接続
            response.responseDecodable(of: Response.self, decoder: decoder, completionHandler: handler)
        } else {
            response.responseDecodable(of: Response.self, completionHandler: handler)
        }
    }
}
