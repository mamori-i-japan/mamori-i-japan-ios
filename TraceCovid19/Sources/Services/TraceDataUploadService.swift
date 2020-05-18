//
//  TraceDataUploadService.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/23.
//

import Foundation

final class TraceDataUploadService {
    private let traceDataUploadAPI: TraceDataUploadAPI
    private let tempIdService: TempIdService

    init(traceDataUploadAPI: TraceDataUploadAPI, tempIdService: TempIdService) {
        self.traceDataUploadAPI = traceDataUploadAPI
        self.tempIdService = tempIdService
    }

    enum UploadError: Error {
        case auth
        case network
        case unknown(Error?)
    }

    func upload(healthCenterToken: String, completion: @escaping (Result<Void, UploadError>) -> Void) {
        let tempUserIds = tempIdService.getTempIdsForTwoWeeks()
        traceDataUploadAPI.upload(tempUserIds: tempUserIds, healthCenterToken: healthCenterToken) { result in
            switch result {
            case .success:
                // TODO: 成功したリストは削除したほうが良い？ずっととっておいて次回以降も含める？
                completion(.success(()))
            case .failure(.authzError):
                print("[TraceDataUploadService] authzError: \(result)")
                completion(.failure(.auth))
            case .failure(.network):
                print("[TraceDataUploadService] network error: \(result)")
                completion(.failure(.network))
            case .failure:
                print("[TraceDataUploadService] error: \(result)")
                completion(.failure(.unknown(NSError(domain: "unknown error", code: 0, userInfo: nil))))
            }
        }
    }
}
