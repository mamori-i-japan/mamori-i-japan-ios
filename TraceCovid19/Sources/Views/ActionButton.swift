//
//  ActionButton.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/11.
//

import UIKit

@IBDesignable
class ActionButton: UIButton {
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

        setBackgroundImage(UIColor(hex: 0x003E9B).toImage, for: .normal)
        setBackgroundImage(UIColor(hex: 0x0071FF, alpha: 0.25).toImage, for: .disabled)

        setTitleColor(UIColor(hex: 0xFFFFFF), for: .normal)
        setTitleColor(UIColor(hex: 0xFFFFFF, alpha: 0.25), for: .disabled)

        isExclusiveTouch = true
    }
}
