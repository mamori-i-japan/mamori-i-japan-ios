//
//  TraceDataEntity.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/12.
//

import UIKit
import CoreData

@objc(TraceData)
final class TraceDataEntity: NSManagedObject, Encodable {
}

extension TraceDataEntity {
    @NSManaged var tempId: String?
    @NSManaged var timestamp: Date?
    @NSManaged var rssi: NSNumber?
    @NSManaged var txPower: NSNumber?

    func set(traceDataRecord: TraceDataRecord) {
        setValue(traceDataRecord.timestamp, forKeyPath: "timestamp")
        setValue(traceDataRecord.tempId, forKey: "tempId")
        setValue(traceDataRecord.rssi, forKeyPath: "rssi")
        setValue(traceDataRecord.txPower, forKeyPath: "txPower")
    }

    func toTraceDataRecord() -> TraceDataRecord {
        TraceDataRecord(timestamp: timestamp, tempId: tempId, rssi: rssi?.doubleValue, txPower: txPower?.doubleValue)
    }
}

extension TraceDataEntity {
    var isValidConnection: Bool {
        timestamp != nil
            && tempId != nil
            && tempId!.isValidTempId
            && rssi != nil
    }
}

extension String {
    var isValidTempId: Bool {
        self != CoreDataService.Event.scanningStarted.rawValue
            && self != CoreDataService.Event.scanningStopped.rawValue
            && self != CoreDataService.Event.scanningRestarted.rawValue
            && self != BluetraceConfig.initialMsg
    }
}
