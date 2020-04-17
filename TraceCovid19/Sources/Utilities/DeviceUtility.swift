//
//  DeviceUtility.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/10.
//

import Foundation

enum DeviceUtility {
    /// Model名取得 ex) `iPhone7,3`
    static func machineName() -> String {
        // TODO: モデル名とちゃんとマッピングする
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }
}
