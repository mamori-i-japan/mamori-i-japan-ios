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
        return .delete
    }
    var path: String {
        return "/users/me/diagnosis_keys"
    }
    var isNeedAuthentication: Bool {
        return true
    }
}

final class CancelPositiveAPI {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func cancelPositive(completionHandler: @escaping (Result<EmpytResponse, APIRequestError>) -> Void) {
        let request = CancelPositiveAPIRequest()
        apiClient.request(request: request, completionHandler: completionHandler)
    }
}
