//
//  UIColor+Hex.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/11.
//

import UIKit

extension UIColor {
    /// HEXで色定義
    ///
    /// - Parameters:
    ///   - hex: 0x000000 ~ 0xFFFFFF
    ///   - alpha: 0.0 ~ 1.0 省略時は1.0
    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((hex & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(hex & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: min(max(alpha, 0), 1))
    }
}
