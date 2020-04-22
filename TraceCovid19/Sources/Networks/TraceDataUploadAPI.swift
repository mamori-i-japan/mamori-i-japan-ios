//
//  TraceDataUploadAPI.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/22.
//

import Foundation

final class TraceDataUploadAPIRequest: APIRequestProtocol {
    typealias Response = TraceDataUploadAPIResponse

    var method: APIRequestMethod {
        return .post
    }
    var path: String {
        return "/users/me/close_contacts"
    }
    var isNeedAuthentication: Bool {
        return true
    }

    var parameters: [String: Any] {
        var result: [String: Any] = [:]
        result["closeContacts"] = deepContactUsers.compactMap { try? $0.asDictionary() }
        return result
    }

    private let deepContactUsers: [DeepContactUserModel]

    init(deepContactUsers: [DeepContactUserModel]) {
        self.deepContactUsers = deepContactUsers
    }
}

struct DeepContactUserModel: DictionaryEncodable {
    let uniqueInsertKey: String
    let externalTempId: String
    let contactStartTime: TimeInterval
    let contactEndTime: TimeInterval
}

extension DeepContactUserModel {
    init?(deepContactUser: DeepContactUser) {
        guard let tempId = deepContactUser.tempId,
            let startDate = deepContactUser.startTime,
            let endDate = deepContactUser.endTime else { return nil }
        externalTempId = tempId
        contactStartTime = startDate.timeIntervalSince1970
        contactEndTime = endDate.timeIntervalSince1970
        uniqueInsertKey = "\(externalTempId)\(contactStartTime)\(contactEndTime)".sha256 ?? ""
    }
}

struct TraceDataUploadAPIResponse: Decodable {
}

final class TraceDataUploadAPI {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func upload(deepContactUsers: [DeepContactUserModel], completionHandler: @escaping (Result<TraceDataUploadAPIResponse, APIRequestError>) -> Void) {
        let request = TraceDataUploadAPIRequest(deepContactUsers: deepContactUsers)
        apiClient.request(request: request, completionHandler: completionHandler)
    }
}
