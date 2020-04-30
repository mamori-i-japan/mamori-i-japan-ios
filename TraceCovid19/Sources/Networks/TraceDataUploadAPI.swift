//
//  TraceDataUploadAPI.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/22.
//

import Foundation

final class TraceDataUploadAPIRequest: APIRequestProtocol {
    typealias Response = EmpytResponse

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

    private let deepContactUsers: [DeepContactUserUploadModel]

    init(deepContactUsers: [DeepContactUserUploadModel]) {
        self.deepContactUsers = deepContactUsers
    }
}

struct DeepContactUserUploadModel: DictionaryEncodable {
    let uniqueInsertKey: String
    let externalTempId: String
    let contactStartTime: Int
    let contactEndTime: Int
}

extension DeepContactUserUploadModel {
    init(deepContactUser: DeepContactUser) {
        let tempId = deepContactUser.tempId
        let startDate = deepContactUser.startTime
        let endDate = deepContactUser.endTime
        externalTempId = tempId
        contactStartTime = Int(startDate.timeIntervalSince1970)
        contactEndTime = Int(endDate.timeIntervalSince1970)
        uniqueInsertKey = "\(externalTempId)\(contactStartTime)\(contactEndTime)".sha256 ?? ""
    }
}

final class TraceDataUploadAPI {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func upload(deepContactUsers: [DeepContactUserUploadModel], completionHandler: @escaping (Result<EmpytResponse, APIRequestError>) -> Void) {
        let request = TraceDataUploadAPIRequest(deepContactUsers: deepContactUsers)
        apiClient.request(request: request, completionHandler: completionHandler)
    }
}
