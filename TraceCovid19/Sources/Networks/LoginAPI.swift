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

    var parameters: [String: Any] {
        var result: [String: Any] = [:]
        if let prefecture = prefecture {
            result["prefecture"] = prefecture
        }
        if let job = job {
            result["job"] = job
        }
        return result
    }

    private let prefecture: Int?
    private let job: String?

    init(profile: Profile) {
        prefecture = profile.prefecture
        job = profile.job
    }
}

struct LoginAPIResponse: DecodableAPIResponseType {
}

final class LoginAPI {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func login(profile: Profile, completionHandler: @escaping (Result<LoginAPIResponse, APIRequestError>) -> Void) {
        let request = LoginAPIRequest(profile: profile)
        apiClient.request(request: request, completionHandler: completionHandler)
    }
}
