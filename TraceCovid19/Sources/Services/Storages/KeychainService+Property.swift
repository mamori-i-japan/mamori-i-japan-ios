//
//  KeychainService+Property.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/09.
//

import Foundation

private extension String {
    static let randomIDs = "randomIDs"
}

extension KeychainService {
    var properties: [String] {
        return [
            .randomIDs
        ]
    }

    func removeAll() {
        properties.forEach {
            _ = try? keychain.remove($0)
        }
    }
}

extension KeychainService {
    var randomIDs: [String] {
        get {
            guard let data = try? keychain.getData(.randomIDs) else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            // JSONエンコードして保存する
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            try? keychain.set(data, key: .randomIDs)
        }
    }

    func addRandomID(id: String) {
        var ids = randomIDs
        ids.append(id)
        randomIDs = ids
    }
}
