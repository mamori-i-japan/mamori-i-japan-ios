//
//  HomeAttensionHeaderView.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/23.
//

import UIKit

final class HomeAttensionHeaderView: UIView, NibInstantiatable {
    @IBOutlet weak var messageLabel: BaseLabel!
    @IBOutlet weak var detailButton: BaseButton!

    private var showDetailAction: (() -> Void)?

    deinit {
        showDetailAction = nil
    }

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

    func set(positiveContactUser: DeepContactUser, showDetailAction: @escaping (() -> Void)) {
        let contactDateString = "１週間" // TODO: おおよその日数計算をする（正確な値は出さない）
        messageLabel.text = L10n.Home.Header.attensionMessage(contactDateString)
        self.showDetailAction = showDetailAction
    }

    @IBAction func tappedShowDetailButton(_ sender: Any) {
        showDetailAction?()
    }
}
