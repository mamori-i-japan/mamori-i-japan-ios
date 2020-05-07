//
//  TempIdService.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/16.
//

import Foundation

/// 持っておくべき有効なTempID数
private let shouldHasValidTempIdCount = 1

final class TempIdService {
    private let tempIdGenerator: TempIdGenerator
    private let coreData: CoreDataService

    init(tempIdGenerator: TempIdGenerator, coreData: CoreDataService) {
        self.tempIdGenerator = tempIdGenerator
        self.coreData = coreData
    }

    func getTempId() -> TempUserId {
        let tempIDs = self.tempIDs
        // 現在時間にマッチするIDの抽出
        if let currentId = filterCurrent(tempIDs: tempIDs) {
            return currentId
        }

        // マッチしない場合、有効なIDで近いIDを抽出
        if let validId = filterIsValid(tempIDs: tempIDs).last {
            return validId
        }

        // 有効なIDがない場合補充して返却
        return relaodTempIds().last!
    }

    var tempIDs: [TempUserId] {
        return coreData.getTempUserIDs()
    }

    var validTempIDs: [TempUserId] {
        return filterIsValid(tempIDs: tempIDs)
    }

    var hasTempIDs: Bool {
        return tempIDs.count != 0
    }

    @discardableResult
    func relaodTempIdsIfNeeded() -> [TempUserId] {
        let validTempIDs = self.validTempIDs
        guard validTempIDs.count < shouldHasValidTempIdCount else {
            return validTempIDs
        }
        // 一定数より有効なTempIDがなければ補充する
        return relaodTempIds()
    }

    func relaodTempIds() -> [TempUserId] {
        let tempIds = tempIdGenerator.createTempUserIds()
        save(tempIds: tempIds)
        return tempIds
    }

    func getTempIdsForTwoWeeks() -> [TempUserId] {
        // TODO: 14日間分（0:00スタート）にする
        return tempIDs
    }

    private func save(tempIds: [TempUserId]) {
        // 重複排除してから保存する
        let localTempIDs = tempIDs.compactMap { $0.tempId }
        let newTempIDs = tempIds.filter { !localTempIDs.contains($0.tempId) }
        newTempIDs.forEach { [weak self] in
            self?.coreData.save(tempUserId: $0)
        }
    }

    private func filterCurrent(tempIDs: [TempUserId]) -> TempUserId? {
        let now = Date()
        return tempIDs.first { tempId -> Bool in
            tempId.startTime <= now && now < tempId.endTime
        }
    }

    private func filterIsValid(tempIDs: [TempUserId]) -> [TempUserId] {
        let now = Date()
        return tempIDs.filter { tempId -> Bool in
            now < tempId.endTime
        }
    }
}

#if DEBUG
extension TempIdService {
    func deleteAll() {
        coreData.deleteAllTempUserIDs()
    }
}
#endif
