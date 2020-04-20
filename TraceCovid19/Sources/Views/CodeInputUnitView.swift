//
//  CodeInputUnitView.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/11.
//

import UIKit

final class CodeInputUnitView: UIView, NibInstantiatable {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var underBarView: UIView!

    var text: String {
        get {
            return label.text ?? ""
        }
        set {
            label.text = newValue
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    private func initialize() {
        guard let view = instantiate() else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(view)

        label.text = nil
    }

    func changeFocus(isCurrent: Bool) {
        if isCurrent {
            underBarView.backgroundColor = .highlightedColor
        } else {
            underBarView.backgroundColor = .normalColor
        }
    }
}

private extension UIColor {
    static var normalColor = { UIColor(hex: 0xE6E7EC) }()
    static var highlightedColor = { UIColor(hex: 0x007AFF) }()
}
