//
//  HomeActionContentsView.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/23.
//

import UIKit

final class HomeActionContentsView: UIView, NibInstantiatable {
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
}
