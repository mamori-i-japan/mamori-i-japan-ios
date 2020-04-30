//
//  NavigationProtocol+Menu.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/30.
//

import Foundation

protocol MenuAccessable: PushNavigationProtocol {
    func pushToMenu()
}

extension MenuAccessable {
    func pushToMenu() {
        push(to: MenuViewController.instantiate())
    }
}

protocol AboutAccessable: PushNavigationProtocol {
    func pushToAbout()
}

extension AboutAccessable {
    func pushToAbout() {
        push(to: AboutViewController.instantiate())
    }
}

protocol SettingAccessable: PushNavigationProtocol {
    func pushToSetting()
}

extension AboutAccessable {
    func pushToSetting() {
        push(to: SettingViewController.instantiate())
    }
}
