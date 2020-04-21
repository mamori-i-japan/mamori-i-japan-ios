//
//  LoginAPI.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/09.
//

import Foundation

final class LoginAPIRequest: APIRequestProtocol {
    typealias Response = LoginAPIResponse

    var method: APIRequestMethod {
        return .post
    }
    var path: String {
        return "/auth/login"
    }
    var isNeedAuthentication: Bool {
        return true
    }
}

struct LoginAPIResponse: Decodable {
}

final class LoginAPI {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func login(completionHandler: @escaping (Result<LoginAPIResponse, APIRequestError>) -> Void) {
        let request = LoginAPIRequest()
        apiClient.request(request: request, completionHandler: completionHandler)
    }
}
