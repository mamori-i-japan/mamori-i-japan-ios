//
//  ISO8601DateFormatter.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/22.
//

import Foundation

extension String {
    static let iso8601DateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
}

extension DateFormatter {
    static let iso8601DateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = .iso8601DateFormat
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
