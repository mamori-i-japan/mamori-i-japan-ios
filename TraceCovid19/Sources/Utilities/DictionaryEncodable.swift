//
//  DictionaryEncodable.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/19.
//

import Foundation

protocol DictionaryEncodable: Encodable {
    func asDictionary() throws -> [String: Any]
    var jsonEncoder: JSONEncoder { get }
}

extension DictionaryEncodable {
    var jsonEncoder: JSONEncoder {
        return JSONEncoder()
    }
}

extension DictionaryEncodable {
    func asDictionary() throws -> [String: Any] {
        let data = try jsonEncoder.encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError(domain: "Json serialization error", code: 0, userInfo: nil)
        }
        return dictionary
    }
}
