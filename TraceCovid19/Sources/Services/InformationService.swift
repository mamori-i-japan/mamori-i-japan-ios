//
//  InformationService.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/05/06.
//

import Foundation
import FirebaseFirestore
import Swinject
import Reachability

final class InformationService {
    private let firestore: Lazy<Firestore> // Firebase.configure()の後で使用するためLazyでラップ

    init(firestore: Lazy<Firestore>) {
        self.firestore = firestore
    }

    enum InformationGetError: Error {
        case network
        case parse
        case unknown(Error?)
    }

    func get(organizationCode: String, completion: @escaping (Result<Information, InformationGetError>) -> Void) {
        // NOTE: Firestoreだと性質上オフラインでもエラーのcoallbackが帰ってこないので事前にチェックする
        guard let rechability = try? Reachability(), rechability.connection != .unavailable else {
            print("[InformationService] network error")
            completion(.failure(.network))
            return
        }

        firestore.instance
            .collection("organizations")
            .document(organizationCode)
            .collection("denormalizedForAppAccess")
            .document(organizationCode).getDocument { response, error in
                if let error = error {
                    switch FirestoreErrorCode(rawValue: (error as NSError).code) {
                    case .unavailable:
                        print("[InformationService] network error")
                        completion(.failure(.network))
                    default:
                        print("[InformationService] error \(error as NSError)")
                        completion(.failure(.unknown(error)))
                    }
                    return
                }

                guard let dictionary = response?.data() else {
                    // 空状態
                    completion(.success(.empty))
                    return
                }

                guard let information = try? Information.make(dictionary: dictionary.convertFirebaseTimestampToDate()) else {
                    print("[InformationService] parse error")
                    completion(.failure(.parse))
                    return
                }
                completion(.success(information))
            }
    }
}
