//
//  NavigationProtocol+Home.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/28.
//

import UIKit

protocol HomeAccessable: PushNavigationProtocol, ModalNavigationProtocol {
    func modalToHome()
    func setViewControllersWithHome()
}

extension HomeAccessable {
    func modalToHome() {
        present(to: HomeViewController.instantiate())
    }

    func setViewControllersWithHome() {
        setViewControllers(to: [HomeViewController.instantiate()])
    }
}
