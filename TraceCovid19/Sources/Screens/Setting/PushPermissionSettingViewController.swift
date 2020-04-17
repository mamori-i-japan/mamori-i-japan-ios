//
//  PushPermissionSettingViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/11.
//

import UIKit

final class PushPermissionSettingViewController: UIViewController {
    var notificationService: PushNotificationService!

    @IBAction func tappedNextButton(_ sender: Any) {
        requestNotification()
    }

    func requestNotification() {
        notificationService.requestAuthorization { [weak self] isGranted in
            print(isGranted)
            // TODO: 許可されなかった場合に何かする？

            DispatchQueue.main.async { [weak self] in
                self?.finishRegistration()
            }
        }
    }

    func finishRegistration() {
        navigationController?.setViewControllers([HomeViewController.instantiate()], animated: true)
    }
}
