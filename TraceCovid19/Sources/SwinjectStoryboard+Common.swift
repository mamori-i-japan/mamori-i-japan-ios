//
//  SwinjectStoryboard+Common.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/02.
//

import Foundation
import Swinject
import SwinjectStoryboard
import KeychainAccess
import UserNotifications
import CoreData
import FirebaseAuth
import FirebaseRemoteConfig
import FirebaseStorage

extension SwinjectStoryboard {
    @objc
    class func setup() {
        // MARK: - ViewController

        defaultContainer.storyboardInitCompleted(SplashViewController.self) { r, vc in
            vc.bootService = r.resolve(BootService.self)
            vc.loginService = r.resolve(LoginService.self)
        }

        defaultContainer.storyboardInitCompleted(Tutorial1ViewController.self) { _, _ in
        }

        defaultContainer.storyboardInitCompleted(Tutorial2ViewController.self) { _, _ in
        }

        defaultContainer.storyboardInitCompleted(Tutorial3ViewController.self) { _, _ in
        }

        defaultContainer.storyboardInitCompleted(Agreement1ViewController.self) { _, _ in
        }

        defaultContainer.storyboardInitCompleted(Agreement2ViewController.self) { _, _ in
        }

        defaultContainer.storyboardInitCompleted(InputPhoneNumberViewController.self) { r, vc in
            vc.smsService = r.resolve(SMSService.self)
        }

        defaultContainer.storyboardInitCompleted(InputPrefectureViewController.self) { _, _ in
        }

        defaultContainer.storyboardInitCompleted(AuthSMSViewController.self) { r, vc in
            vc.keychain = r.resolve(KeychainService.self)
            vc.loginService = r.resolve(LoginService.self)
        }

        defaultContainer.storyboardInitCompleted(BLEPermissionSettingViewController.self) { r, vc in
            vc.bleService = r.resolve(BLEService.self, argument: r.resolve(DispatchQueue.self, name: "BluetoothQueue")!)
        }

        defaultContainer.storyboardInitCompleted(PushPermissionSettingViewController.self) { r, vc in
            vc.notificationService = r.resolve(PushNotificationService.self)
        }

        defaultContainer.storyboardInitCompleted(HomeViewController.self) { r, vc in
            vc.keychain = r.resolve(KeychainService.self)
            vc.ble = r.resolve(BLEService.self, argument: r.resolve(DispatchQueue.self, name: "BluetoothQueue")!)
            vc.deepContactCheck = r.resolve(DeepContactCheckService.self)
            vc.positiveContact = r.resolve(PositiveContactService.self)
            vc.tempId = r.resolve(TempIdService.self)
        }

        defaultContainer.storyboardInitCompleted(MenuViewController.self) { _, _ in
        }

        defaultContainer.storyboardInitCompleted(AboutViewController.self) { _, _ in
        }

        defaultContainer.storyboardInitCompleted(TraceDataUploadViewController.self) { _, _ in
        }

        defaultContainer.storyboardInitCompleted(TraceNotificationViewController.self) { _, _ in
        }

        #if DEBUG
        defaultContainer.storyboardInitCompleted(DebugViewController.self) { r, vc in
            vc.keychain = r.resolve(KeychainService.self)
            vc.loginService = r.resolve(LoginService.self)
            vc.ble = r.resolve(BLEService.self, argument: r.resolve(DispatchQueue.self, name: "BluetoothQueue")!)
            vc.push = r.resolve(PushNotificationService.self)
            vc.coreData = r.resolve(CoreDataService.self)
            vc.deepContactCheck = r.resolve(DeepContactCheckService.self)
            vc.positiveContact = r.resolve(PositiveContactService.self)
            vc.tempId = r.resolve(TempIdService.self)
        }

        defaultContainer.storyboardInitCompleted(Debug2ViewController.self) { r, vc in
            vc.positiveContact = r.resolve(PositiveContactService.self)
        }

        defaultContainer.storyboardInitCompleted(Debug3ViewController.self) { r, vc in
            vc.tempId = r.resolve(TempIdService.self)
        }
        #endif

        // MARK: - Service

        defaultContainer.register(LoginService.self) { r in
            LoginService(
                auth: r.resolve(Lazy<Auth>.self)!,
                keychain: r.resolve(KeychainService.self)!,
                userDefaults: r.resolve(UserDefaultsService.self)!,
                ble: r.resolve(BLEService.self, argument: r.resolve(DispatchQueue.self, name: "BluetoothQueue")!)!,
                coreData: r.resolve(CoreDataService.self)!,
                loginAPI: r.resolve(LoginAPI.self)!
            )
        }

