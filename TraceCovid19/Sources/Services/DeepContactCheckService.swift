//
//  DeepContactCheckService.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/14.
//

import Foundation

final class DeepContactCheckService {
    private let coreData: CoreDataService

    private(set) var deepContactSequenceDuration: TimeInterval = 60 * 3 // 3分間以内=>連続データ
    private(set) var deepContactJudgedDuration: TimeInterval = 60 * 15 // 15分間継続=>濃厚接触

    private var isChecking: Bool = false

    init(coreData: CoreDataService) {
        self.coreData = coreData
    }

    func checkStart(completion: @escaping (Bool) -> Void) {
        guard isChecking == false else { return }
        print("[DeepContactCheckService] start at \(Date().toString(format: "yyyy/MM/dd HH:mm:ss.SSS"))")

        DispatchQueue.global(qos: .userInitiated).async {
            self.check()

            DispatchQueue.main.async {
                print("[DeepContactCheckService] finesed at \(Date().toString(format: "yyyy/MM/dd HH:mm:ss.SSS"))")
                completion(true)
            }
        }
    }

    func getDeepContactUsers() -> [DeepContactUser] {
        return coreData.getDeepContactUsers().compactMap { DeepContactUser(entity: $0) }
    }

    func getDeepContactUsersAtYesterday() -> [DeepContactUser] {
        let deepContactUsers = getDeepContactUsers()
        let yesterday = Date.yesterdayZeroOClock
        let today = Date.todatyZeroOClock
        return deepContactUsers.filter {
            yesterday <= $0.startTime && $0.startTime < today
        }
    }

    func getDeepContactUsersUniqCountAtYesterday() -> Int {
        let yesterdayDeepContactUsers = getDeepContactUsersAtYesterday()
        var tempIDs: [String] = []
        yesterdayDeepContactUsers.forEach {
            if tempIDs.contains($0.tempId) == false {
                tempIDs.append($0.tempId)
            }
        }
        return tempIDs.count
    }

    private func check() {
        isChecking = true

        tempTraceDataList.removeAll()
        let tempIDs = coreData.getAllTempIDsOfTraceData()
        tempIDs.forEach { tempID in
            let traceData = coreData.getTraceDataList(tempID: tempID)
            check(traceData: traceData)
        }

        // 作成したリストにより濃厚接触処理を行う
        moveTraceDataToDeepContactUser()
        isChecking = false
    }

    private func check(traceData: [TraceData]) {
        guard traceData.count >= 2 else { return }
        // NOTE: インデックスが0の方が新しい
        // 直近の閾値以内かどうか
        guard Date().timeIntervalSince1970 - traceData.first!.timestamp!.timeIntervalSince1970 > deepContactSequenceDuration else {
            // まだ動いているとみなす
            return
        }

        // リストを作成する
        tempRecord.removeAll()
        makeTemporaryTraceDataList(traceData: traceData)
    }

    private var tempTraceDataList: [String: [[TraceData]]] = [:]
    private var tempRecord: [TraceData] = []

    private func makeTemporaryTraceDataList(traceData: [TraceData], index: Int = 0) {
        let tempID = traceData[index].tempId!
        tempRecord.append(traceData[index])
        tempTraceDataList[tempID] = []

        (index..<traceData.count - 1).forEach { index in
            if traceData[index].timestamp!.timeIntervalSince1970 - traceData[index + 1].timestamp!.timeIntervalSince1970 > deepContactSequenceDuration {
                // 閾値外だったらそれまでの配列を退避させる
                tempTraceDataList[tempID]?.append(tempRecord)
                tempRecord.removeAll()
                tempRecord.append(traceData[index + 1])
                return
            }
            // 次のデータを格納して処理を継続
            tempRecord.append(traceData[index + 1])
        }
        // まだ残ってるやつがあったら退避させる
        if !tempRecord.isEmpty {
            tempTraceDataList[tempID]?.append(tempRecord)
        }
        tempRecord.removeAll()
    }

    private func moveTraceDataToDeepContactUser() {
        // 追跡データ保存テーブルから濃厚接触者管理テーブルへ移行
        tempTraceDataList.forEach { tempID, traceDataList in
            traceDataList.forEach { traceData in
                guard !traceData.isEmpty else { return }
                // 最新と最古の時間をチェック
                let startTime = traceData.last!.timestamp!
                let endTime = traceData.first!.timestamp!
                if endTime.timeIntervalSince1970 - startTime.timeIntervalSince1970 > deepContactJudgedDuration {
                    // 濃厚接触とみなす
                    coreData.saveAsDeepContactUser(tempId: tempID, traceData: traceData)
                    // 該当したデータはCoreDataから削除
                    coreData.deleteAllTraceData(tempId: tempID, startTime: startTime, endTime: endTime)
                }
            }
        }
    }
}

#if DEBUG
extension DeepContactCheckService {
    func setDeepContactSequenceDuration(_ duration: TimeInterval) {
        deepContactSequenceDuration = duration
    }

    func setDeepContactJudgedDuration(_ duration: TimeInterval) {
        deepContactJudgedDuration = duration
    }
}
#endif
