//
//  Information.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/05/06.
//

import Foundation

struct Information: DictionaryDecodable {
    let messageForAppAccess: String
    let updateAt: String
}

extension Information {
    var updateAtDate: Date? {
        return updateAt.toDate(format: .iso8601DateFormat)
    }
}

extension Information {
    static let empty = Information(messageForAppAccess: "", updateAt: "")
}
