//
//  BootService.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/09.
//

import Foundation
import FirebaseStorage
import Swinject
import Reachability

final class BootService {
    private let userDefaults: UserDefaultsService
    private let keychain: KeychainService
    private let loginService: LoginService
    private let storage: Lazy<Storage>
    private let jsonDecoder: JSONDecoder

    private var lastGeneration: Int64?
    private(set) var appStatus: AppStatusDetail?

    private var fileName: String {
        return "app_status.json"
    }

    init(
        userDefaults: UserDefaultsService,
        keychain: KeychainService,
        loginService: LoginService,
        storage: Lazy<Storage>,
        jsonDecoder: JSONDecoder
    ) {
        self.userDefaults = userDefaults
        self.keychain = keychain
        self.loginService = loginService
        self.storage = storage
        self.jsonDecoder = jsonDecoder
    }

    enum RemoteConfigStatus {
        case success
        case failed(RemoteConfigError)
        case isMaintenance
        case isNeedUpdate(storeURL: URL)
    }

    enum RemoteConfigError: Error {
        case network
        case parse
        case unknown(Error?)
    }

    func execLaunch(completion: @escaping (RemoteConfigStatus) -> Void) {
        print(#function)
        clearStorageIfUninstalled()
        fetchAppStatus(completion: completion)
    }

    func execEnterForeground(completion: @escaping (RemoteConfigStatus) -> Void) {
        print(#function)
        fetchAppStatus(completion: completion)
    }

    /// アンインストールを検知したらログアウト(状態を初期化)する
    private func clearStorageIfUninstalled() {
        if userDefaults.lastUseAppVersion == nil {
            loginService.logout()
        }

        // 現在のアプリバージョンで更新する
        userDefaults.lastUseAppVersion = .currentAppVersion
    }

    private func fetchAppStatus(completion: @escaping (RemoteConfigStatus) -> Void) {
        // NOTE: FirebaseStorageもオフラインではコールバックが呼ばれないため事前にチェックする
        guard let rechability = try? Reachability(), rechability.connection != .unavailable else {
            print("[BootService] network error")
            completion(.failed(.network))
            return
        }

        let reference = storage.instance.reference().child(fileName)
        reference.getMetadata { [weak self] metaData, error in
            guard let metaData = metaData, error == nil else {
                print("[BootService] error occurred: \(String(describing: error))")
                completion(.failed(.unknown(error)))
                return
            }

            print("[BootService] new generation: \(String(describing: metaData.generation)), last generation: \(String(describing: self?.lastGeneration))")
            if let lastGeneration = self?.lastGeneration,
                lastGeneration <= metaData.generation {
                // 取得不要
                self?.handle(completion: completion)
                return
            }

            // メモリ指定（最大1MB）
            reference.getData(maxSize: 1 * 1024 * 1024) { [weak self] data, error in
                guard let sSelf = self else { return }
                guard let data = data, error == nil else {
                    print("[BootService] error occurred: \(String(describing: error))")
                    completion(.failed(.unknown(error)))
                    return
                }
                print("[BootService] data: \(String(describing: String(data: data, encoding: .utf8)))")

                do {
                    let appStatus = try sSelf.jsonDecoder.decode(AppStatus.self, from: data)
                    self?.lastGeneration = metaData.generation
                    self?.appStatus = appStatus.ios
                    self?.handle(completion: completion)
                } catch {
                    print("[BootService] parse error: \(error)")
                    completion(.failed(.parse))
                }
            }
        }
    }

    private func handle(completion: @escaping (RemoteConfigStatus) -> Void) {
        guard let appStatus = appStatus, appStatus.minAppVersion != nil else {
            completion(.failed(.parse))
            return
        }

        print("[BootService] isMaintenance: \(appStatus.isMaintenance)")
        guard !appStatus.isMaintenance else {
            completion(.isMaintenance)
            return
        }

        print("[BootService] is currentAppVersion: \(AppVersion.currentAppVersion) >= minAppVersion: \(appStatus.minAppVersion!)")
        guard AppVersion.currentAppVersion >= appStatus.minAppVersion! else {
            completion(.isNeedUpdate(storeURL: appStatus.storeUrl))
            return
        }

        completion(.success)
    }
}
