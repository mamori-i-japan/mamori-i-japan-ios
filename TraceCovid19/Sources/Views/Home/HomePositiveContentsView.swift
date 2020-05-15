//
//  HomePositiveContentsView.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/24.
//

import UIKit

final class HomePositiveContentsView: UIView, NibInstantiatable {
    private var uploadButtonAction: (() -> Void)?
    @IBOutlet weak var dummyView1: UIView!
    @IBOutlet weak var dummyView2: UIView!
    @IBOutlet weak var dummyView3: UIView!

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

        dummyView1.layer.cornerRadius = dummyView1.bounds.height / 2.0
        dummyView2.layer.cornerRadius = dummyView2.bounds.height / 2.0
        dummyView3.layer.cornerRadius = dummyView3.bounds.height / 2.0
    }

    func setUploadButtonAction(uploadButtonAction: @escaping () -> Void) {
        self.uploadButtonAction = uploadButtonAction
    }

    @IBAction func tappedUploadButton(_ sender: Any) {
        uploadButtonAction?()
    }
}
