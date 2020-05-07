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
    private let profileAPI: ProfileAPI

    init(firestore: Lazy<Firestore>, auth: Lazy<Auth>, profileAPI: ProfileAPI) {
        self.firestore = firestore
        self.auth = auth
        self.profileAPI = profileAPI
    }

    enum ProfileSetError: Error {
        case network
        case auth
        case unknown(Error?)
    }

    enum ProfileGetError: Error {
        case network
        case auth
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
                    case .unauthenticated:
                        // TODO: 認証エラーはこのコード？
                        print("[ProfileService] unauthenticated error")
                        completion(.failure(.auth))
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
                    case .unauthenticated:
                        // TODO: 認証エラーはこのコード？
                        print("[ProfileService] unauthenticated error")
                        completion(.failure(.auth))
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

    enum OrganizationUpdateError: Error {
        case notMatchCode
        case network
        case auth
        case unknown(Error?)
    }

    func update(profile: Profile, organization: String?, completion: @escaping (Result<Void, OrganizationUpdateError>) -> Void) {
        profileAPI.patch(profile: profile, organization: organization) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(.authzError):
                completion(.failure(.auth))
            case .failure(.statusCodeError(400, let data, _))
                where data != nil
                    && (try? JSONDecoder().decode(ErrorResponse.self, from: data!))?.message == "Organization code does not match any existing organization":
                // TODO: エラー形式が確定なのか不明なため、ひとまず共通部分で作り込まずにサービスのハンドリングとしてデコードする
                // NOTE: 判定ができないため、無理やりエラーメッセージで行う
                completion(.failure(.notMatchCode))
            case .failure(.error(detail: let error)),
                 .failure(.statusCodeError(_, _, let error)):
                // TODO: エラーハンドリング
                print("[ProfileService] unknown error: \(error?.localizedDescription ?? "nil")")
                completion(.failure(.unknown(error)))
            }
        }
    }

    enum OrganizationCodeDeleteError: Error {
        case network
        case auth
        case unknown(Error?)
    }

    func delete(randomIDs: [String], completion: @escaping (Result<Void, OrganizationCodeDeleteError>) -> Void) {
        profileAPI.deleteOrganizationCode(randomIDs: randomIDs) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(.authzError):
                completion(.failure(.auth))
            case .failure(.error(detail: let error)),
                 .failure(.statusCodeError(_, _, let error)):
                // TODO: エラーハンドリング
                print("[ProfileService] unknown error: \(error?.localizedDescription ?? "nil")")
                completion(.failure(.unknown(error)))
            }
        }
    }
}
