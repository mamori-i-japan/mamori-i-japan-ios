//
//  DeepContactUser.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/15.
//

import Foundation

struct DeepContactUser {
    var tempId: String
    var startTime: Date
    var endTime: Date
}

extension DeepContactUser {
    init(entity: DeepContactUserEntity) {
        self.tempId = entity.tempId
        self.startTime = entity.startTime
        self.endTime = entity.endTime
    }
}
