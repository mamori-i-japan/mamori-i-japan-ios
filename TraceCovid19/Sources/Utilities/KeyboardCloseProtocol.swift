//
//  KeyboardCloseProtocol.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/09.
//

import UIKit

protocol KeyboardCloseProtocol: class {
    var target: UIView { get }
    /// ViewDidLoadなどで呼ぶこと
    func setupKeyboardClose()
}

extension KeyboardCloseProtocol {
    func setupKeyboardClose() {
        let gesture = UITapGestureRecognizer(
            closureWrapper: .init { [weak self] _ in
                self?.closeKeyboard()
            }
        )
        target.addGestureRecognizer(gesture)
    }

    func closeKeyboard() {
        target.endEditing(true)
    }
}

extension KeyboardCloseProtocol where Self: UIViewController {
    var target: UIView {
        return view
    }
}
