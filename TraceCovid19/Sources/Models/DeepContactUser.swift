//
//  DeepContactUser.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/15.
//

import Foundation
import CoreData

@objc(DeepContactUser)
final class DeepContactUser: NSManagedObject, Encodable {
}

extension DeepContactUser {
    @NSManaged var tempId: String?
    @NSManaged var startTime: Date?
    @NSManaged var endTime: Date?

    @discardableResult
    func set(tempId: String, traceData: [TraceData]) -> Bool {
        guard traceData.count >= 2 else { return false }
        self.tempId = tempId
        startTime = traceData.last!.timestamp
        endTime = traceData.first!.timestamp
        return true
    }
}
