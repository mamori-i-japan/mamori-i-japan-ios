//
//  TraceDataUploadService.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/23.
//

import Foundation

final class TraceDataUploadService {
    private let traceDataUploadAPI: TraceDataUploadAPI
    private let coreData: CoreDataService

    init(traceDataUploadAPI: TraceDataUploadAPI, coreData: CoreDataService) {
        self.traceDataUploadAPI = traceDataUploadAPI
        self.coreData = coreData
    }

    enum UploadError: Error {
        case unauthorized
        case unknown(Error?)
    }

    func upload(completion: @escaping (Result<Void, UploadError>) -> Void) {
        let deepContactUsers = getDeepContactUsers()
        traceDataUploadAPI.upload(deepContactUsers: deepContactUsers) { result in
            switch result {
            case .success:
                // TODO: 成功したリストは削除したほうが良い？ずっととっておいて次回以降も含める？
                completion(.success(()))
            case .failure(.authzError):
                print("[TraceDataUploadService] authzError: \(result)")
                completion(.failure(.unauthorized))
            case .failure:
                // TODO: エラー
                print("[TraceDataUploadService] error: \(result)")
                completion(.failure(.unknown(NSError(domain: "unknown error", code: 0, userInfo: nil))))
            }
        }
    }

    private func getDeepContactUsers() -> [DeepContactUserUploadModel] {
        // TODO: 14日間分（0:00スタート）の自身のTempIDに切り替える
        return coreData.getDeepContactUsers().compactMap { DeepContactUserUploadModel(deepContactUser: $0.toDeepContactUser()) }
    }
}
