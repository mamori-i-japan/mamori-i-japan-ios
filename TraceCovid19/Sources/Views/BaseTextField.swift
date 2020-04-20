//
//  BaseTextField.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/20.
//

import UIKit

@IBDesignable
class BaseTextField: UITextField, XIBLocalizable {
    @IBInspectable var textLocalizedKey: String = "" {
        didSet {
            updateText(textLocalizedKey)
        }
    }

    @IBInspectable var placeholderLocalizedKey: String = "" {
        didSet {
            updatePlaceholder(placeholderLocalizedKey)
        }
    }
}
