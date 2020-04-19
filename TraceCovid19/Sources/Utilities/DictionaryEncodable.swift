//
//  DictionaryEncodable.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/19.
//

import Foundation

protocol DictionaryEncodable: Encodable {
    func asDictionary() throws -> [String: Any]
}

extension DictionaryEncodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError(domain: "Json serialization error", code: 0, userInfo: nil)
        }
        return dictionary
    }
}
