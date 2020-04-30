//
//  NavigationProtocol+Menu.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/30.
//

import Foundation

protocol MenuAccessable: NavigationProtocol {
    func pushToMenu()
}

extension MenuAccessable {
    func pushToMenu() {
        navigationController?.pushViewController(MenuViewController.instantiate(), animated: true)
    }
}

protocol AboutAccessable: NavigationProtocol {
    func pushToAbout()
}

extension AboutAccessable {
    func pushToAbout() {
        navigationController?.pushViewController(AboutViewController.instantiate(), animated: true)
    }
}

protocol SettingAccessable: NavigationProtocol {
    func pushToSetting()
}

extension AboutAccessable {
    func pushToSetting() {
        navigationController?.pushViewController(SettingViewController.instantiate(), animated: true)
    }
}

