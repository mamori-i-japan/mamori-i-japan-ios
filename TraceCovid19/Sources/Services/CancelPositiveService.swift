//
//  CancelPositiveService.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/05/18.
//

import Foundation

final class CancelPositiveService {
    private let cancelPositiveAPI: CancelPositiveAPI
    private let keychainService: KeychainService!

    init(cancelPositiveAPI: CancelPositiveAPI, keychainService: KeychainService) {
        self.cancelPositiveAPI = cancelPositiveAPI
        self.keychainService = keychainService
    }

    enum CancelError: Error {
        case auth
        case network
        case unknown(Error?)
    }

    func cancel(completion: @escaping (Result<Void, CancelError>) -> Void) {
        let randomIDs = keychainService.randomIDs
        cancelPositiveAPI.cancelPositive(randomIDs: randomIDs) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(.authzError):
                print("[CancelPositiveService] authzError: \(result)")
                completion(.failure(.auth))
            case .failure(.network):
                print("[CancelPositiveService] network error: \(result)")
                completion(.failure(.network))
            case .failure:
                print("[CancelPositiveService] error: \(result)")
                completion(.failure(.unknown(NSError(domain: "unknown error", code: 0, userInfo: nil))))
            }
        }
    }
}
