//
//  ProfileChangeable.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/19.
//

import UIKit
import NVActivityIndicatorView

/// プロフィール変更を共通化したプロトコル
protocol ProfileChangeable: class {
    var profileService: ProfileService! { get }
    var loginService: LoginService! { get }
    func startAnimation()
    func stopAnimation()
    func requestProfile(profile: Profile)
    func endNavigation()
    func errorNavigation(error: ProfileService.ProfileUpdateError?)
    func forceLogout()
    func showNetworkError()
    func showUnknownError()
}

extension ProfileChangeable {
    func requestProfile(profile: Profile) {
        startAnimation()

        profileService.update(profile: profile, organization: nil) { [weak self] result in
            self?.stopAnimation()
            switch result {
            case .success:
                self?.endNavigation()
            case .failure(let error):
                self?.errorNavigation(error: error)
            }
        }
    }
}

extension ProfileChangeable where Self: NVActivityIndicatorViewable & UIViewController {
    func startAnimation() {
        // キーボードを閉じる
        view.endEditing(true)
        startAnimating(type: .circleStrokeSpin)
    }

    func stopAnimation() {
        stopAnimating()
    }
}

extension ProfileChangeable where Self: UIViewController {
    func endNavigation() {
        // デフォルトでは1つ戻る
        navigationController?.popViewController(animated: true)
    }

    func errorNavigation(error: ProfileService.ProfileUpdateError?) {
        switch error {
        case .some(.auth):
            forceLogout()
        case .some(.network):
            showNetworkError()
        case .some(.unknown), .none:
            showUnknownError()
        case .some(.notMatchCode):
            // 組織コードのアップデートはここでは見ない
            break
        }
    }

    func showNetworkError() {
        showAlert(title: L10n.Error.Network.title)
    }

    func showUnknownError() {
        showAlert(title: L10n.Error.Unknown.title)
    }

    func forceLogout() {
        // ダイアログを表示して強制ログアウト
        showAlert(title: L10n.Error.Authentication.title, message: L10n.Error.Authentication.message, buttonTitle: L10n.logout) { [weak self] _ in
            self?.loginService.logout()
            self?.backToSplash()
        }
    }
}
