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
        return "/users/me/diagnosis_keys_for_org"
    }
    var isNeedAuthentication: Bool {
        return true
    }

    var parameters: [String: Any] {
        var result: [String: Any] = [
            "randomID": randomID
        ]
        result["tempIDs"] = deepContactUsers.compactMap { try? $0.asDictionary() }
        return result
    }

    private let randomID: String
    private let deepContactUsers: [DeepContactUserUploadModel]

    init(randomID: String, deepContactUsers: [DeepContactUserUploadModel]) {
        self.randomID = randomID
        self.deepContactUsers = deepContactUsers
    }
}

struct DeepContactUserUploadModel: DictionaryEncodable {
    let tempID: String
    let validFrom: Int
    let validTo: Int
}

extension DeepContactUserUploadModel {
    init(deepContactUser: DeepContactUser) {
        tempID = deepContactUser.tempId
        validFrom = Int(deepContactUser.startTime.timeIntervalSince1970)
        validTo = Int(deepContactUser.endTime.timeIntervalSince1970)
    }
}

final class TraceDataUploadAPI {
    private let apiClient: APIClient
    private let keychain: KeychainService

    init(apiClient: APIClient, keychain: KeychainService) {
        self.apiClient = apiClient
        self.keychain = keychain
    }

    func upload(deepContactUsers: [DeepContactUserUploadModel], completionHandler: @escaping (Result<EmpytResponse, APIRequestError>) -> Void) {
        let randomID = creatRandomID()
        let request = TraceDataUploadAPIRequest(randomID: randomID, deepContactUsers: deepContactUsers)
        apiClient.request(request: request) { [weak self] result in
            if case .success = result {
                // NOTE: 成功時に、発行したランダムIDを保存しておく
                self?.keychain.addRandomID(id: randomID)
            }
            completionHandler(result)
        }
    }

    private func creatRandomID() -> String {
        return UUID().uuidString // TODO: ひとまずランダム値をUUIDv4で生成
    }
}
