//
//  UIViewController+Navigation.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/22.
//

import UIKit
import NVActivityIndicatorView

extension UIViewController {
    func backToSplash() {
        // NOTE: Routerを別で作るならそちらに移植する
        // スプラッシュに雑に戻す
        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true) {
            // TODO: 強制ログアウトする際に、中間の画面のviewWillAppearで非同期処理をしていると画面がブロックされて詰むので、ここで強制的に解除する
            if let activityIndicatorViewable = self as? (NVActivityIndicatorViewable & UIViewController) {
                activityIndicatorViewable.stopAnimating()
            }
            NotificationCenter.default.post(name: .splashStartNotirication, object: nil)
        }
    }
}
