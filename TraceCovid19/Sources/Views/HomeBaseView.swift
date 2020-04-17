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

            statusLevelLabel.text = "低い"
            statusDescriptionLabel.text = "ここ14日間で感染者との接触は認められません。"
            actionGuideLabel.text = "引き続きソーシャルディスタンスを保って行動してください。"
            statusDescriptionBaseView.backgroundColor = .init(hex: 0x2F80ED, alpha: 0.2)
            expandButton.isHidden = true
        case .contactedPositive:
            let contactedPositiveView = ContactedPositiveImageStatusView(frame: statusImageBaseView.bounds)
            statusImageBaseView.addSubview(contactedPositiveView)
            contactedPositiveView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            statusLevelLabel.text = "中"
            statusDescriptionLabel.text = "X日前に感染者との接触の可能性があります。"
            actionGuideLabel.text = "ご自宅で安静にしてください。"
            statusDescriptionBaseView.backgroundColor = .init(hex: 0xFFE0B0)
            expandButton.isHidden = false
        }
    }
}
