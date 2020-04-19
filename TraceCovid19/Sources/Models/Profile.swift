//
//  Profile.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/19.
//

import Foundation

struct Profile: DictionaryEncodable, DictionaryDecodable {
    let prefecture: Int
    let job: String?

    init(prefecture: PrefectureModel, job: String?) {
        self.prefecture = prefecture.index
        if let job = job, !job.isEmpty {
            // 空文字は省く
            self.job = job
        } else {
            self.job = nil
        }
    }
}
