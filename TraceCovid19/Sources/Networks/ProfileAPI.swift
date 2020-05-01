//
//  ProfileAPI.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/05/01.
//

import Foundation

final class ProfilePatchAPIRequest: APIRequestProtocol {
    typealias Response = EmpytResponse

    var method: APIRequestMethod {
        return .patch
    }
    var path: String {
        return "/users/me/profile"
    }
    var isNeedAuthentication: Bool {
        return true
    }

    var parameters: [String: Any] {
        var result: [String: Any] = (try? profile.asDictionary()) ?? [:]
        if let organization = organizationCode {
            // organizationCodeは通常ではread-onlyなので除外するが、このAPIでは更新できるので設定する
            result["organizationCode"] = organization
        }
        return result
    }

    private let profile: Profile
    private let organizationCode: String?

    init(profile: Profile, organizationCode: String?) {
        self.profile = profile
        self.organizationCode = organizationCode
    }
}

final class ProfileAPI {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func patch(profile: Profile, organization: String?, completionHandler: @escaping (Result<EmpytResponse, APIRequestError>) -> Void) {
        let request = ProfilePatchAPIRequest(profile: profile, organizationCode: organization)
        apiClient.request(request: request, completionHandler: completionHandler)
    }
}
