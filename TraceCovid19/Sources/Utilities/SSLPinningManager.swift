//
//  SSLPinningManager.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/21.
//

import Foundation
import CommonCrypto

struct SSLPinningCondition {
    let host: String
    let hashes: [String]
    let expired: Date?
    let isIncludeSubDomain: Bool

    /// 初期化処理
    ///
    /// - Parameters:
    ///   - host: ホスト名 ex) www.decurret.com
    ///   - hashes: ハッシュ値の配列
    ///     ```
    ///     // CRTの取得
    ///     $ echo | openssl s_client -servername <HostName> -connect <HostName>:443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > certificate.crt
    ///     // ハッシュ値の取得
    ///     $ openssl x509 -in certificate.crt -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
    ///     // 有効期限の調べ方
    ///     $ echo | openssl s_client -servername <HostName> -connect <HostName>:443 | openssl x509 -noout -dates
    ///     ```
    ///   - expired: 有効期限(設定した場合、この期限を過ぎていたらチェックをスルーする)
    ///   - isIncludeSubDomain: サブドメインを含むかどうか。含まない場合はドメインと完全一致で判定する(default=false)
    init(host: String, hashes: [String], expired: Date? = nil, isIncludeSubDomain: Bool = false) {
        self.host = host
        self.hashes = hashes
        self.expired = expired
        self.isIncludeSubDomain = isIncludeSubDomain
    }

    /// 初期化処理
    ///
    /// - Parameters:
    ///   - host: ホスト名 ex) www.decurret.com
    ///   - hashes: ハッシュ値の配列
    ///     ```
    ///     // CRTの取得
    ///     $ echo | openssl s_client -servername <HostName> -connect <HostName>:443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > certificate.crt
    ///     // ハッシュ値の取得
    ///     $ openssl x509 -in certificate.crt -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
    ///     // 有効期限の調べ方
    ///     $ echo | openssl s_client -servername <HostName> -connect <HostName>:443 | openssl x509 -noout -dates
    ///     ```
    ///   - expiredUnixTime: 有効期限(設定した場合、この期限を過ぎていたらチェックをスルーする)
    ///   - isIncludeSubDomain: サブドメインを含むかどうか。含まない場合はドメインと完全一致で判定する(default=false)
    init(host: String, hashes: [String], expiredUnixTime: TimeInterval, isIncludeSubDomain: Bool = false) {
        self.host = host
        self.hashes = hashes
        self.expired = Date(timeIntervalSince1970: expiredUnixTime)
        self.isIncludeSubDomain = isIncludeSubDomain
    }
}

final class SSLPinningManager {
    private let conditions: [SSLPinningCondition]

    /// SSLPinnigを有効化するかどうか
    var isEnable = true

    init(conditions: [SSLPinningCondition]) {
        self.conditions = conditions
    }

    var hosts: [String] {
        return conditions.compactMap { $0.host }
    }

    /// SSLチャレンジ処理を実行する
    ///
    /// - Parameter challenge:
    /// - Returns:
    func sslCertificate(challenge: URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        guard isEnable, challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust else {
            // チャレンジ不要
            return (.performDefaultHandling, nil)
        }

        // 条件チェック
        guard let condition = sslPinningCondition(for: challenge.protectionSpace.host) else {
            // SSLPinning対象ではない
            return (.performDefaultHandling, nil)
        }

        if let serverTrust = challenge.protectionSpace.serverTrust {
            var secresult: SecTrustResultType = .unspecified
            if SecTrustEvaluate(serverTrust, &secresult) == errSecSuccess {
                if isValid(trust: serverTrust, condition: condition) {
                    return (.useCredential, URLCredential(trust: serverTrust))
                }
            }
        }

        // Pinning failed
        return (.cancelAuthenticationChallenge, nil)
    }

    func isValid(trust: SecTrust, condition: SSLPinningCondition) -> Bool {
        // index=0が子要素
        guard let serverCertificate = SecTrustGetCertificateAtIndex(trust, 0),
            let serverPublicKey = getPublicKey(certificate: serverCertificate),
            let serverPublicKeyData: NSData = SecKeyCopyExternalRepresentation(serverPublicKey, nil) else { return false }

        // key pinning
        let keyHash = sha256AndBase64Encode(data: serverPublicKeyData as Data)
        if condition.hashes.contains(keyHash) {
            print("[SSLPinningManager] SSL Challenge Success")
            return true
        }
        return false
    }

    /// 証明書から公開鍵を取り出す
    ///
    /// - Parameter certificate:
    /// - Returns:
    private func getPublicKey(certificate: SecCertificate) -> SecKey? {
        if #available(iOS 12.0, *) {
            return SecCertificateCopyKey(certificate)
        } else if #available(iOS 10.3, *) {
            return SecCertificateCopyPublicKey(certificate)
        } else {
            var possibleTrust: SecTrust?
            SecTrustCreateWithCertificates(certificate, SecPolicyCreateBasicX509(), &possibleTrust)
            guard let trust = possibleTrust else { return nil }
            var result: SecTrustResultType = .unspecified
            SecTrustEvaluate(trust, &result)
            return SecTrustCopyPublicKey(trust)
        }
    }

    func sslPinningCondition(for host: String) -> SSLPinningCondition? {
        // NOTE: ひとまず作り込まずに、該当した先頭の条件を拾う
        return conditions.first { checkHost($0, host: host) && checkExpiration($0) }
    }

    private func checkHost(_ config: SSLPinningCondition, host: String) -> Bool {
        // ホスト
        if config.isIncludeSubDomain {
            // サブドメインを含む場合は、完全一致または*.hostでサフィックスを見るで簡単にチェックする
            return config.host == host || host.hasSuffix("." + config.host)
        } else {
            return config.host == host
        }
    }

    private func checkExpiration(_ config: SSLPinningCondition, now: Date = Date()) -> Bool {
        if let date = config.expired, now > date {
            // 有効期限が設定されていて、現在時刻がそれをすぎていたらfalseとして条件を無視する
            return false
        }
        return true
    }
}

private extension SSLPinningManager {
    var rsa2048Asn1Header: [UInt8] {
        return [
            0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
            0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
        ]
    }

    func sha256AndBase64Encode(data: Data) -> String {
        var keyWithHeader = Data(rsa2048Asn1Header)
        keyWithHeader.append(data)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))

        _ = hash.withUnsafeMutableBytes { hashBytes -> UInt8 in
            keyWithHeader.withUnsafeBytes { dataBytes -> UInt8 in
                if let dataBytesAddress = dataBytes.baseAddress, let hashBytesBindMemory = hashBytes.bindMemory(to: UInt8.self).baseAddress {
                    CC_SHA256(dataBytesAddress, CC_LONG(keyWithHeader.count), hashBytesBindMemory)
                }
                return 0
            }
        }

        return Data(hash).base64EncodedString()
    }
}
