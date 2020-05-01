//
//  TempIdGenerator.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/05/01.
//

import Foundation

final class TempIdGenerator {
    /// 区切りの時間
    private let breakClock = "T04:00:00"
    /// 一度に生成する数
    private static let defaultGenerateCount = 3

    func createTempUserIds(startDate: Date = Date(), count: Int = defaultGenerateCount) -> [TempUserId] {
        var date = createDate(date: startDate)
        if Date() < date {
            // 開始日時が、区切り時間の関係上まだ始まっていないなら、さらにその前日を開始時間とする
            date = date.previousDate()
        }
        var result: [TempUserId] = []
        for _ in 0..<count {
            /// 先頭の方により未来のものを追加していく
            result.insert(create(startDate: date), at: 0)
            date = date.nextDate()
        }
        return result
    }

    private func create(startDate: Date) -> TempUserId {
        let endDate = startDate.nextDate()
        return TempUserId(tempId: createId(), startTime: createDate(date: startDate), endTime: createDate(date: endDate))
    }

    private func createId() -> String {
        // NOTE: ID体系はUUIDv4とする
        return UUID().uuidString
    }

    private func createDate(date: Date) -> Date {
        let dateString = date.toString(format: "yyyy/MM/dd")
        return (dateString + breakClock).toDate(format: "yyyy/MM/dd'T'HH:mm:ss")!
    }
}

private extension Date {
    func nextDate() -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: self))! // 翌日
    }

    func previousDate() -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: self))! // 前日
    }
}
