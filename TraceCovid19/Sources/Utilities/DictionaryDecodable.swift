//
//  DictionaryDecodable.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/19.
//

import Foundation

protocol DictionaryDecodable: Decodable {
    static func make(dictionary: [String: Any]) throws -> Self
    static var jsonDecoder: JSONDecoder { get }
}

extension DictionaryDecodable {
    static var jsonDecoder: JSONDecoder {
        return JSONDecoder()
    }
}

extension DictionaryDecodable {
    static func make(dictionary: [String: Any]) throws -> Self {
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: [.fragmentsAllowed]) else {
            throw NSError(domain: "Json serialization error", code: 0, userInfo: nil)
        }
        return try jsonDecoder.decode(self, from: data)
    }
}
