//
//  HomePositiveContentsView.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/24.
//

import UIKit

final class HomePositiveContentsView: UIView, NibInstantiatable {
    private var uploadButtonAction: (() -> Void)?

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

    func setUploadButtonAction(uploadButtonAction: @escaping () -> Void) {
        self.uploadButtonAction = uploadButtonAction
    }

    @IBAction func tappedUploadButton(_ sender: Any) {
        uploadButtonAction?()
    }
}
