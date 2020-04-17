//
//  EncounterRecord.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/12.
//

import Foundation

struct TraceDataRecord: Encodable {
    var timestamp: Date?
    var tempId: String?
//    var msg: String?
//    var modelC: String?
//    private(set) var modelP: String?
    var rssi: Double?
    var txPower: Double?
//    var org: String?
//    var v: Int?
}

extension TraceDataRecord {
//    mutating func update(modelP: String) {
//        self.modelP = modelP
//    }

    init(from centralWriteDataV2: CentralWriteDataV2) {
        self.timestamp = Date()
        self.tempId = centralWriteDataV2.i
//        self.msg = centralWriteDataV2.id
//        self.modelC = centralWriteDataV2.mc
//        self.modelP = DeviceUtility.machineName()
        self.rssi = centralWriteDataV2.rs
//        self.org = centralWriteDataV2.o
//        self.v = centralWriteDataV2.v
    }
}
