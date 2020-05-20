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

    func request<T: APIRequestProtocol>(
        request: T,
        completionHandler: @escaping (Result<T.Response, APIRequestError>) -> Void
    ) where T.Response == EmpytResponse {
        print("[APIClient] start \(request)")
        print("[APIClient] parameters: \(request.parameters)")
        fetchIDTokenIfNeeded(request: request) { [weak self] result in
            switch result {
            case .success(let token):
                guard let sSelf = self else { return }
                let dataRequest = sSelf.makeDataRequest(request: request, accessToken: token)
                let handler = sSelf.makeEmptyHandler(request: request, completionHandler: completionHandler)

                dataRequest.response(completionHandler: handler)
            case .failure(let error):
                completionHandler(.failure(.error(detail: error)))
            }
        }
    }

    func request<T: APIRequestProtocol>(
        request: T,
        completionHandler: @escaping (Result<T.Response, APIRequestError>) -> Void
    ) where T.Response: Decodable {
        print("[APIClient] start \(request)")
        print("[APIClient] parameters: \(request.parameters)")
        fetchIDTokenIfNeeded(request: request) { [weak self] result in
            switch result {
            case .success(let token):
                guard let sSelf = self else { return }
                let dataRequest = sSelf.makeDataRequest(request: request, accessToken: token)
                let handler = sSelf.makeDecodableHandler(request: request, completionHandler: completionHandler)

                if let decoder = request.decoder {
                    // 指定のDecoderに切り替えてHandlerと接続
                    dataRequest.responseDecodable(of: T.Response.self, decoder: decoder, completionHandler: handler)
                } else {
                    dataRequest.responseDecodable(of: T.Response.self, completionHandler: handler)
                }
            case .failure(let error):
                completionHandler(.failure(.error(detail: error)))
            }
        }
    }

    private func fetchIDTokenIfNeeded<T: APIRequestProtocol>(request: T, completion: @escaping (Result<String?, Error>) -> Void) {
        if request.isNeedAuthentication {
            guard let currentUser = auth.instance.currentUser else {
                assertionFailure("Should be logged in before posting authenticated request.")
                completion(.success(nil))
                return
            }
            currentUser.getIDTokenResult(completion: { result, error in
                if let result = result {
                    completion(.success(result.token))
                } else if let error = error {
                    completion(.failure(error))
                } else {
                    fatalError("Unreachable")
                }
            }
            )
            return
        }
        completion(.success(nil))
    }

    private func makeDataRequest<T: APIRequestProtocol>(request: T, accessToken: String?) -> DataRequest {
        session.request(
            request.urlString,
            method: Alamofire.HTTPMethod(rawValue: request.method.rawValue),
            parameters: request.parameters,
            encoding: request.encodingType.encoding,
            headers: HTTPHeaders(request.creaetHeaders(accessToken: accessToken))
        )
    }

    private func makeDecodableHandler<T: APIRequestProtocol>(
        request: T,
        completionHandler: @escaping (Result<T.Response, APIRequestError>) -> Void
    ) -> (DataResponse<T.Response, AFError>) -> Void where T.Response: Decodable { { result in
            print("[APIClient] \(String(describing: String(data: result.data ?? Data(), encoding: .utf8)))")

            guard (result.error?.underlyingError as NSError?)?.code != NSURLErrorNotConnectedToInternet else {
                // ネットワークエラー
                completionHandler(.failure(.network))
                return
            }

            let statusCode = result.response?.statusCode
            guard statusCode != 401 else {
                // 401の場合は認証エラー
                completionHandler(.failure(.authzError))
                return
            }

            guard request.acceptableStatusCode.contains(statusCode ?? -1) else {
                if let data = result.data {
                    let str = String(data: data, encoding: .utf8)
                    log("statusCode=\(String(describing: statusCode)), data=\(String(describing: str))")
                }
                completionHandler(.failure(.statusCodeError(statusCode: statusCode, data: result.data, error: result.error)))
                return
            }

            guard let value = result.value, result.error == nil else {
                completionHandler(.failure(.error(detail: result.error)))
                return
            }
            completionHandler(.success(value))
        }
    }

    private func makeEmptyHandler<T: APIRequestProtocol>(
         request: T,
         completionHandler: @escaping (Result<T.Response, APIRequestError>) -> Void
    ) -> (AFDataResponse<Data?>) -> Void where T.Response == EmpytResponse { { result in
             print("[APIClient] \(String(describing: String(data: result.data ?? Data(), encoding: .utf8)))")

            guard (result.error?.underlyingError as NSError?)?.code != NSURLErrorNotConnectedToInternet else {
                // ネットワークエラー
                completionHandler(.failure(.network))
                return
            }

             let statusCode = result.response?.statusCode
             guard statusCode != 401 else {
                 // 401の場合は認証エラー
                 completionHandler(.failure(.authzError))
                 return
             }

             guard request.acceptableStatusCode.contains(statusCode ?? -1) else {
                 completionHandler(.failure(.statusCodeError(statusCode: statusCode, data: result.data, error: result.error)))
                 return
             }

             guard result.error == nil else {
                 completionHandler(.failure(.error(detail: result.error)))
                 return
             }
             completionHandler(.success(EmpytResponse()))
         }
     }
}

extension ParameterEncodingType {
    var encoding: Alamofire.ParameterEncoding {
        switch self {
        case .url:
            return URLEncoding()
        case .json:
            return JSONEncoding()
        }
    }
}
