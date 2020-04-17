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

    /// SMS送信
    /// - Parameter phoneNumber: 11桁番号ハイフンなし
    func sendSMS(phoneNumber: String, completion: @escaping (Result<String, Error>) -> Void) {
        phoneAuth.instance.verifyPhoneNumber(phoneNumber.formatted, uiDelegate: nil) { verificationID, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let verificationID = verificationID else {
                completion(.failure(NSError(domain: "Not found verification id", code: 0, userInfo: nil)))
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
