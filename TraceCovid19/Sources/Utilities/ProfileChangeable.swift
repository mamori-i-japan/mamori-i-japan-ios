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
    func startAnimation()
    func stopAnimation()
    func requestProfile(profile: Profile)
    func endNavigation()
    func errorNavigation(error: Error?)
}

extension ProfileChangeable {
    func requestProfile(profile: Profile) {
        startAnimation()

        profileService.set(profile: profile) { [weak self] result in
            self?.stopAnimation()
            switch result {
            case true:
                self?.endNavigation()
            case false:
                self?.errorNavigation(error: nil)
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

    func errorNavigation(error: Error?) {
        // TODO: エラー表示
        showAlert(message: error.debugDescription)
    }
}
