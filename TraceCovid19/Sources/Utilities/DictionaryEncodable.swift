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
    /// エンコード対象外にするキー
    static var ignoreEncodeKeys: [String] { get }
}

extension DictionaryEncodable {
    var jsonEncoder: JSONEncoder {
        return JSONEncoder()
    }

    static var ignoreEncodeKeys: [String] {
        return []
    }
}

extension DictionaryEncodable {
    func asDictionary() throws -> [String: Any] {
        let data = try jsonEncoder.encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError(domain: "Json serialization error", code: 0, userInfo: nil)
        }

        // 対象外のキーをフィルタリングして返却
        return dictionary.filter { !type(of: self).ignoreEncodeKeys.contains($0.key) }
    }
}
