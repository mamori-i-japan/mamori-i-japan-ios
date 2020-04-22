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
    func showRetry(retry: @escaping () -> Void)
    func errorNavigation(error: Error?)
}

extension ProfileChangeable {
    func requestProfile(profile: Profile) {
        startAnimation()

        profileService.set(profile: profile) { [weak self] result in
            self?.stopAnimation()
            switch result {
            case .success:
                self?.endNavigation()
            case .failure(.network):
                // TODO: 再実行のみせかた
                self?.showRetry { [weak self] in
                    self?.requestProfile(profile: profile)
                }
            case .failure(.unknown(let error)):
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
        // TODO: 文言とか
        showAlert(message: "更新が完了しました", buttonTitle: "OK") { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
    }

    func showRetry(retry: @escaping () -> Void) {
        showAlertWithCancel(message: "TODO: 再読み込みしますか？", okButtonTitle: "再読み込み", okAction: { _ in retry() })
    }

    func errorNavigation(error: Error?) {
        // TODO: エラー表示
        showAlert(message: error.debugDescription)
    }
}
