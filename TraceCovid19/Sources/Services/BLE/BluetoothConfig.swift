//
//  BluetoothConfig.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/10.
//

import Foundation
import CoreBluetooth

struct BluetraceConfig {
    static let initialMsg = "<unknown>"

    static let CentralScanInterval = 60 // in seconds
    static let CentralScanDuration = 10 // in seconds
    static let TTLDays = -21
}
