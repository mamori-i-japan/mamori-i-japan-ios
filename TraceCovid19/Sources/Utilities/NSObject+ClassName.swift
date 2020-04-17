//
//  NSObject+ClassName.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/02.
//

import Foundation

extension NSObject {
    class var className: String {
        return String(describing: self)
    }

    var className: String {
        return type(of: self).className
    }
}
