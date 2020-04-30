//
//  BorederButton.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/23.
//

import UIKit

@IBDesignable
class BorederButton: BaseButton {
    private var observers = [NSKeyValueObservation]()

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

        isExclusiveTouch = true

        observers.append(
            observe(\.state, options: [.initial, .new]) { [weak self] _, change in
                guard let state = change.newValue ?? self?.state else { return }
                self?.layer.borderColor = self?.titleColor(for: state)?.cgColor
            }
        )
    }
}
