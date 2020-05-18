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
    var rssi: Double?
    var txPower: Double?
}

extension TraceDataRecord {
    init(from data: WriteData) {
        self.timestamp = Date()
        self.tempId = data.i
        self.rssi = data.rs
    }
}
