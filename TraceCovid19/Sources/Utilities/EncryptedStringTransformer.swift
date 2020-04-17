//
//  EncryptedStringTransformer.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/15.
//

import Foundation
import RNCryptor

/// CoreDataの特定のStringのフィールドを暗号化・複合化するための変換
///
/// ```
/// // 以下をCoreData側で指定すること
/// Type: Transformable
/// Transformer: EncryptedStringTransformer
/// CustomClass: String
/// ```
@objc(EncryptedStringTransformer)
final class EncryptedStringTransformer: ValueTransformer {
    private var p: String {
        return "feawpjfa+JF213jifop"
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let valueString = value as? String,
            let data = valueString.data(using: .utf8) else {
                return nil
        }

        let ciphertext = RNCryptor.encrypt(data: data, withPassword: p)
        return ciphertext
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else {
            return nil
        }
        do {
            let originalData = try RNCryptor.decrypt(data: data, withPassword: p)
            return String(data: originalData, encoding: .utf8)
        } catch {
            print(error)
            return nil
        }
    }
}
