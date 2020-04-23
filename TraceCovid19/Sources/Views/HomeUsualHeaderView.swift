//
//  HomeUsualHeaderView.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/15.
//

import UIKit

final class HomeUsualHeaderView: UIView, NibInstantiatable {
    @IBOutlet weak var timesCountLabel: BaseLabel!
    @IBOutlet weak var messageLabel: BaseLabel!

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

    func set(contactCount: Int) {
        timesCountLabel.text = contactCount.numberFormat

        // NOTE: 回数でUsualとSemiUsualを切り替える
        if contactCount >= UserStatus.usualUpperLimitCount {
            messageLabel.text = L10n.Home.Header.semiUsualMessage
        } else {
            messageLabel.text = L10n.Home.Header.usualMessage
        }
    }
}

private extension Date {
    // TODO: あとで切り出すか消す
    static var todatyZeroOClock: Date {
        // 雑にフォーマット変換で時と分と秒を落とす
        return Date().toString(format: "yyyy/MM/dd").toDate(format: "yyyy/MM/dd")!
    }
}

private extension Int {
    var numberFormat: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self))
    }
}
