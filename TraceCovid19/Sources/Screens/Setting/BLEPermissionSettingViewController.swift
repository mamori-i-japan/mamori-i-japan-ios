//
//  BLEPermissionSettingViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/09.
//

import UIKit
import KeychainAccess

final class BLEPermissionSettingViewController: UIViewController {
    var bleService: BLEService!

    @IBAction func tappedNextButton(_ sender: Any) {
        checkBLE()
    }

    func checkBLE() {
        // TODO: iOS13とそうでないかで挙動がことなるので調査する（12だと画面遷移後にパーミッションが出てしまっている）
        bleService.bluetoothDidUpdateStateCallback = { [weak self] state in
            print(state.toString)
            self?.bleService.bluetoothDidUpdateStateCallback = nil
            self?.bleService.turnOff()

            // TODO: stateによって許可されなかった場合とかの見せ方

            DispatchQueue.main.async { [weak self] in
                self?.gotoPushPermissionSetting()
            }
        }

        // 一度起動させる（パーミッションだけ動かす手段がないため）
        bleService.turnOn()
    }

    func gotoPushPermissionSetting() {
        navigationController?.pushViewController(PushPermissionSettingViewController.instantiate(), animated: true)
    }
}
