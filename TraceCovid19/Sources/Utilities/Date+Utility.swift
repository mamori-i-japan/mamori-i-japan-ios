//
//  Date+Utility.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/05/04.
//

import Foundation

extension Date {
    static var todatyZeroOClock: Date {
        // 雑にフォーマット変換で時と分と秒を落とす
        return Date().toString(format: "yyyy/MM/dd").toDate(format: "yyyy/MM/dd")!
    }

    static var yesterdayZeroOClock: Date {
        // 雑にフォーマット変換で時と分と秒を落とす
        let yesterday = Date(timeIntervalSinceNow: -24 * 60 * 60)
        return yesterday.toString(format: "yyyy/MM/dd").toDate(format: "yyyy/MM/dd")!
    }
}
