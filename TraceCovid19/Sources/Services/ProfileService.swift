//
//  ProfileService.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/19.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Swinject
import Reachability

final class ProfileService {
    private let firestore: Lazy<Firestore> // Firebase.configure()の後で使用するためLazyでラップ
    private let auth: Lazy<Auth>

    init(firestore: Lazy<Firestore>, auth: Lazy<Auth>) {
        self.firestore = firestore
        self.auth = auth
    }

    enum ProfileSetError: Error {
        case network
        case unknown(Error?)
    }

    enum ProfileGetError: Error {
        case network
        case parse
        case unknown(Error?)
    }

    func set(profile: Profile, completion: @escaping (Result<Void, ProfileSetError>) -> Void) {
        guard let uid = auth.instance.currentUser?.uid else {
            print("[ProfileService] not found uid")
            completion(.failure(.unknown(NSError(domain: "Not found uid", code: 0, userInfo: nil))))
            return
        }
        guard let profileData = try? profile.asDictionary() else {
            print("[ProfileService] profile is invalid format: \(profile)")
            completion(.failure(.unknown(NSError(domain: "Profile is invalid format", code: 0, userInfo: nil))))
            return
        }

        // NOTE: Firestoreだと性質上オフラインでもエラーのcoallbackが帰ってこないので事前にチェックする
        guard let rechability = try? Reachability(), rechability.connection != .unavailable else {
            print("[ProfileService] network error")
            completion(.failure(.network))
            return
        }

        firestore.instance
            .collection("users")
            .document(uid)
            .collection("profile")
            .document(uid).setData(profileData.convertDateToFirebaseTimestamp()) { error in
                if let error = error {
                    print("[ProfileService] Error writing profile: \(error)")
                    switch FirestoreErrorCode(rawValue: (error as NSError).code) {
                    case .unavailable:
                        print("[ProfileService] network error")
                        completion(.failure(.network))
                    default:
                        print("[ProfileService] error \(error as NSError)")
                        completion(.failure(.unknown(error)))
                    }
                } else {
                    print("[ProfileService] Profile successfully written")
                    completion(.success(()))
                }
            }
    }

    func get(completion: @escaping (Result<Profile, ProfileGetError>) -> Void) {
        guard let uid = auth.instance.currentUser?.uid else {
            print("[ProfileService] not found uid")
            completion(.failure(.unknown(NSError(domain: "not found uid", code: 0, userInfo: nil))))
            return
        }
        firestore.instance
            .collection("users")
            .document(uid)
            .collection("profile")
            .document(uid).getDocument { response, error in
                if let error = error {
                    switch FirestoreErrorCode(rawValue: (error as NSError).code) {
                    case .unavailable:
                        print("[ProfileService] network error")
                        completion(.failure(.network))
                    default:
                        print("[ProfileService] error \(error as NSError)")
                        completion(.failure(.unknown(error)))
                    }
                    return
                }

                guard let dictionary = response?.data() else {
                    // 空状態(理論上はありうるため正常系として返す)
                    completion(.success(Profile.empty))
                    return
                }

                guard let profile = try? Profile.make(dictionary: dictionary.convertFirebaseTimestampToDate()) else {
                    print("[ProfileService] parse error")
                    completion(.failure(.parse))
                    return
                }
                completion(.success(profile))
            }
    }
}

extension String {
    static let firebaseTimestampPrefix = "FIRTimestamp:"
}

private extension String {
    var dropFribaseTemstampPrefix: String {
        let regex = try? NSRegularExpression(pattern: "^\(String.firebaseTimestampPrefix)", options: [])
        return regex?.stringByReplacingMatches(in: self, options: [], range: NSRange(location: 0, length: count), withTemplate: "") ?? self
    }
}

private extension Dictionary where Key == String, Value == Any {
    /// FIRTimestampがValueのままJSONSerializeするとエラーで死ぬので一度Dateの文字列に変換しておく
    func convertFirebaseTimestampToDate() -> [Key: Value] {
        var result = self
        forEach { (key: String, value: Any) in
            if let timestamp = value as? Timestamp {
                result[key] = timestamp.dateValue().toString(format: .iso8601DateFormat)
            }
        }
        return result
    }

    /// 特定のプレフィックスを持つDate文字列のValueをFIRTimestampに変換する
    func convertDateToFirebaseTimestamp() -> [Key: Value] {
        var result = self
        forEach { (key: String, value: Any) in
            if let dateString = value as? String,
                dateString.hasPrefix(.firebaseTimestampPrefix),
                let date = dateString.dropFribaseTemstampPrefix.toDate(format: .iso8601DateFormat) {
                result[key] = Timestamp(date: date)
            }
        }
        return result
    }
}
