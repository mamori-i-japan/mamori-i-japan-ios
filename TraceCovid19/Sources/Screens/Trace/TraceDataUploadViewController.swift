//
//  TraceDataUploadViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/09.
//

import UIKit
import NVActivityIndicatorView

final class TraceDataUploadViewController: UIViewController, NVActivityIndicatorViewable, NavigationBarHiddenApplicapable {
    var traceDataUpload: TraceDataUploadService!

    @IBAction func tappedUploadButton(sender: Any) {
        requestUpload()
    }

    func requestUpload() {
        startAnimating(type: .circleStrokeSpin)

        traceDataUpload.upload { [weak self] result in
            self?.stopAnimating()
            print(result)
        }
    }

    @IBAction func tappedCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
