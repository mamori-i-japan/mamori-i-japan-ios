//
//  Date+ToString.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/09.
//

import Foundation

extension Date {
    private static var defaultJSTFormatter = { () -> DateFormatter in
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "JST")
        return dateFormatter
    }()

    func toString(format: String) -> String {
        let dateFormatter = type(of: self).defaultJSTFormatter
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
