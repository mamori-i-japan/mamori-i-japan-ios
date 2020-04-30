//
//  DeepContactUserEntity.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/30.
//

import Foundation
import CoreData

@objc(DeepContactUser)
final class DeepContactUserEntity: NSManagedObject, Encodable {
}

extension DeepContactUserEntity {
    @NSManaged var tempId: String!
    @NSManaged var startTime: Date!
    @NSManaged var endTime: Date!

    @discardableResult
    func set(tempId: String, traceData: [TraceDataRecord]) -> Bool {
        guard traceData.count >= 2 else { return false }
        self.tempId = tempId
        startTime = traceData.last!.timestamp
        endTime = traceData.first!.timestamp
        return true
    }

    func toDeepContactUser() -> DeepContactUser {
         return DeepContactUser(tempId: tempId, startTime: startTime, endTime: endTime)
     }
}
