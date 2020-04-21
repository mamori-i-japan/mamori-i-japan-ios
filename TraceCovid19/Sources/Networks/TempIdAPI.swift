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
        decoder.dateDecodingStrategy = .formatted(type(of: self).iso8601)
        return decoder
    }

    private static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

struct TempIdAPIResponse: Decodable {
    let tempID: String
    let validFrom: Date
    let validTo: Date
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
