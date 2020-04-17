//
//  UserDefaultsService+Property.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/09.
//

import Foundation

private extension String {
    static let lastUseAppVersion = "lastUseAppVersion"
}

extension UserDefaultsService {
    var lastUseAppVersion: AppVersion? {
        get {
            guard let raw = userDefaults.value(forKey: .lastUseAppVersion) as? String else { return nil }
            return AppVersion(versionString: raw)
        }
        set {
            userDefaults.set(newValue?.versionString, forKey: .lastUseAppVersion)
            userDefaults.synchronize()
        }
    }
}
