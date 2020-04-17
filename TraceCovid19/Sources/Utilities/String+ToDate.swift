//
//  String+ToDate.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/16.
//

import Foundation

extension String {
    private static var defaultJSTFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "JST") // TODO: タイムゾーン検討
        return dateFormatter
    }

    func toDate(format: String) -> Date? {
        let dateFormatter = type(of: self).defaultJSTFormatter
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
}
