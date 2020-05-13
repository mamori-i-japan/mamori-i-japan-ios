//
//  TraceHistorySectionHeaderView.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/05/13.
//

import UIKit

final class TraceHistorySectionHeaderView: UIView, NibInstantiatable {
    @IBOutlet weak var dateLabel: UILabel!
    static var hight: CGFloat = 40.0

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

    func update(dateString: String) {
        dateLabel.text = dateString
    }
}
