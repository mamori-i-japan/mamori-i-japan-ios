//
//  HomeInformationView.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/05/07.
//

import UIKit

final class HomeInformationView: UIView, NibInstantiatable {
    @IBOutlet weak var dateLabel: BaseLabel!

    private var information: Information?
    private var informationButtonAction: ((Information) -> Void)?

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

    func set(information: Information, informationButtonAction: @escaping ((Information) -> Void)) {
        self.information = information
        self.informationButtonAction = informationButtonAction

        if let date = information.updateAt {
            // TODO: オプショナルじゃなくなる予定
            dateLabel.text = date.toString(format: "yyyy/MM/dd")
        }
    }

    @IBAction func tappedInformationButton(sendar: Any) {
        guard let information = information else { return }
        informationButtonAction?(information)
    }
}
