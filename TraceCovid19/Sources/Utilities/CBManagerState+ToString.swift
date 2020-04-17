//
//  CBManagerState+ToString.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/10.
//

import Foundation
import CoreBluetooth

extension CBManagerState {
    var toString: String {
        switch self {
        case .poweredOff:
            return "poweredOff"
        case .poweredOn:
            return "poweredOn"
        case .resetting:
            return "resetting"
        case .unauthorized:
            return "unauthorized"
        case .unknown:
            return "unknown"
        case .unsupported:
            return "unsupported"
        @unknown default:
            return "unknown"
        }
    }
}
