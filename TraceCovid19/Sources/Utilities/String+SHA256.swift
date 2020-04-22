//
//  String+SHA256.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/22.
//

import Foundation
import CommonCrypto

extension String {
    var sha256: String? {
        guard let strData = data(using: .utf8) else { return nil }

        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = strData.withUnsafeBytes {
            CC_SHA256($0.baseAddress, UInt32(strData.count), &digest)
        }

        var sha256String = ""
        for byte in digest {
            sha256String += String(format: "%02x", UInt8(byte))
        }

        return sha256String
    }
}
