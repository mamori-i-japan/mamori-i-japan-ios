//
//  LabelUtilityProtocol.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/20.
//

import UIKit

protocol LabelUtilityProtocol: class, HasAssociatedObjects {
    var attributes: [NSAttributedString.Key: Any] { get set }

    var paragraphStyle: NSMutableParagraphStyle? { get }
    func setParagraph<T>(_ value: T, for keyPath: ReferenceWritableKeyPath<NSMutableParagraphStyle, T>)
}

private let attributeKey = "_attributeKey"
extension LabelUtilityProtocol where Self: UILabel {
    var attributes: [NSAttributedString.Key: Any] {
        get {
            return associatedObjects[attributeKey] as? [NSAttributedString.Key: Any] ?? [:]
        }
        set {
            associatedObjects[attributeKey] = newValue
            adaptAttributes(attributes: attributes)
        }
    }

    private func adaptAttributes(attributes: [NSAttributedString.Key: Any]?) {
        let string = attributedText?.string ?? text ?? ""
        attributedText = NSAttributedString(string: string, attributes: attributes)
    }
}

extension LabelUtilityProtocol where Self: UILabel {
    var paragraphStyle: NSMutableParagraphStyle? {
        return attributes[.paragraphStyle] as? NSMutableParagraphStyle
    }

    func setParagraph<T>(_ value: T, for keyPath: ReferenceWritableKeyPath<NSMutableParagraphStyle, T>) {
        let style = paragraphStyle ?? makeDefaultParagraphStyle()
        style[keyPath: keyPath] = value
        attributes[.paragraphStyle] = style
    }

    private func makeDefaultParagraphStyle() -> NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        paragraphStyle.lineBreakMode = lineBreakMode
        return paragraphStyle
    }
}
