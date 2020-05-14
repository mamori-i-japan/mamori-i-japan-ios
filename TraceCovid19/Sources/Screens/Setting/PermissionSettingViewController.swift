//
//  PermissionSettingViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/09.
//

import UIKit
import KeychainAccess

final class PermissionSettingViewController: UIViewController, NavigationBarHiddenApplicapable, HomeAccessable {
    var bleService: BLEService!
    var notificationService: PushNotificationService!

    var isPushPermissionConfirmed = false {
        didSet {
            checkPermissionState()
        }
    }

    @IBAction func tappedNextButton(_ sender: Any) {
        checkBLE()
        requestNotification()
    }

    func checkBLE() {
        // TODO: iOS13とそうでないかで挙動がことなるので調査する（12だと画面遷移後にパーミッションが出てしまっている）
        // `poweredOn`しかとれない
        bleService.bluetoothDidUpdateStateCallback = { [weak self] state in
            print("[PermissionSetting] ble: \(state.toString)")
            self?.bleService.bluetoothDidUpdateStateCallback = nil
            self?.bleService.turnOff()

            // NOTE: iOS13未満の場合に、許可ダイアログのもどりを判別できないのでハンドリングはしない
        }

        // 一度起動させる（パーミッションだけ動かす手段がないため）
        bleService.turnOn()
    }

    func requestNotification() {
        notificationService.requestAuthorization { [weak self] isGranted in
            print("[PermissionSetting] push: \(isGranted)")
            self?.isPushPermissionConfirmed = true
        }
    }

    private func checkPermissionState() {
        // 各種パーミッションの確認が取れているかどうか
        guard isPushPermissionConfirmed else { return }
        DispatchQueue.main.async { [weak self] in
            self?.finishRegistration()
        }
    }

    func finishRegistration() {
        setViewControllersWithHome()
    }
}
