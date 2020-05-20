//
//  AppStatus.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/19.
//

import Foundation

struct AppStatus: Decodable {
    let ios: AppStatusDetail
}

struct AppStatusDetail: Decodable {
    let isMaintenance: Bool
    let minVersion: String
    let storeUrl: URL
}

extension AppStatusDetail {
    var minAppVersion: AppVersion? {
        AppVersion(versionString: minVersion)
    }
}
