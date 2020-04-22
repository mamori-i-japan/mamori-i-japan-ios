//
//  UIViewController+Navigation.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/22.
//

import UIKit

extension UIViewController {
    func backToSplash() {
        // NOTE: Routerを別で作るならそちらに移植する
        // スプラッシュに雑に戻す
        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true) {
            NotificationCenter.default.post(name: .splashStartNotirication, object: nil)
        }
    }
}
