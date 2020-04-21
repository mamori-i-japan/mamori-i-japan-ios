//
//  BluetoothConfig.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/10.
//

import Foundation
import CoreBluetooth

struct BluetraceConfig {
    static let uuidPeripheralServiceString = "0000C019-0000-1000-8000-00805F9B34FB"
    static let uuidContactEventIdentifierCharacteristicString = "D61F4F27-3D6B-4B04-9E46-C9D2EA617F62" // https://github.com/TCNCoalition/TCN

    static let bluetoothServiceID = CBUUID(string: uuidPeripheralServiceString)
    static let characteristicServiceID = CBUUID(string: uuidContactEventIdentifierCharacteristicString)

    static let charUUIDArray = [characteristicServiceID]

    static let initialMsg = "<unknown>"

    static let CentralScanInterval = 60 // in seconds
    static let CentralScanDuration = 10 // in seconds
    static let TTLDays = -21
}
