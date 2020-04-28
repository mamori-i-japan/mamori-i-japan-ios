//
//  NavigationProtocol+Home.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/28.
//

import UIKit

protocol HomeAccessable: NavigationProtocol {
    var homePresenter: UIViewController { get }
    func modalToHome()
    func setViewControllersWithHome()
}

extension HomeAccessable where Self: UIViewController {
    var homePresenter: UIViewController {
        return self
    }
}

extension HomeAccessable {
    func modalToHome() {
        let navigationController = CustomNavigationController(rootViewController: Tutorial1ViewController.instantiate())
        navigationController.modalPresentationStyle = .fullScreen
        homePresenter.present(navigationController, animated: false, completion: nil)
    }

    func setViewControllersWithHome() {
        navigationController?.setViewControllers([HomeViewController.instantiate()], animated: true)
    }
}
