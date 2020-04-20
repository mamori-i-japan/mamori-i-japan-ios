//
//  HomeBaseView.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/15.
//

import UIKit
import SnapKit

final class HomeBaseView: UIView, NibInstantiatable {
    @IBOutlet weak var statusImageBaseView: UIView!
    @IBOutlet weak var statusDescriptionBaseView: UIView!
    @IBOutlet weak var statusLevelLabel: UILabel!
    @IBOutlet weak var statusDescriptionLabel: UILabel!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var actionGuideLabel: UILabel!

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

    func setStatus(_ status: HomeViewController.Status) {
        statusImageBaseView.subviews.forEach { $0.removeFromSuperview() }
        switch status {
        case .normal:
            let normalView = NormalImageStatusView(frame: statusImageBaseView.bounds)
            statusImageBaseView.addSubview(normalView)
            normalView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            statusLevelLabel.text = L10n.Home.Level.low
            statusDescriptionLabel.text = L10n.Home.StatusDescription.low
            actionGuideLabel.text = L10n.Home.ActionGuide.low
            statusDescriptionBaseView.backgroundColor = .init(hex: 0x2F80ED, alpha: 0.2)
            expandButton.isHidden = true
        case .contactedPositive(let latest):
            let contactedPositiveView = ContactedPositiveImageStatusView(frame: statusImageBaseView.bounds)
            statusImageBaseView.addSubview(contactedPositiveView)
            contactedPositiveView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            statusLevelLabel.text = L10n.Home.Level.middle
            // TODO: 差分日数計算
            if let contactDate = latest.startTime {
                let beforeCalcuratedDay = max(Date.todatyZeroOClock.timeIntervalSince1970 - contactDate.timeIntervalSince1970, 0) / (60 * 60 * 24)
                statusDescriptionLabel.text = L10n.Home.StatusDescription.middle("\(Int(beforeCalcuratedDay))")
            } else {
                statusDescriptionLabel.text = L10n.Home.StatusDescription.middle("X")
            }
            actionGuideLabel.text = L10n.Home.ActionGuide.middle
            statusDescriptionBaseView.backgroundColor = .init(hex: 0xFFE0B0)
            expandButton.isHidden = false
        case .isPositiveOwn:
            let positiveOwnView = PositiveOwnStatusView(frame: statusImageBaseView.bounds)
            statusImageBaseView.addSubview(positiveOwnView)
            positiveOwnView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            statusLevelLabel.text = L10n.Home.Level.high
            statusDescriptionLabel.text = L10n.Home.StatusDescription.high
            actionGuideLabel.text = L10n.Home.ActionGuide.high
            statusDescriptionBaseView.backgroundColor = .init(hex: 0xFFB0B0)
            expandButton.isHidden = true
        }
    }
}

private extension Date {
    static var todatyZeroOClock: Date {
        // 雑にフォーマット変換で時と分と秒を落とす
        return Date().toString(format: "yyyy/MM/dd").toDate(format: "yyyy/MM/dd")!
    }
}
