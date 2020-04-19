//
//  PrefectureModel.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/11.
//

import Foundation

private let errorIndex = 999

enum PrefectureModel: String, CaseIterable {
    case hokkaido = "北海道"
    case aomori = "青森県"
    case iwate = "岩手県"
    case miyagi = "宮城県"
    case akita = "秋田県"
    case yamagata = "山形県"
    case fukushima = "福島県"
    case ibaragi = "茨城県"
    case tochigi = "栃木県"
    case gunma = "群馬県"
    case saitama = "埼玉県"
    case chiba = "千葉県"
    case tokyo = "東京都"
    case kanagawa = "神奈川県"
    case niigata = "新潟県"
    case toyama = "富山県"
    case ishikawa = "石川県"
    case fukui = "福井県"
    case yamanashi = "山梨県"
    case nagano = "長野県"
    case gifu = "岐阜県"
    case shizuoka = "静岡県"
    case aichi = "愛知県"
    case mie = "三重県"
    case shiga = "滋賀県"
    case kyoto = "京都府"
    case osaka = "大阪府"
    case hyogo = "兵庫県"
    case nara = "奈良県"
    case wakayama = "和歌山県"
    case tottori = "鳥取県"
    case shimane = "島根県"
    case okayama = "岡山県"
    case hiroshima = "広島県"
    case yamaguchi = "山口県"
    case tokushima = "徳島県"
    case kagawa = "香川県"
    case ehime = "愛媛県"
    case kochi = "高知県"
    case fukuoka = "福岡県"
    case saga = "佐賀県"
    case nagasaki = "長崎県"
    case kumamoto = "熊本県"
    case oita = "大分県"
    case miyazaki = "宮崎県"
    case kagoshima = "鹿児島県"
    case okinawa = "沖縄県"

    var rawIndex: Int {
        guard let rawIndex = type(of: self).allCases.firstIndex(of: self) else {
            return errorIndex
        }
        return rawIndex
    }

    var index: Int {
        return rawIndex == errorIndex ? errorIndex : rawIndex + 1 // 0始まりになってしまうので、B/Eに投げる場合などは1を加算（異常系は固定）
    }

    static var rawValues: [String] {
        return allCases.compactMap { $0.rawValue }
    }

    init?(index: Int?) {
        guard let index = index else { return nil }
        /// 1~47を想定
        let allCases = type(of: self).allCases
        let rawIndex = index - 1
        guard rawIndex < allCases.count else {
            return nil
        }
        self = allCases[rawIndex]
    }
}
