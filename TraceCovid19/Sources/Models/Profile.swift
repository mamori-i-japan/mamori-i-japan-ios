//
//  Profile.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/19.
//

import Foundation

struct Profile: DictionaryEncodable, DictionaryDecodable {
    private(set) var prefecture: Int?
    private(set) var organizationCode: String?

    init(prefecture: PrefectureModel?, organizationCode: String?) {
        self.prefecture = prefecture?.index
        self.organizationCode = isValidOrganization(organizationCode: organizationCode)
    }

    @discardableResult
    mutating func update(prefecture: PrefectureModel) -> Profile {
        self.prefecture = prefecture.index
        return self
    }

    static var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.iso8601DateFormatter)
        return decoder
    }()

    var jsonEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom { date, encoder in
            // NOTE: Date型をFirebaseのtimestampとして扱うためにプレフィックスをつけた文字列として識別をわける
            var container = encoder.singleValueContainer()
            try container.encode("FIRTimestamp:\(DateFormatter.iso8601DateFormatter.string(from: date))")
        }
        return encoder
    }

    static var ignoreEncodeKeys: [String] {
        // 組織コードはread-onlyなためリクエストに含めないためにエンコード対象外とする
        return ["organizationCode"]
    }
}

extension Profile {
    static var empty: Profile {
        .init(prefecture: nil, organizationCode: nil)
    }
}

private func isValidOrganization(organizationCode: String?) -> String? {
    if let organizationCode = organizationCode, !organizationCode.isEmpty {
        // 空文字は省く
        return organizationCode
    } else {
        return nil
    }
}
