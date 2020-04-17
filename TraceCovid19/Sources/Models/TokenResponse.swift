//
//  TokenResponse.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/09.
//

import Foundation

struct TokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}
