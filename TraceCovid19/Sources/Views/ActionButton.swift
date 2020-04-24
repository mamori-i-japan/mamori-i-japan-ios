//
//  ActionButton.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/11.
//

import UIKit

@IBDesignable
class ActionButton: BaseButton {
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

        setBackgroundImage(UIColor.primary1.toImage, for: .normal)
        setBackgroundImage(UIColor.primary1.withAlphaComponent(0.3).toImage, for: .disabled)

        setTitleColor(UIColor.systemWhite, for: .normal)
        setTitleColor(UIColor.systemWhite.withAlphaComponent(0.3), for: .disabled)

        isExclusiveTouch = true
    }
}