        defaultContainer.register(SMSService.self) { r in
            SMSService(phoneAuth: r.resolve(Lazy<PhoneAuthProvider>.self)!)
        }

        defaultContainer.register(BootService.self) { r in
            BootService(
                userDefaults: r.resolve(UserDefaultsService.self)!,
                keychain: r.resolve(KeychainService.self)!,
                loginService: r.resolve(LoginService.self)!,
                remoteConfig: r.resolve(Lazy<RemoteConfig>.self)!
            )
        }

        defaultContainer.register(KeychainService.self) { r in
            KeychainService(keychain: r.resolve(Keychain.self)!)
        }

        defaultContainer.register(UserDefaultsService.self) { r in
            UserDefaultsService(userDefaults: r.resolve(UserDefaults.self)!)
        }

        defaultContainer.register(BLEService.self) { r, queue in
            BLEService(
                queue: queue,
                peripheralController: r.resolve(PeripheralController.self, argument: queue)!,
                centralController: r.resolve(CentralController.self, argument: queue)!
            )
        }.inObjectScope(.container)

        defaultContainer.register(PushNotificationService.self) { r in
            PushNotificationService(notificationCenter: r.resolve(UNUserNotificationCenter.self)!)
        }

        defaultContainer.register(CoreDataService.self) { r in
            CoreDataService(persistentContainer: r.resolve(NSPersistentContainer.self)!)
        }

        defaultContainer.register(DeepContactCheckService.self) { r in
            DeepContactCheckService(coreData: r.resolve(CoreDataService.self)!)
        }.inObjectScope(.container) // Debug用のものと共用するためcontainerを使用

        defaultContainer.register(PositiveContactService.self) { r in
            PositiveContactService(
                storage: r.resolve(Storage.self)!,
                jsonDecoder: r.resolve(JSONDecoder.self)!,
                tempIdService: r.resolve(TempIdService.self)!,
                deepContactCheck: r.resolve(DeepContactCheckService.self)!
            )
        }.inObjectScope(.container) // Debug用のものと共用するためcontainerを使用

        defaultContainer.register(TempIdService.self) { r in
            TempIdService(tempIdAPI: r.resolve(TempIdAPI.self)!, coreData: r.resolve(CoreDataService.self)!)
        }

        // MARK: - Others

        defaultContainer.register(Keychain.self) { _ in
            Keychain()
        }

        defaultContainer.register(UserDefaults.self) { _ in
            .standard
        }

        defaultContainer.register(CentralController.self) { r, queue in
            CentralController(queue: queue, keychain: r.resolve(KeychainService.self)!, coreData: r.resolve(CoreDataService.self)!)
        }

        defaultContainer.register(PeripheralController.self) { r, queue in
            // TODO: ペリフェラル名
            PeripheralController(peripheralName: "TR", queue: queue, tempId: r.resolve(TempIdService.self)!, coreData: r.resolve(CoreDataService.self)!)
        }

        defaultContainer.register(DispatchQueue.self, name: "BluetoothQueue") { _ in
            DispatchQueue(label: "BluetoothQueue")
        }

        defaultContainer.register(UNUserNotificationCenter.self) { _ in
            .current()
        }

        defaultContainer.register(NSPersistentContainer.self) { _ in
            let container = NSPersistentContainer(name: "Model")
            container.loadPersistentStores { _, error in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
            return container
        }.inObjectScope(.container)

        defaultContainer.register(Auth.self) { _ in
            Auth.auth()
        }

        defaultContainer.register(PhoneAuthProvider.self) { _ in
            PhoneAuthProvider.provider()
        }

        defaultContainer.register(RemoteConfig.self) { _ in
            let remoteConfig = RemoteConfig.remoteConfig()
            let settings = RemoteConfigSettings()
            settings.minimumFetchInterval = 0
            remoteConfig.configSettings = settings
            return remoteConfig
        }

        defaultContainer.register(Storage.self) { _ in
            Storage.storage()
        }

        defaultContainer.register(JSONDecoder.self) { _ in
            JSONDecoder()
        }

        defaultContainer.register(LoginAPI.self) { _ in
            LoginAPI()
        }

        defaultContainer.register(TempIdAPI.self) { _ in
            TempIdAPI()
        }
    }
}
