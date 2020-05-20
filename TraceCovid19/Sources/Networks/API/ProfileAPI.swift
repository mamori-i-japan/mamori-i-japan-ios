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
        .patch
    }
    var path: String {
        "/users/me/profile"
    }
    var isNeedAuthentication: Bool {
        true
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

final class ProfileDeleteOrganizationCodeAPIRequest: APIRequestProtocol {
    typealias Response = EmpytResponse

    var method: APIRequestMethod {
        .delete
    }
    var path: String {
        "/users/me/organization"
    }
    var isNeedAuthentication: Bool {
        true
    }

    var encodingType: ParameterEncodingType {
        // DELETEだが、JSONリクエストとして送る
        return .json
    }

    var parameters: [String: Any] {
        (try? randomIDs.asDictionary()) ?? [:]
    }

    private let randomIDs: RandomIDs

    init(randomIDs: [String]) {
        self.randomIDs = RandomIDs(randomIDs: randomIDs)
    }
}

private struct RandomIDs: DictionaryEncodable {
    let randomIDs: [RandomID]

    struct RandomID: DictionaryEncodable {
        let randomID: String
    }

    init(randomIDs: [String]) {
        self.randomIDs = randomIDs.compactMap { .init(randomID: $0) }
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

    func deleteOrganizationCode(randomIDs: [String], completionHandler: @escaping (Result<EmpytResponse, APIRequestError>) -> Void) {
        let request = ProfileDeleteOrganizationCodeAPIRequest(randomIDs: randomIDs)
        apiClient.request(request: request, completionHandler: completionHandler)
    }
}
