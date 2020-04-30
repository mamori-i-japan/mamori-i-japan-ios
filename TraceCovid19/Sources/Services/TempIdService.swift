//
//  TempIdService.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/16.
//

import Foundation

/// 持っておくべき有効なTempID数
private let shouldHasValidTempIdCount = 3

final class TempIdService {
    private let tempIdAPI: TempIdAPI
    private let coreData: CoreDataService

    init(tempIdAPI: TempIdAPI, coreData: CoreDataService) {
        self.tempIdAPI = tempIdAPI
        self.coreData = coreData
    }

    var currentTempId: TempUserId? {
        let tempIDs = self.tempIDs
        if filterIsValid(tempIDs: tempIDs).count < shouldHasValidTempIdCount {
            // 一定数より有効なTempIDがなければ取得しておく(結果は見ない)
            fetchTempIDs(completion: { _ in })
        }
        return filterCurrent(tempIDs: tempIDs)
    }

    var latestTempId: TempUserId? {
        return tempIDs.first
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

    enum FetchTempIDsError: Error {
        case unauthorized
        case unknown(Error?)
    }

    func fetchTempIDs(completion: @escaping (Result<[TempUserId], FetchTempIDsError>) -> Void) {
        tempIdAPI.getTempIDs { [weak self] result in
            switch result {
            case .success(let response):
                let tempIds = response.compactMap { TempUserId(response: $0) }
                self?.save(tempIds: tempIds)
                completion(.success(tempIds))
            case .failure(.error(let error)),
                 .failure(.statusCodeError(_, _, let error)):
                completion(.failure(.unknown(error)))
            case .failure(.authzError):
                completion(.failure(.unauthorized))
            }
        }
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
