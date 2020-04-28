//
//  Agreement2ViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/11.
//

import UIKit
import NVActivityIndicatorView

final class Agreement2ViewController: UIViewController, NavigationBarHiddenApplicapable, NVActivityIndicatorViewable, PermissionSettingAccessable {
    var profile: Profile!
    var loginService: LoginService!

    @IBAction func tappedNextButton(_ sender: Any) {
        login()
    }

    func login() {
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
