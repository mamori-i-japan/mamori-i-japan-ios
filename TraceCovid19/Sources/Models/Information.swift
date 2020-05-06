//
//  Information.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/05/06.
//

import Foundation

struct Information: DictionaryDecodable {
    let messageForAppAccess: String
    // TODO: いったんはオプショナルにしておくが、あとで外す
    let updateAt: Date?

    static var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.iso8601DateFormatter)
        return decoder
    }()
}

extension Information {
    static let empty = Information(messageForAppAccess: "", updateAt: Date(timeIntervalSince1970: 0))
}
