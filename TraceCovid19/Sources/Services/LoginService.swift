//
//  LoginService.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/09.
//

import Foundation
import FirebaseAuth
import Swinject

final class LoginService {
    private let auth: Lazy<Auth> // Firebase.configure()の後で使用するためLazyでラップ
    private let keychain: KeychainService
    private let userDefaults: UserDefaultsService
    private let ble: BLEService
    private let coreData: CoreDataService
    private let loginAPI: LoginAPI

    var isLogin: Bool {
        return auth.instance.currentUser != nil
    }

    init(auth: Lazy<Auth>, keychain: KeychainService, userDefaults: UserDefaultsService, ble: BLEService, coreData: CoreDataService, loginAPI: LoginAPI) {
        self.auth = auth
        self.keychain = keychain
        self.userDefaults = userDefaults
        self.ble = ble
        self.coreData = coreData
        self.loginAPI = loginAPI
    }

    func signIn(verificationID: String, code: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: code)

        auth.instance.signIn(with: credential) { [weak self] _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                self?.requestLogin(completion: completion)
            }
        }
    }

    private func requestLogin(completion: @escaping (Result<Void, Error>) -> Void) {
        loginAPI.login { [weak self] result in
            switch result {
            case .success:
                // 非同期で、とりあえず投げておく（結果は見ない）
                self?.forceRefreshToken()
                completion(.success(()))

            case .failure(.error(let error)),
                 .failure(.statusCodeError(_, _, let error)):
                completion(.failure(error ?? NSError(domain: "unknown", code: 0, userInfo: nil)))
            }
            print(result)
        }
    }

    private func forceRefreshToken() {
        auth.instance.currentUser?.getIDTokenForcingRefresh(true) { token, error in
            print("[LoginService] ForeceRefresh finished. token: \(token ?? "nil"), error: \(String(describing: error))")
            // TODO: つづいて、Firestoreを用いて都道府県・職業の同期を行う（結果はまたない）
        }
    }

    func logout() {
        do {
            try auth.instance.signOut()
            keychain.removeAll()
            userDefaults.removeAll()
            ble.turnOff()
            coreData.deleteAll()
            // TODO: プッシュ通知の購読解除？
        } catch {
            print("sign out error: \(error)")
        }
    }

    #if DEBUG
    var uid: String? {
        return auth.instance.currentUser?.uid
    }

    var phoneNumber: String? {
        return auth.instance.currentUser?.phoneNumber
    }
    #endif
}
