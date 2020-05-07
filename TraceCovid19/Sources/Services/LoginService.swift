//
//  LoginService.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/09.
//

import Foundation
import FirebaseAuth
import Swinject
import FirebaseFirestore

final class LoginService {
    private let auth: Lazy<Auth> // Firebase.configure()の後で使用するためLazyでラップ
    private let keychain: KeychainService
    private let userDefaults: UserDefaultsService
    private let ble: BLEService
    private let coreData: CoreDataService
    private let loginAPI: LoginAPI
    private let profileService: ProfileService

    var isLogin: Bool {
        return auth.instance.currentUser != nil
    }

    init(
        auth: Lazy<Auth>,
        keychain: KeychainService,
        userDefaults: UserDefaultsService,
        ble: BLEService,
        coreData: CoreDataService,
        loginAPI: LoginAPI,
        profileService: ProfileService
    ) {
        self.auth = auth
        self.keychain = keychain
        self.userDefaults = userDefaults
        self.ble = ble
        self.coreData = coreData
        self.loginAPI = loginAPI
        self.profileService = profileService
    }

    enum SignInError: Error {
        case networkError
        case unknown(Error)
    }

    func signInAnonymously(profile: Profile, completion: @escaping (Result<Void, SignInError>) -> Void) {
        auth.instance.signInAnonymously { [weak self] _, error in
            if let error = error {
                switch AuthErrorCode(rawValue: (error as NSError).code) {
                case .some(.networkError):
                    print("[LoginService] singIn ローカル通信エラー")
                    completion(.failure(.networkError))
                default:
                    print("[LoginService] singIn その他エラー: code=\((error as NSError).code)")
                    completion(.failure(.unknown(error)))
                }
            } else {
                self?.requestLogin(profile: profile, completion: completion)
            }
        }
    }

    // NOTE: SMS認証はPh1では未使用
    func signIn(verificationID: String, code: String, profile: Profile, completion: @escaping (Result<Void, SignInError>) -> Void) {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: code)

        auth.instance.signIn(with: credential) { [weak self] _, error in
            if let error = error {
                switch AuthErrorCode(rawValue: (error as NSError).code) {
//                case .some(.invalidVerificationCode):
//                    print("[LoginService] singIn コード不正")
//                    completion(.failure(.notMatch))
//                case .some(.sessionExpired):
//                    print("[LoginService] singIn 期限切れ")
//                    completion(.failure(.expired))
                case .some(.networkError):
                    print("[LoginService] singIn ローカル通信エラー")
                    completion(.failure(.networkError))
                default:
                    print("[LoginService] singIn その他エラー: code=\((error as NSError).code)")
                    completion(.failure(.unknown(error)))
                }
            } else {
                self?.requestLogin(profile: profile, completion: completion)
            }
        }
    }

    private func requestLogin(profile: Profile, completion: @escaping (Result<Void, SignInError>) -> Void) {
        loginAPI.login(profile: profile) { [weak self] result in
            switch result {
            case .success:
                // 非同期で、とりあえず投げておく（結果は見ない）
                self?.forceRefreshToken(profile: profile)
                completion(.success(()))
            case .failure(.error(let error)),
                 .failure(.statusCodeError(_, _, let error)):
                completion(.failure(.unknown(error ?? NSError(domain: "unknown", code: 0, userInfo: nil))))
            case .failure(.authzError): // ログインには認証エラーは返ってこないのでエラーとする
                completion(.failure(.unknown(APIRequestError.authzError)))
            }
            print(result)
        }
    }

    private func forceRefreshToken(profile: Profile) {
        auth.instance.currentUser?.getIDTokenForcingRefresh(true) { token, error in
            print("[LoginService] ForeceRefresh finished. token: \(token ?? "nil"), error: \(String(describing: error))")
        }
    }

    @discardableResult
    func logout() -> Bool {
        do {
            try auth.instance.signOut()
            keychain.removeAll()
            userDefaults.removeAll()
            ble.turnOff()
            coreData.deleteAll()
            return true
            // TODO: プッシュ通知の購読解除？
        } catch {
            print("sign out error: \(error)")
            return false
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
