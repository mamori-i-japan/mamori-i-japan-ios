//
//  SMSService.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/13.
//

import Foundation
import FirebaseAuth
import Swinject

final class SMSService {
    private let phoneAuth: Lazy<PhoneAuthProvider> // Firebase.configure()の後で使用するためLazyでラップ

    init(phoneAuth: Lazy<PhoneAuthProvider>) {
        self.phoneAuth = phoneAuth
    }

    enum SendSMSError: Error {
        case network
        case upperLimit
        case unknown(Error?)
    }

    /// SMS送信
    /// - Parameter phoneNumber: 11桁番号ハイフンなし
    func sendSMS(phoneNumber: String, completion: @escaping (Result<String, SendSMSError>) -> Void) {
        phoneAuth.instance.verifyPhoneNumber(phoneNumber.formatted, uiDelegate: nil) { verificationID, error in
            if let error = error {
                switch AuthErrorCode(rawValue: (error as NSError).code) {
                case .some(.captchaCheckFailed):
                    print("[SMSService] sendSMS reCAPTCHA不正")
                case .some(.invalidPhoneNumber):
                    print("[SMSService] sendSMS 電番不正")
                case .some(.missingPhoneNumber):
                    print("[SMSService] sendSMS 電番未入力")
                case .some(.tooManyRequests):
                    print("[SMSService] sendSMS 上限エラー")
                    completion(.failure(.upperLimit))
                    return
                case .some(.networkError):
                    print("[SMSService] sendSMS network error")
                    completion(.failure(.network))
                    return
                default:
                    // TODO: キャプチャキャンセルなど、エラーとして扱わないものの精査
                    print("[SMSService] sendSMS その他エラー: code=\((error as NSError).code)")
                }
                completion(.failure(.unknown(error)))
                return
            }
            guard let verificationID = verificationID else {
                completion(.failure(.unknown(NSError(domain: "Not found verification id", code: 0, userInfo: nil))))
                return
            }
            completion(.success(verificationID))
        }
    }
}

private extension String {
    var formatted: String {
        // 先頭に国コードを付与（先頭の0を落としても落とさなくてもどちらでも動く）
        return "+81" + self
    }
}
