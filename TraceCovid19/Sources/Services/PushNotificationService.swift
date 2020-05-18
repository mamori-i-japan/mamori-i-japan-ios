//
//  PushNotificationService.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/11.
//

import Foundation
import UserNotifications

final class PushNotificationService {
    private let notificationCenter: UNUserNotificationCenter

    init(notificationCenter: UNUserNotificationCenter) {
        self.notificationCenter = notificationCenter
    }

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            print("[PUSH] granted: \(granted), error: \(String(describing: error))")
            completion(granted)
        }
    }

    func getAuthorization(completion: @escaping (Bool) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                print("[PUSH] authorized")
                completion(true)
                return
            case .denied:
                print("[PUSH] denied")
            case .notDetermined:
                print("[PUSH] notDetermined")
            case .provisional:
                print("[PUSH] provisional")
            @unknown default:
                print("[PUSH] unknown")
            }
            completion(false)
        }
    }
}
