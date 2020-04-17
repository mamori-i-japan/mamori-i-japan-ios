//
//  TraceDataUploadViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/09.
//

import UIKit
import NVActivityIndicatorView

final class TraceDataUploadViewController: UIViewController, NVActivityIndicatorViewable {
    @IBAction func tappedInquireButton(sender: Any) {
        requestInquire()
    }

    func requestInquire() {
        startAnimating(type: .circleStrokeSpin)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.stopAnimating()
        }
    }
}
