//
//  TempUserId.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/17.
//

import Foundation
import CoreData

struct TempUserId {
    let tempId: String
    let startTime: Date
    let endTime: Date
}

extension TempUserId {
    var id: String {
        return "\(tempId)\(Int(startTime.timeIntervalSince1970))\(Int(endTime.timeIntervalSince1970)))".sha256!
    }
}
