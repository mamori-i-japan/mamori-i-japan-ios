//
//  PositiveContactService.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/15.
//

import Foundation
import FirebaseStorage
import Swinject
import Gzip
import Reachability

final class PositiveContactService {
    private let storage: Lazy<Storage>
    private let jsonDecoder: JSONDecoder
    private let tempIdService: TempIdService
    private let deepContactCheck: DeepContactCheckService

    private var lastGeneration: Int64?
    private(set) var positiveContacts: [String] = []

    private var fileName: String {
        return "positives.json.gz"
    }

    init(
        storage: Lazy<Storage>,
        jsonDecoder: JSONDecoder,
        tempIdService: TempIdService,
        deepContactCheck: DeepContactCheckService
    ) {
        self.storage = storage
        self.jsonDecoder = jsonDecoder
        self.tempIdService = tempIdService
        self.deepContactCheck = deepContactCheck
    }

    enum PositiveContactStatus: Error {
        case noNeedToLoad
        case network
        case parse
        case unknown(Error?)
    }

    /// 自身の陽性判定
    func isPositiveMyself() -> Bool {
        let myTempIDs = tempIdService.tempIDs.compactMap { $0.tempId }
        for tempID in myTempIDs {
            if positiveContacts.contains(tempID) {
                return true
            }
        }
        return false
    }

    /// 接触した陽性者の最新を取得
    func getLatestContactedPositivePeople() -> DeepContactUser? {
        let deepContactTempIds = deepContactCheck.getDeepContactUsers().compactMap { $0.tempId }
        for tempId in deepContactTempIds where positiveContacts.contains(tempId) {
            return deepContactCheck.getDeepContactUsers().first(where: { $0.tempId == tempId })
        }
        return nil
    }

    func load(completion: @escaping (Result<[String], PositiveContactStatus>) -> Void) {
        // NOTE: FirebaseStorageもオフラインではコールバックが呼ばれないため事前にチェックする
        guard let rechability = try? Reachability(), rechability.connection != .unavailable else {
            print("[PositiveContactService] network error")
            completion(.failure(.network))
            return
        }

        let reference = storage.instance.reference().child(fileName)

        reference.getMetadata { [weak self] metaData, error in
            guard let metaData = metaData, error == nil else {
                print("[PositiveContactService] error occurred: \(String(describing: error))")
                completion(.failure(.unknown(error)))
                return
            }

            print("[PositiveContactService] new generation: \(String(describing: metaData.generation)), last generation: \(String(describing: self?.lastGeneration))")
            if let lastGeneration = self?.lastGeneration,
                lastGeneration == metaData.generation {
                // 取得不要
                completion(.failure(.noNeedToLoad))
                return
            }

            // メモリ指定（最大1MB）
            reference.getData(maxSize: 1 * 1024 * 1024) { [weak self] data, error in
                guard let sSelf = self else { return }
                guard let data = data, error == nil else {
                    print("[PositiveContactService] error occurred: \(String(describing: error))")
                    completion(.failure(.unknown(error)))
                    return
                }

                // gunzip
                let rawData: Data
                if data.isGzipped {
                    guard let gunzippedData = try? data.gunzipped() else {
                        print("[PositiveContactService] gunzip failed: \(String(describing: String(data: data, encoding: .utf8)))")
                        completion(.failure(.parse))
                        return
                    }
                    rawData = gunzippedData
                } else {
                    rawData = data
                }

                do {
                    let list = try sSelf.jsonDecoder.decode(PositiveContactList.self, from: rawData)
                    self?.lastGeneration = metaData.generation
                    self?.positiveContacts = list.data
                    completion(.success(list.data))
                } catch {
                    print("[PositiveContactService] parse error: \(error)")
                    completion(.failure(.unknown(error)))
                }
            }
        }
    }
}

#if DEBUG
extension PositiveContactService {
    /// (デバッグ用) TempIdを陽性者リストに追加する
    func appendPositiveContact(tempId: String) {
        if !positiveContacts.contains(tempId) {
            positiveContacts.append(tempId)
        }
    }

    /// (デバッグ用) UUIDを陽性者リストから削除する
    func removePositiveContact(tempId: String) {
        positiveContacts.removeAll(where: { $0 == tempId })
    }

    func resetGeneration() {
        lastGeneration = nil
    }
}
#endif
