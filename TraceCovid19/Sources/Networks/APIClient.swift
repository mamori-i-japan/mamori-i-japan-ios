//
//  APIClient.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/16.
//

import Foundation
import Alamofire
import FirebaseAuth
import Swinject

final class APIClient {
    private let session: Session
    private let auth: Lazy<Auth>

    init(session: Session, auth: Lazy<Auth>) {
        self.session = session
        self.auth = auth
    }

    func request<T: APIRequestProtocol>(request: T, completionHandler: @escaping (Result<T.Response, APIRequestError>) -> Void) {
        if request.isNeedAuthentication && auth.instance.currentUser != nil {
            auth.instance.currentUser!.getIDToken { token, _ in
                self._request(request: request, accessToken: token, completionHandler: completionHandler)
            }
            return
        }

        _request(request: request, completionHandler: completionHandler)
    }

    private func _request<T: APIRequestProtocol>(request: T, accessToken: String? = nil, completionHandler: @escaping (Result<T.Response, APIRequestError>) -> Void) {
        print("[APIClient] \(request)")
        let response = session.request(
            request.urlString,
            method: Alamofire.HTTPMethod(rawValue: request.method.rawValue),
            parameters: request.parameters,
            headers: HTTPHeaders(request.creaetHeaders(accessToken: accessToken))
        )

        let handler: (DataResponse<T.Response, AFError>) -> Void = { result in
            print("[APIClient] \(String(describing: String(data: result.data ?? Data(), encoding: .utf8)))")

            // TODO: ログアウトする判定どうする？

            let statusCode = result.response?.statusCode
            guard request.acceptableStatusCode.contains(statusCode ?? -1) else {
                completionHandler(.failure(.statusCodeError(statusCode: statusCode, data: result.data, error: result.error)))
                return
            }

            guard let value = result.value, result.error == nil else {
                completionHandler(.failure(.error(detail: result.error)))
                return
            }
            completionHandler(.success(value))
        }

        if let decoder = request.decoder {
            // 指定のDecoderに切り替えてHandlerと接続
            response.responseDecodable(of: T.Response.self, decoder: decoder, completionHandler: handler)
        } else {
            response.responseDecodable(of: T.Response.self, completionHandler: handler)
        }
    }
}
