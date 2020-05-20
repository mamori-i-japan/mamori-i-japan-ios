//
//  TempUserIdEntity.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/30.
//

import Foundation
import CoreData

@objc(TempUserId)
final class TempUserIdEntity: NSManagedObject, Encodable {
}

extension TempUserIdEntity {
    @NSManaged var tempId: String!
    @NSManaged var expiryTime: Date!
    @NSManaged var startTime: Date!

    func set(tempUserId: TempUserId) {
        setValue(tempUserId.tempId, forKeyPath: "tempId")
        setValue(tempUserId.endTime, forKey: "expiryTime")
        setValue(tempUserId.startTime, forKeyPath: "startTime")
    }

    func toTempUserId() -> TempUserId {
        TempUserId(tempId: tempId, startTime: startTime, endTime: expiryTime)
    }
}
