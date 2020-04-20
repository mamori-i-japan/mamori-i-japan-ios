//
//  BaseLabel.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/20.
//

import UIKit

@IBDesignable
class BaseLabel: UILabel, XIBLocalizable, LabelUtilityProtocol {
    @IBInspectable var textLocalizedKey: String = "" {
        didSet {
            // Attributeの使用を考慮し、AttributedTextベースで適応する
            updateAttributedText(textLocalizedKey, attributes: attributes)
        }
    }

    @IBInspectable var spacing: CGFloat {
        get {
            return paragraphStyle?.lineSpacing ?? 0.0
        }
        set {
            setParagraph(newValue, for: \.lineSpacing)
        }
    }
}
