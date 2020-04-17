//
//  CBPeripheralState+ToString.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/10.
//

import Foundation
import CoreBluetooth

extension CBPeripheralState {
    var toString: String {
        switch self {
        case .disconnected:
            return "disconnected"
        case .connecting:
            return "connecting"
        case .connected:
            return "connected"
        case .disconnecting:
            return "disconnecting"
        @unknown default:
            return "unknown"
        }
    }
}
