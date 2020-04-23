//
//  HomeAttensionHeaderView.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/23.
//

import UIKit

final class HomeAttensionHeaderView: UIView, NibInstantiatable {
    @IBOutlet weak var messageLabel: BaseLabel!//

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
    }

    func set(positiveContactUser: DeepContactUser, showDetailAction: @escaping (() -> Void)) {
        let ampm = positiveContactUser.startTime!.toStringWithAMPMInJapanese(format: "h") // 例: 午前1
        let contactDateString = positiveContactUser.startTime!.toString(format: "yyyy年M月d日") + ampm + "頃"
        messageLabel.text = L10n.Home.Header.attensionMessage(contactDateString)
        self.showDetailAction = showDetailAction
    }

    @IBAction func tappedShowDetailButton(_ sender: Any) {
        showDetailAction?()
    }
}
