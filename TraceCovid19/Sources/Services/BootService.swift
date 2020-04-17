//
//  BootService.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/09.
//

import Foundation
import FirebaseRemoteConfig
import Swinject

final class BootService {
    private let userDefaults: UserDefaultsService
    private let keychain: KeychainService
    private let loginService: LoginService
    private let remoteConfig: Lazy<RemoteConfig>

    private var isMaintenance: Bool {
        return remoteConfig.instance.configValue(forKey: "is_maintenance").boolValue
    }

    private var minimumVersion: AppVersion? {
        guard let versionString = remoteConfig.instance.configValue(forKey: "minimum_version").stringValue,
            let version = AppVersion(versionString: versionString) else {
            return nil
        }
        return version
    }

    private var storeURL: URL? {
        guard let urlString = remoteConfig.instance.configValue(forKey: "store_url").stringValue,
            let url = URL(string: urlString) else {
            return nil
        }
        return url
    }

    init(
        userDefaults: UserDefaultsService,
        keychain: KeychainService,
        loginService: LoginService,
        remoteConfig: Lazy<RemoteConfig>
    ) {
        self.userDefaults = userDefaults
        self.keychain = keychain
        self.loginService = loginService
        self.remoteConfig = remoteConfig
    }

    enum RemoteConfigStatus {
        case success
        case failed
        case isMaintenance
        case isNeedUpdate(storeURL: URL)
    }

    func execLaunch(completion: @escaping (RemoteConfigStatus) -> Void) {
        print(#function)
        clearStorageIfUninstalled()
        setupRandomToken()
        syncRemoteConfig(completion: completion)
    }

    func execEnterForeground(completion: @escaping (RemoteConfigStatus) -> Void) {
        print(#function)
        syncRemoteConfig(completion: completion)
    }

    /// アンインストールを検知したらログアウト(状態を初期化)する
    private func clearStorageIfUninstalled() {
        if userDefaults.lastUseAppVersion == nil {
            loginService.logout()
        }

        // 現在のアプリバージョンで更新する
        userDefaults.lastUseAppVersion = .currentAppVersion
    }

    /// APIアクセス用の識別子を準備(x-mobile-secret-random-token)
    private func setupRandomToken() {
        if keychain.randomToken == nil {
            let uuid = UUID()
            keychain.randomToken = uuid.uuidString
            return
        }
    }

    private func syncRemoteConfig(completion: @escaping (RemoteConfigStatus) -> Void) {
        remoteConfig.instance.fetchAndActivate { [weak self] _, error in
            guard self?.checkRemoteConfigResult() == true && error == nil else {
                completion(.failed)
                return
            }
            guard self?.checkMaintenance() == true else {
                completion(.isMaintenance)
                return
            }
            guard self?.checkAppVersion() == true else {
                completion(.isNeedUpdate(storeURL: self!.storeURL!))
                return
            }
            completion(.success)
        }
    }

    private func checkRemoteConfigResult() -> Bool {
        return minimumVersion != nil && storeURL != nil
    }

    private func checkMaintenance() -> Bool {
        print("is isMaintenance: \(isMaintenance)")
        return !isMaintenance
    }

    private func checkAppVersion() -> Bool {
        print("is currentAppVersion: \(AppVersion.currentAppVersion) >= minimumVersion: \(minimumVersion!)")
        return AppVersion.currentAppVersion >= minimumVersion!
    }
}
