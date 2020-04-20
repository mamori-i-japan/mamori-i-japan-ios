//
//  XibLocalizable.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/20.
//

import UIKit

protocol XIBLocalizable: UIView {
    var localizableBundle: Bundle { get }
    /// ローカライズファイル名(nilの場合は`Localizable`）
    var localizableFileName: String? { get }

    func localizedString(_ key: String) -> String
}

extension XIBLocalizable {
    var localizableBundle: Bundle {
        // 読み込むBundleを指定
        return Bundle(for: type(of: self))
    }
}

extension XIBLocalizable {
    var localizableFileName: String? {
        return nil
    }

    func localizedString(_ key: String) -> String {
        return NSLocalizedString(key, tableName: localizableFileName, bundle: localizableBundle, comment: "")
    }
}

// MARK: - 各種UIViewのサブクラスに適応

extension XIBLocalizable where Self: UILabel {
    func updateText(_ key: String) {
        text = localizedString(key)
    }

    func updateAttributedText(_ key: String, attributes: [NSAttributedString.Key: Any]?) {
        attributedText = NSAttributedString(string: localizedString(key), attributes: attributes)
    }

    /// テキストを取得後に、利用側でAttributeを装飾して適応する
    ///
    /// - Parameters:
    ///   - key: キー名
    ///   - customizeBlock: 入力はローカライズテキスト、出力は装飾後の文字列なクロージャ
    func updateAttributedText(_ key: String, customizeBlock: (_ text: String) -> NSAttributedString) {
        let text = localizedString(key)
        attributedText = customizeBlock(text)
    }
}

extension XIBLocalizable where Self: UIButton {
    func updateTitle(_ key: String, for state: UIControl.State) {
        setTitle(localizedString(key), for: state)
    }
}

extension XIBLocalizable where Self: UITextField {
    func updateText(_ key: String) {
        text = localizedString(key)
    }
    func updatePlaceholder(_ key: String) {
        placeholder = localizedString(key)
    }
}
