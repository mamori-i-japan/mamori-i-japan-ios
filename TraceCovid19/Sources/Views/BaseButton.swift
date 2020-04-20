//
//  BaseButton.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/20.
//

import UIKit

@IBDesignable
class BaseButton: UIButton, XIBLocalizable {
    @IBInspectable var titleLocalizedKey: String = "" {
        didSet {
            updateTitle(titleLocalizedKey, for: state)
        }
    }
}
