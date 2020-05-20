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
    /// デコード対象外にするキー
    static var ignoreDecodeKeys: [String] { get }
}

extension DictionaryDecodable {
    static var jsonDecoder: JSONDecoder {
        JSONDecoder()
    }

    static var ignoreDecodeKeys: [String] {
        []
    }
}

extension DictionaryDecodable {
    static func make(dictionary: [String: Any]) throws -> Self {
        // 対象外のキーをフィルタリング
        let filteredDictionary = dictionary.filter { !ignoreDecodeKeys.contains($0.key) }

        guard let data = try? JSONSerialization.data(withJSONObject: filteredDictionary, options: [.fragmentsAllowed]) else {
            throw NSError(domain: "Json serialization error", code: 0, userInfo: nil)
        }
        return try jsonDecoder.decode(self, from: data)
    }
}
