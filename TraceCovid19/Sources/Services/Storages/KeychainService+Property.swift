//
//  KeychainService+Property.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/09.
//

import Foundation

private extension String {
    static let randomToken = "randomToken"
}

extension KeychainService {
    var properties: [String] {
        return [
            .randomToken
        ]
    }

    func removeAll() {
        properties.forEach {
            _ = try? keychain.remove($0)
        }
    }
}

extension KeychainService {
//    var randomToken: String? {
//        get {
//            // TODO: 暫定的に、ランダム文字列を固定値として扱う
//            return "helloworld"
////            return try? keychain.get(.randomToken)
//        }
//        set {
//            guard let value = newValue else {
//                try? keychain.remove(.randomToken)
//                return
//            }
//            try? keychain.set(value, key: .randomToken)
//        }
//    }
}
