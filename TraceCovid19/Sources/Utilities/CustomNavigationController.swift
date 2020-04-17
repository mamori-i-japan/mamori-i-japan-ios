//
//  CustomNavigationController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/11.
//

import UIKit

final class CustomNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
}

extension CustomNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is NavigationBarHiddenApplicapable {
            // NavigationBar透明化
            (viewController as? NavigationBarHiddenApplicapable)?.clearNavigationBar()
        } else {
            navigationBar.setBackgroundImage(nil, for: .default)
            navigationBar.shadowImage = nil
        }
    }
}

/// ナビゲーションバーを非表示(透明)に適応させるプロトコル
protocol NavigationBarHiddenApplicapable: UIViewController {
    func clearNavigationBar()
    func undoClearNavigationBar()
}

extension NavigationBarHiddenApplicapable {
    func clearNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }

    func undoClearNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
    }
}
