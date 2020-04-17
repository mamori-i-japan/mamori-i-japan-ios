//
//  TempUserId.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/17.
//

import Foundation
import CoreData

@objc(TempUserId)
final class TempUserId: NSManagedObject, Encodable {
}

extension TempUserId {
    @NSManaged var tempId: String?
    @NSManaged var expiryTime: Date?
    @NSManaged var startTime: Date?

    func set(tempIdStruct: TempIdStruct) {
        setValue(tempIdStruct.tempId, forKeyPath: "tempId")
        setValue(tempIdStruct.endTime, forKey: "expiryTime")
        setValue(tempIdStruct.startTime, forKeyPath: "startTime")
    }
}

extension TempUserId {
    func toTempIdStruct() -> TempIdStruct? {
        guard isValid else { return nil }
        return TempIdStruct(tempId: tempId!, startTime: startTime!, endTime: expiryTime!)
    }

    private var isValid: Bool {
        return tempId != nil
            && expiryTime != nil
            && startTime != nil
    }
}
