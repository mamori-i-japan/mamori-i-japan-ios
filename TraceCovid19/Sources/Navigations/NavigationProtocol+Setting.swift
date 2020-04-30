//
//  NavigationProtocol+Setting.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/28.
//

import Foundation

protocol PermissionSettingAccessable: PushNavigationProtocol {
    func pushToPermissionSetting()
}

extension PermissionSettingAccessable {
    func pushToPermissionSetting() {
        push(to: PermissionSettingViewController.instantiate())
    }
}
