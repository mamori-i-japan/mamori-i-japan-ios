//
//  Profile.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/19.
//

import Foundation

struct Profile: DictionaryEncodable, DictionaryDecodable {
    private(set) var prefecture: Int?
    private(set) var job: String?

    init(prefecture: PrefectureModel?, job: String?) {
        self.prefecture = prefecture?.index
        self.job = isValidJob(job: job)
    }

    @discardableResult
    mutating func update(prefecture: PrefectureModel) -> Profile {
        self.prefecture = prefecture.index
        return self
    }

    @discardableResult
    mutating func update(job: String?) -> Profile {
        self.job = isValidJob(job: job)
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
}

extension Profile {
    static var empty: Profile {
        .init(prefecture: nil, job: nil)
    }
}

private func isValidJob(job: String?) -> String? {
    if let job = job, !job.isEmpty {
        // 空文字は省く
        return job
    } else {
        return nil
    }
}
