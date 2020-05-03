//
//  Agreement1ViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/11.
//

import UIKit
import NVActivityIndicatorView

final class Agreement1ViewController: UIViewController, NavigationBarHiddenApplicapable, NVActivityIndicatorViewable, PermissionSettingAccessable {
    var loginService: LoginService!

    var profile: Profile!

    @IBAction func tappedNextButton(_ sender: Any) {
        login()
    }
}

extension Agreement1ViewController {
    private func login() {
        startAnimating(type: .circleStrokeSpin)
        loginService.signInAnonymously(profile: profile) { [weak self] result in
            self?.stopAnimating()

            switch result {
            case .success:
                self?.pushToPermissionSetting()
            case .failure(let error):
                // TODO: エラーのUX
                self?.showError(error: error)
            }
        }
    }

    private func showError(error: LoginService.SignInError) {
        switch error {
        case .notMatch:
            break
        case .expired:
            break
        case .networkError:
            showAlert(message: "TODO: 通信に失敗しました")
        case .unknown(let error):
            showAlert(message: error.localizedDescription)
        }
    }
}
