//
//  Profile.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/19.
//

import Foundation

struct Profile: DictionaryEncodable, DictionaryDecodable {
    private(set) var prefecture: Int?
    private(set) var organization: String?

    init(prefecture: PrefectureModel?, organization: String?) {
        self.prefecture = prefecture?.index
        self.organization = isValidOrganization(organization: organization)
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

    static var ignoreDecodeKeys: [String] {
        // 組織コードはread-onlyなためリクエストに含めないためにエンコード対象外とする
        return ["organization"]
    }
}

extension Profile {
    static var empty: Profile {
        .init(prefecture: nil, organization: nil)
    }
}

private func isValidOrganization(organization: String?) -> String? {
    if let organization = organization, !organization.isEmpty {
        // 空文字は省く
        return organization
    } else {
        return nil
    }
}
