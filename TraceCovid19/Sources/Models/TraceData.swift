//
//  TraceData.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/12.
//

import UIKit
import CoreData

@objc(TraceData)
final class TraceData: NSManagedObject, Encodable {
}

extension TraceData {
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
}

extension TraceData {
    var isValidConnection: Bool {
        return timestamp != nil
            && tempId != nil
            && tempId!.isValidTempId
            && rssi != nil
    }
}

extension String {
    var isValidTempId: Bool {
        return self != CoreDataService.Event.scanningStarted.rawValue
            && self != CoreDataService.Event.scanningStopped.rawValue
            && self != BluetraceConfig.initialMsg
    }
}
