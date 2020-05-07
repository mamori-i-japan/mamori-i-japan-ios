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
        var result: [String: Any] = (try? tempIDs.asDictionary()) ?? [:]
        result["randomID"] = randomID
        return result
    }

    private let randomID: String
    private let tempIDs: TempIDs

    init(randomID: String, tempUserIds: [TempUserId]) {
        self.randomID = randomID
        self.tempIDs = TempIDs(tempIDs: tempUserIds.compactMap { .init(tempUserId: $0) })
    }
}

private struct TempIDs: DictionaryEncodable {
    let tempIDs: [TempID]

    struct TempID: DictionaryEncodable {
        let tempID: String
        let validFrom: Int
        let validTo: Int

        init(tempUserId: TempUserId) {
            tempID = tempUserId.tempId
            validFrom = Int(tempUserId.startTime.timeIntervalSince1970)
            validTo = Int(tempUserId.endTime.timeIntervalSince1970)
        }
    }
}

final class TraceDataUploadAPI {
    private let apiClient: APIClient
    private let keychain: KeychainService

    init(apiClient: APIClient, keychain: KeychainService) {
        self.apiClient = apiClient
        self.keychain = keychain
    }

    func upload(tempUserIds: [TempUserId], completionHandler: @escaping (Result<EmpytResponse, APIRequestError>) -> Void) {
        let randomID = creatRandomID()
        let request = TraceDataUploadAPIRequest(randomID: randomID, tempUserIds: tempUserIds)
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
