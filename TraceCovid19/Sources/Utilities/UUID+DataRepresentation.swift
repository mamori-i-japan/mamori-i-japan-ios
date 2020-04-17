//
//  UUID+DataRepresentation.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/09.
//

import Foundation
import CoreBluetooth

extension UUID {
    var data: Data {
        return withUnsafePointer(to: uuid) {
            Data(bytes: $0, count: MemoryLayout.size(ofValue: uuid))
        }
    }

    init?(data: Data) {
        self.init(uuidString: CBUUID(data: data).uuidString)
    }
}
