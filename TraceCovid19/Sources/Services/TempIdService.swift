//
//  TempIdService.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/16.
//

import Foundation

final class TempIdService {
    private let tempIdAPI: TempIdAPI
    private let coreData: CoreDataService

    init(tempIdAPI: TempIdAPI, coreData: CoreDataService) {
        self.tempIdAPI = tempIdAPI
        self.coreData = coreData
    }

    var currentTempId: TempIdStruct? {
        return filterCurrent(tempIdDs: tempIDs)
    }

    var latestTempId: TempIdStruct? {
        return tempIDs.first
    }

    var tempIDs: [TempIdStruct] {
        return coreData.getTempUserIDs()
    }

    var hasTempIDs: Bool {
        return tempIDs.count != 0
    }

    func fetchTempIDs(completion: @escaping (Result<[TempIdStruct], Error>) -> Void) {
        tempIdAPI.getTempIDs { [weak self] result in
            switch result {
            case .success(let response):
                let tempIds = response.compactMap { TempIdStruct(response: $0) }
                self?.save(tempIds: tempIds)
                completion(.success(tempIds))
            case .failure(.error(let error)),
                 .failure(.statusCodeError(_, _, let error)):
                completion(.failure(error ?? NSError(domain: "unknown error", code: 0, userInfo: nil)))
            }
        }
    }

    private func save(tempIds: [TempIdStruct]) {
        // 重複排除してから保存する
        let localTempIDs = tempIDs.compactMap { $0.tempId }
        let newTempIDs = tempIds.filter { !localTempIDs.contains($0.tempId) }
        newTempIDs.forEach { [weak self] in
            self?.coreData.save(tempID: $0)
        }
    }

    private func filterCurrent(tempIdDs: [TempIdStruct]) -> TempIdStruct? {
        let now = Date()
        return tempIdDs.first { tempId -> Bool in
            tempId.startTime <= now && now < tempId.endTime
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

struct TempIdStruct {
    let tempId: String
    let startTime: Date
    let endTime: Date
}

extension TempIdStruct {
    init(response: TempIdAPIResponse) {
        tempId = response.tempID
        startTime = Date(timeIntervalSince1970: response.validFrom)
        endTime = Date(timeIntervalSince1970: response.validTo)
    }
}
