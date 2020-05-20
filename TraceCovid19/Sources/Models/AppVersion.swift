//
//  AppVersion.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/09.
//

import Foundation

struct AppVersion {
    let major: Int
    let minor: Int
    let patch: Int
}

extension AppVersion: Comparable {
    static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        if lhs.major < rhs.major {
            return true
        } else if lhs.major > rhs.major {
            return false
        }

        if lhs.minor < rhs.minor {
            return true
        } else if lhs.minor > rhs.minor {
            return false
        }

        if lhs.patch < rhs.patch {
            return true
        }

        return false
    }

    static var currentAppVersion: AppVersion {
        guard let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else { fatalError("アプリバージョンが参照できない") }
        return AppVersion(versionString: versionString) ?? { fatalError("アプリバージョンのフォーマットがおかしい") }()
    }
}

private let separator: Character = "."

extension AppVersion {
    init?(versionString: String) {
        guard let versionInfo = versionInfo(versionString) else { return nil }

        major = versionInfo[0]
        minor = versionInfo[1]
        patch = versionInfo[2]
    }

    var versionString: String {
        "\(major)\(separator)\(minor)\(separator)\(patch)"
    }
}

private func versionInfo(_ versionString: String) -> [Int]? {
    let versionInfo = versionString.split(separator: separator).compactMap { Int($0) }
    guard versionInfo.count == 3 else {
        return nil
    }
    return versionInfo
}
