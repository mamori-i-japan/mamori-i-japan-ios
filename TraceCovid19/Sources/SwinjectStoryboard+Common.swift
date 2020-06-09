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
import CoreBluetooth
import CoreData
import FirebaseAuth
import FirebaseRemoteConfig
import FirebaseStorage
import FirebaseFirestore
import Alamofire
import Reachability

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

        defaultContainer.storyboardInitCompleted(InputPrefectureViewController.self) { r, vc in
            vc.profileService = r.resolve(ProfileService.self)
            vc.loginService = r.resolve(LoginService.self)
        }

        defaultContainer.storyboardInitCompleted(InputOrganizationViewController.self) { r, vc in
            vc.profileService = r.resolve(ProfileService.self)
            vc.loginService = r.resolve(LoginService.self)
        }

        defaultContainer.storyboardInitCompleted(AuthSMSViewController.self) { r, vc in
            vc.keychain = r.resolve(KeychainService.self)
            vc.loginService = r.resolve(LoginService.self)
        }

        defaultContainer.storyboardInitCompleted(PermissionSettingViewController.self) { r, vc in
            vc.bleService = r.resolve(BLEService.self, argument: r.resolve(DispatchQueue.self, name: "BluetoothQueue")!)
            vc.notificationService = r.resolve(PushNotificationService.self)
        }

        defaultContainer.storyboardInitCompleted(HomeViewController.self) { r, vc in
            vc.keychain = r.resolve(KeychainService.self)
            vc.ble = r.resolve(BLEService.self, argument: r.resolve(DispatchQueue.self, name: "BluetoothQueue")!)
            vc.deepContactCheck = r.resolve(DeepContactCheckService.self)
            vc.positiveContact = r.resolve(PositiveContactService.self)
            vc.tempId = r.resolve(TempIdService.self)
            vc.loginService = r.resolve(LoginService.self)
            vc.profileService = r.resolve(ProfileService.self)
            vc.informationService = r.resolve(InformationService.self)
        }

        defaultContainer.storyboardInitCompleted(MenuViewController.self) { r, vc in
            vc.profileService = r.resolve(ProfileService.self)
            vc.loginService = r.resolve(LoginService.self)
            vc.cancelPositiveService = r.resolve(CancelPositiveService.self)
        }

        defaultContainer.storyboardInitCompleted(AboutViewController.self) { _, _ in
        }

        defaultContainer.storyboardInitCompleted(SettingViewController.self) { r, vc in
            vc.profileService = r.resolve(ProfileService.self)
            vc.loginService = r.resolve(LoginService.self)
            vc.keychainService = r.resolve(KeychainService.self)
        }

        defaultContainer.storyboardInitCompleted(TraceDataUploadViewController.self) { r, vc in
            vc.traceDataUpload = r.resolve(TraceDataUploadService.self)
            vc.loginService = r.resolve(LoginService.self)
        }

        defaultContainer.storyboardInitCompleted(TraceDataUploadCompleteViewController.self) { _, _ in
        }

        defaultContainer.storyboardInitCompleted(TraceNotificationViewController.self) { _, _ in
        }

        defaultContainer.storyboardInitCompleted(TraceHistoryViewController.self) { r, vc in
            vc.deepContactCheck = r.resolve(DeepContactCheckService.self)
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
            vc.profileService = r.resolve(ProfileService.self)
        }

        defaultContainer.storyboardInitCompleted(Debug3ViewController.self) { r, vc in
            vc.tempId = r.resolve(TempIdService.self)
            vc.positiveContact = r.resolve(PositiveContactService.self)
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
                loginAPI: r.resolve(LoginAPI.self)!,
                profileService: r.resolve(ProfileService.self)!
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
                storage: r.resolve(Lazy<Storage>.self)!,
                jsonDecoder: r.resolve(JSONDecoder.self)!
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
                coreData: r.resolve(CoreDataService.self)!,
                tempId: r.resolve(TempIdService.self)!
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
                storage: r.resolve(Lazy<Storage>.self)!,
                jsonDecoder: r.resolve(JSONDecoder.self)!,
                tempIdService: r.resolve(TempIdService.self)!,
                deepContactCheck: r.resolve(DeepContactCheckService.self)!
            )
        }.inObjectScope(.container) // Debug用のものと共用するためcontainerを使用

        defaultContainer.register(TempIdService.self) { r in
            TempIdService(tempIdGenerator: r.resolve(TempIdGenerator.self)!, coreData: r.resolve(CoreDataService.self)!)
        }

        defaultContainer.register(ProfileService.self) { r in
            ProfileService(
                firestore: r.resolve(Lazy<Firestore>.self)!,
                auth: r.resolve(Lazy<Auth>.self)!,
                profileAPI: r.resolve(ProfileAPI.self)!
            )
        }

        defaultContainer.register(TraceDataUploadService.self) { r in
            TraceDataUploadService(traceDataUploadAPI: r.resolve(TraceDataUploadAPI.self)!, tempIdService: r.resolve(TempIdService.self)!)
        }

        defaultContainer.register(InformationService.self) { r in
            InformationService(firestore: r.resolve(Lazy<Firestore>.self)!)
        }

        defaultContainer.register(CancelPositiveService.self) { r in
            CancelPositiveService(cancelPositiveAPI: r.resolve(CancelPositiveAPI.self)!, keychainService: r.resolve(KeychainService.self)!)
        }

        // MARK: - Others

        defaultContainer.register(Keychain.self) { _ in
            Keychain()
        }

        defaultContainer.register(UserDefaults.self) { _ in
            .standard
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

        defaultContainer.register(LoginAPI.self) { r in
            LoginAPI(apiClient: r.resolve(APIClient.self)!)
        }

        defaultContainer.register(TempIdGenerator.self) { _ in
            TempIdGenerator()
        }

        defaultContainer.register(Firestore.self) { _ in
            Firestore.firestore()
        }

        defaultContainer.register(APIClient.self) { r in
            APIClient(session: r.resolve(Session.self)!, auth: r.resolve(Lazy<Auth>.self)!)
        }

        defaultContainer.register(Session.self) { r in
            Session(serverTrustManager: ServerTrustManager(evaluators: r.resolve([String: SSLPinningManager].self)!))
        }

        defaultContainer.register([String: SSLPinningManager].self) { r in
            let pinningManager = SSLPinningManager(conditions: r.resolve([SSLPinningCondition].self)!)
            var dictionay: [String: SSLPinningManager] = [:]
            #if DEBUG
            // デバッグではデフォルト無効にしておく
            pinningManager.isEnable = false
            #endif
            pinningManager.hosts.forEach { dictionay[$0] = pinningManager }
            return dictionay
        }

        defaultContainer.register([SSLPinningCondition].self) { _ in
            #if DEV
            return [
                SSLPinningCondition(
                    host: "api-dev.mamori-i.jp",
                    hashes: ["zMOvA34BcbgmGIaP3vndMkbThDS74hnTD4UZMK10MqA="],
                    expiredUnixTime: 1621684800 - 3600 * 24 * 30 // NOTE: May 22 12:00:00 2021 GMT からマージン(30日)を引いた日時を期限として設定
                )
            ]
            #elseif STG
            return [
                SSLPinningCondition(
                    host: "api-stg.mamori-i.jp",
                    hashes: ["zMOvA34BcbgmGIaP3vndMkbThDS74hnTD4UZMK10MqA="],
                    expiredUnixTime: 1621684800 - 3600 * 24 * 30 // NOTE: May 22 12:00:00 2021 GMT からマージン(30日)を引いた日時を期限として設定
                )
            ]
            #else
            return [
                SSLPinningCondition(
                    host: "api-demo.mamori-i.jp",
                    hashes: ["q2EjjSpLfR+nqnWE/yrjLQVmq8Lse0CI2/vQn/F07VA="],
                    expiredUnixTime: 1621684800 - 3600 * 24 * 30 // NOTE: May 22 12:00:00 2021 GMT からマージン(30日)を引いた日時を期限として設定
                )
            ]
            #endif
        }

        defaultContainer.register(TraceDataUploadAPI.self) { r in
            TraceDataUploadAPI(apiClient: r.resolve(APIClient.self)!, keychain: r.resolve(KeychainService.self)!)
        }

        defaultContainer.register(ProfileAPI.self) { r in
            ProfileAPI(apiClient: r.resolve(APIClient.self)!)
        }

        defaultContainer.register(CancelPositiveAPI.self) { r in
            CancelPositiveAPI(apiClient: r.resolve(APIClient.self)!)
        }
    }
}
