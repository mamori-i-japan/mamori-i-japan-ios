//
//  NoPerformActionTextField.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/11.
//

import UIKit

class NoPerformActionTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}
