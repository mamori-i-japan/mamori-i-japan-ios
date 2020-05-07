//
//  TraceDataUploadViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/09.
//

import UIKit
import NVActivityIndicatorView

final class TraceDataUploadViewController: UIViewController, NVActivityIndicatorViewable, NavigationBarHiddenApplicapable, TraceDataUploadCompleteAccessable {
    var traceDataUpload: TraceDataUploadService!
    var loginService: LoginService!

    @IBAction func tappedUploadButton(sender: Any) {
        requestUpload()
    }

    func requestUpload() {
        startAnimating(type: .circleStrokeSpin)

        traceDataUpload.upload { [weak self] result in
            self?.stopAnimating()

            switch result {
            case .success:
                self?.pushToTraceDataUploadComplete()
            case .failure(.auth):
                self?.showAlert(title: L10n.Error.Authentication.title, message: L10n.Error.Authentication.message, buttonTitle: L10n.logout) { [weak self] _ in
                    self?.loginService.logout()
                    self?.backToSplash()
                }
            case .failure(.network):
                self?.showAlert(title: L10n.Error.FailedUploading.title, message: L10n.Error.FailedUploading.message)
            case .failure(.unknown(let error)):
                print("[InputOrganization] error: \(error?.localizedDescription ?? "nil")")
                self?.showAlert(title: L10n.Error.Unknown.title)
            }
        }
    }
}
