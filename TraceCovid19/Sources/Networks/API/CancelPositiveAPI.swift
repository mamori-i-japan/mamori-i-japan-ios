//
//  CancelPositiveAPI.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/05/15.
//

import Foundation

final class CancelPositiveAPIRequest: APIRequestProtocol {
    typealias Response = EmpytResponse

    var method: APIRequestMethod {
        .delete
    }
    var path: String {
        "/users/me/diagnosis_keys"
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

final class CancelPositiveAPI {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func cancelPositive(randomIDs: [String], completionHandler: @escaping (Result<EmpytResponse, APIRequestError>) -> Void) {
        let request = CancelPositiveAPIRequest(randomIDs: randomIDs)
        apiClient.request(request: request, completionHandler: completionHandler)
    }
}
