//
//  String+PhoneNumber.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/11.
//

import Foundation

extension String {
    func phoneNumberValidation() -> Bool {
        let pattern = "^[0-9]{11}$"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let matches = regex.matches(in: self, range: NSRange(location: 0, length: count))
        return matches.count > 0
    }

    /// 電番入力に許されている文字列状態かどうか
    var isPhoneNumberAcceptInput: Bool {
        let pattern = "^[0-9]{0,11}$"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let matches = regex.matches(in: self, range: NSRange(location: 0, length: count))
        return matches.count > 0
    }
}
