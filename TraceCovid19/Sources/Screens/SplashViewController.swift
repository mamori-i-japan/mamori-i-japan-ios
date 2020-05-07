//
//  SplashViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/02.
//

import UIKit
import NVActivityIndicatorView

extension NSNotification.Name {
    static let splashStartNotirication = NSNotification.Name("splashStartNotirication")
}

final class SplashViewController: UIViewController, NVActivityIndicatorViewable, Tutorial1Accessable, HomeAccessable {
    var loginService: LoginService!
    var bootService: BootService!

    override func viewDidLoad() {
        super.viewDidLoad()
        firstLaunch()

        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForegound), name: UIApplication.willEnterForegroundNotification, object: nil)
        // ログアウトなどによりスプラッシュに戻ってきた場合に再開するための通知受け取り
        NotificationCenter.default.addObserver(self, selector: #selector(handleNavigation), name: .splashStartNotirication, object: nil)
    }

    private func firstLaunch() {
        startAnimating(type: .circleStrokeSpin)

        bootService.execLaunch { [weak self] result in
            self?.stopAnimating()

            switch result {
            case .success:
                self?.handleNavigation()
            case .isMaintenance:
                self?.showMaintenanceAlert()
            case .isNeedUpdate(let storeURL):
                self?.showUpdateAlert(storeURL: storeURL)
            case .failed:
                print("RemoteConfig Error.")
                // NOTE: 初回表示でも、ひとまず止めずにエラー抑制して次へ流す
                self?.handleNavigation()
            }
        }
    }

    @objc
    func willEnterForegound() {
        bootService.execEnterForeground { [weak self] result in
            switch result {
            case .success:
                break
            case .isMaintenance:
                self?.showMaintenanceAlert()
            case .isNeedUpdate(let storeURL):
                self?.showUpdateAlert(storeURL: storeURL)
            case .failed:
                // Foregroundでの失敗の場合は明示的な処理はしない
                print("RemoteConfig Error.")
            }
        }
    }

    private func showMaintenanceAlert() {
        showAlert(message: "TODO: メンテナンス中です", buttonTitle: "再読み込み") { [weak self] _ in
            self?.firstLaunch()
        }
    }

    private func showUpdateAlert(storeURL: URL) {
        showAlert(message: "TODO: アプリをアップデートしてください", buttonTitle: "AppStoreへ遷移") { _ in
            UIApplication.shared.open(storeURL, options: [:], completionHandler: nil)
        }
    }

    @objc
    func handleNavigation() {
        if loginService.isLogin {
            DispatchQueue.main.async { [weak self] in
                self?.modalToHome()
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.modalToTutorial1()
            }
        }
    }
}
