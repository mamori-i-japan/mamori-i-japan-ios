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
            (viewController as? NavigationBarHiddenApplicapable)?.setDesignedNavigationBar()
        } else {
            navigationBar.setBackgroundImage(nil, for: .default)
            navigationBar.shadowImage = nil
        }
    }
}

/// ナビゲーションバーを非表示(透明)に適応させるプロトコル
protocol NavigationBarHiddenApplicapable: UIViewController {
    func setDesignedNavigationBar()
    func undoDesignedNavigationBar()
    var navigationBackgroundImage: UIImage? { get }
    var navigationShadowImage: UIImage { get }
}

extension NavigationBarHiddenApplicapable {
    func setDesignedNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(navigationBackgroundImage, for: .default)
        navigationController?.navigationBar.shadowImage = navigationShadowImage
    }

    func undoDesignedNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
    }

    var navigationBackgroundImage: UIImage? {
        return UIImage()
    }

    var navigationShadowImage: UIImage {
        return UIImage()
    }
}
