//
//  NavigationProtocol+Setting.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/28.
//

import Foundation

protocol PermissionSettingAccessable: NavigationProtocol {
    func pushToPermissionSetting()
}

extension PermissionSettingAccessable {
    func pushToPermissionSetting() {
        navigationController?.pushViewController(PermissionSettingViewController.instantiate(), animated: true)
    }
}
