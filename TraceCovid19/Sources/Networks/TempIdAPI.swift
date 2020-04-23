//
//  TempIdAPI.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/16.
//

import Foundation

final class TempIdAPIRequest: APIRequestProtocol {
    typealias Response = [TempIdAPIResponse]

    var method: APIRequestMethod {
        return .get
    }
    var path: String {
        return "/users/me/temp_ids"
    }
    var isNeedAuthentication: Bool {
        return true
    }
    var decoder: JSONDecoder? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.iso8601DateFormatter)
        return decoder
    }
}

struct TempIdAPIResponse: Decodable {
    let tempID: String
    let validFrom: Date
    let validTo: Date
}

extension Array: APIResponseType where Element == TempIdAPIResponse {
}

extension Array: DecodableAPIResponseType where Element == TempIdAPIResponse {
}

final class TempIdAPI {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func getTempIDs(completionHandler: @escaping (Result<[TempIdAPIResponse], APIRequestError>) -> Void) {
        let request = TempIdAPIRequest()
        apiClient.request(request: request, completionHandler: completionHandler)
    }
}
