//
//  CodeInputView.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/11.
//

import UIKit

protocol CodeInputViewDelegate: class {
    func didInput(code: String)
}

final class CodeInputView: UIView {
    private var codeInputUnitViews: [CodeInputUnitView] = []
    private var stackView: UIStackView!
    private let textField = UITextField()

    private var length: Int!
    private weak var delegate: CodeInputViewDelegate?

    var text: String {
        get {
            return textField.text ?? ""
        }
        set {
            textField.text = newValue
            codeInputUnitViews.forEach { $0.text = "" }
            for (index, code) in newValue.enumerated() where index < codeInputUnitViews.count {
                codeInputUnitViews[index].text = String(code)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        initialize()
    }

    func initialize() {
        stackView = UIStackView(frame: bounds)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8.0

        addSubview(stackView)

        // テキストフィールドの実態は隠す
        textField.alpha = 0.0
        textField.keyboardType = .numberPad
        textField.delegate = self
        addSubview(textField)

        let gesture = UITapGestureRecognizer(
            closureWrapper: .init { [weak self] _ in
                self?.becomeFirstResponder()
            }
        )
        addGestureRecognizer(gesture)
    }

    func setup(length: Int, delegate: CodeInputViewDelegate) {
        self.length = length
        self.delegate = delegate

        for _ in 0..<length {
            let unitView = CodeInputUnitView(frame: CGRect(x: 0, y: 0, width: 0, height: bounds.height))
            stackView.addArrangedSubview(unitView)
            codeInputUnitViews.append(unitView)
        }
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
}

extension CodeInputView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let currentString = textField.text, let _range = Range(range, in: currentString) {
            let newString = currentString.replacingCharacters(in: _range, with: string)
            if newString.count == length {
                delegate?.didInput(code: newString)
            }
            // textfieldだけでなく、それぞれのコード画面単位に反映させるためtextに設定する
            self.text = newString
            return false
        }
        return true
    }
}
