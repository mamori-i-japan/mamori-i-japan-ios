//
//  UserDefaultsService.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/09.
//

import Foundation

final class UserDefaultsService {
    private(set) var userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func removeAll() {
        userDefaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        userDefaults.synchronize()
    }
}
