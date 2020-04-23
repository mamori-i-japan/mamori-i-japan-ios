//
//  BorederButton.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/23.
//

import UIKit

@IBDesignable
class BorederButton: BaseButton {
    override init(frame: CGRect) {
        super.init(frame: frame)

        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        initialize()
    }

    func initialize() {
        layer.cornerRadius = 8.0
        clipsToBounds = true

        layer.borderWidth = 2.0
        layer.borderColor = titleColor(for: state)?.cgColor

        isExclusiveTouch = true
    }
}
