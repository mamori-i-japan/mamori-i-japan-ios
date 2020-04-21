//
//  SSLPinningManager+Alamofire.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/21.
//

import Foundation
import Alamofire

extension SSLPinningManager: ServerTrustEvaluating {
    func evaluate(_ trust: SecTrust, forHost host: String) throws {
        guard isEnable, let condition = sslPinningCondition(for: host) else {
            // SSLPinning対象ではないのでスルー
            return
        }

        guard isValid(trust: trust, condition: condition) else {
            throw NSError(domain: "pinning failed", code: 0, userInfo: nil)
        }
    }
}
