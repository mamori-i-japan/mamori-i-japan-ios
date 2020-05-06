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
    @IBOutlet weak var subMessageLabel: BaseLabel!
    @IBOutlet weak var detailButton: BaseButton!

    private var showDetailAction: (() -> Void)?

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

        detailButton.layer.cornerRadius = 8.0
        detailButton.clipsToBounds = true
        detailButton.setBackgroundImage(UIColor.primary3.toImage, for: .normal)
        detailButton.setBackgroundImage(UIColor.primary1.withAlphaComponent(0.2).toImage, for: .highlighted)
    }

    func set(contactCount: Int, showDetailAction: @escaping (() -> Void)) {
        timesCountLabel.text = contactCount.numberFormat

        // NOTE: 回数でUsualとSemiUsualを切り替える
        if contactCount >= UserStatus.usualUpperLimitCount {
            messageLabel.text = L10n.Home.Header.semiUsualMessage
            subMessageLabel.text = nil
            subMessageLabel.isHidden = true
        } else {
            messageLabel.text = L10n.Home.Header.usualMessage
            subMessageLabel.text = L10n.Home.Header.usualSubMessage
            subMessageLabel.isHidden = false
        }

        self.showDetailAction = showDetailAction
    }

    @IBAction func tappedShowDetailButton(_ sender: Any) {
        showDetailAction?()
    }
}

private extension Int {
    var numberFormat: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: self))
        // "0"の場合はハイフンに変更する
        return formatted == "0" ? "-" : formatted
    }
}
