//
//  DictionaryCodable+FirebaseTimestamp.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/05/06.
//

import Foundation
import FirebaseFirestore

// MARK: Firebaseのtimestamp対応

extension String {
    static let firebaseTimestampPrefix = "FIRTimestamp:"
}

extension String {
    var dropFribaseTemstampPrefix: String {
        let regex = try? NSRegularExpression(pattern: "^\(String.firebaseTimestampPrefix)", options: [])
        return regex?.stringByReplacingMatches(in: self, options: [], range: NSRange(location: 0, length: count), withTemplate: "") ?? self
    }
}

extension Dictionary where Key == String, Value == Any {
    /// FIRTimestampがValueのままJSONSerializeするとエラーで死ぬので一度Dateの文字列に変換しておく
    func convertFirebaseTimestampToDate() -> [Key: Value] {
        var result = self
        forEach { (key: String, value: Any) in
            if let timestamp = value as? Timestamp {
                result[key] = timestamp.dateValue().toString(format: .iso8601DateFormat)
            }
        }
        return result
    }

    /// 特定のプレフィックスを持つDate文字列のValueをFIRTimestampに変換する
    func convertDateToFirebaseTimestamp() -> [Key: Value] {
        var result = self
        forEach { (key: String, value: Any) in
            if let dateString = value as? String,
                dateString.hasPrefix(.firebaseTimestampPrefix),
                let date = dateString.dropFribaseTemstampPrefix.toDate(format: .iso8601DateFormat) {
                result[key] = Timestamp(date: date)
            }
        }
        return result
    }
}
