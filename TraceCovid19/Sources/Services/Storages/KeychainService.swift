//
//  KeychainService.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/09.
//

import Foundation

protocol KeychainClientProtocol {
    func get(_ key: String, ignoringAttributeSynchronizable: Bool) throws -> String?
    func getData(_ key: String, ignoringAttributeSynchronizable: Bool) throws -> Data?
    func set(_ value: String, key: String, ignoringAttributeSynchronizable: Bool) throws
    func set(_ value: Data, key: String, ignoringAttributeSynchronizable: Bool) throws
    func remove(_ key: String, ignoringAttributeSynchronizable: Bool) throws
}

extension KeychainClientProtocol {
    func get(_ key: String) throws -> String? {
        try get(key, ignoringAttributeSynchronizable: true)
    }

    func getData(_ key: String) throws -> Data? {
        try getData(key, ignoringAttributeSynchronizable: true)
    }

    func set(_ value: String, key: String) throws {
        try set(value, key: key, ignoringAttributeSynchronizable: true)
    }

    func set(_ value: Data, key: String) throws {
        try set(value, key: key, ignoringAttributeSynchronizable: true)
    }

    func remove(_ key: String) throws {
        try remove(key, ignoringAttributeSynchronizable: true)
    }
}

final class KeychainService {
    private(set) var keychain: KeychainClientProtocol

    init(keychain: KeychainClientProtocol) {
        self.keychain = keychain
    }
}
