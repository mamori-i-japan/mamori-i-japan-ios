//
//  HomeActionContentsView.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/23.
//

import UIKit

final class HomeActionContentsView: UIView, NibInstantiatable {
    private var action1: (() -> Void)?
    private var action2: (() -> Void)?
    private var action3: (() -> Void)?
    private var action4: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    private func initialize() {
        guard let view = instantiate() else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(view)
    }

    func setup(action1: @escaping () -> Void, action2: @escaping () -> Void, action3: @escaping () -> Void, action4: @escaping () -> Void) {
        self.action1 = action1
        self.action2 = action2
        self.action3 = action3
        self.action4 = action4
    }

    @IBAction func tappedAction1Button(_ sender: Any) {
        action1?()
    }
    @IBAction func tappedAction2Button(_ sender: Any) {
        action2?()
    }
    @IBAction func tappedAction3Button(_ sender: Any) {
        action3?()
    }
    @IBAction func tappedAction4Button(_ sender: Any) {
        action4?()
    }
}
