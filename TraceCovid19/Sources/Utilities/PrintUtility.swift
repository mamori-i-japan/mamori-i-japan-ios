//
//  PrintUtility.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/02.
//

import UIKit
import os.log

final class PrintUtility {
    static let shared = PrintUtility()

    var isEnable: Bool
    var isHidden: Bool = false {
        didSet {
            window.isHidden = isHidden
        }
    }

    private init() {
        #if DEBUG
        isEnable = true
        #else
        isEnable = false
        #endif
    }

    var isUserInteractionEnabled = false {
        didSet {
            window.isUserInteractionEnabled = isUserInteractionEnabled
            isUserInteractionDisableButton.isHidden = !isUserInteractionEnabled
        }
    }
    var isAutoScrolling = true

    private lazy var window = UIWindow(frame: UIScreen.main.bounds)
    private lazy var textView = UITextView(frame: UIScreen.main.bounds)
    private lazy var isUserInteractionDisableButton = UIButton()
    private var isSetup = false

    private func setup() {
        guard !isSetup else { return }
        window.isUserInteractionEnabled = isUserInteractionEnabled
        window.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        window.makeKeyAndVisible()

        textView.isEditable = false

        window.addSubview(textView)

        textView.frame.size.height -= (textView.safeAreaInsets.top + textView.safeAreaInsets.bottom)
        textView.frame.origin.y = textView.safeAreaInsets.top
        textView.bounds = textView.frame.insetBy(dx: 16.0, dy: 16.0)
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.black.cgColor

        // 操作救済ボタン
        let baseButtonView = UIView(frame: CGRect(x: 0, y: 0, width: window.bounds.width, height: 44.0 + window.safeAreaInsets.top))
        isUserInteractionDisableButton.frame = CGRect(x: 0, y: window.safeAreaInsets.top, width: window.bounds.width, height: 44.0)
        isUserInteractionDisableButton.setTitle("ログ制御無効化", for: .normal)
        isUserInteractionDisableButton.setTitleColor(.red, for: .normal)
        isUserInteractionDisableButton.setBackgroundImage(UIColor.black.toImage, for: .normal)
        isUserInteractionDisableButton.addTarget(self, action: #selector(disableInteraction), for: .touchUpInside)
        baseButtonView.addSubview(isUserInteractionDisableButton)
        window.addSubview(baseButtonView)
        isUserInteractionDisableButton.isHidden = true

        window.alpha = 0.8
        window.isHidden = isHidden

        isSetup = true
    }

    @objc
    func disableInteraction() {
        isUserInteractionEnabled = false
        isUserInteractionDisableButton.isHidden = true
    }

    fileprivate func logging(_ log: String) {
        DispatchQueue.main.async {
            self._logging(log: log)
        }
    }

    private func _logging(log: String) {
        setup()

        let appendLog = NSAttributedString(string: log)
        if let attributedText = textView.attributedText, !attributedText.string.isEmpty {
            let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
            let separator = NSMutableAttributedString(string: "\n--[\(Date().toString(format: "yyyy/MM/dd HH:mm:ss.SSS"))]--\n")
            separator.addAttribute(.foregroundColor, value: UIColor.red, range: NSRange(location: 0, length: separator.length))
            mutableAttributedText.append(separator)
            mutableAttributedText.append(appendLog)
            textView.attributedText = mutableAttributedText
        } else {
            textView.attributedText = appendLog
        }

        if isAutoScrolling {
            // 下までスクロール
            let bottomOffset = CGPoint(x: textView.contentOffset.x, y: max(-textView.contentInset.top, textView.contentSize.height - textView.bounds.height + textView.contentInset.bottom))
            textView.setContentOffset(bottomOffset, animated: true)
        }
    }
}

func print(_ item: Any) {
    if PrintUtility.shared.isEnable {
        Swift.print(item)
        PrintUtility.shared.logging(String(describing: item))
    }
}

func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    if PrintUtility.shared.isEnable {
        Swift.print(items, separator: separator, terminator: terminator)
    }
}

func debugPrint(_ item: Any) {
    if PrintUtility.shared.isEnable {
        Swift.debugPrint(item)
        PrintUtility.shared.logging(String(describing: item))
    }
}

func debugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    if PrintUtility.shared.isEnable {
        Swift.debugPrint(items, separator: separator, terminator: terminator)
    }
}

func log(_ vars: Any..., filename: String = #file, line: Int = #line, funcname: String = #function) {
    let isMain = Thread.current.isMainThread
    let file = filename.components(separatedBy: "/").last ?? ""
    let p = "\(isMain ? "M" : "?")#\(line) \(funcname)|" + vars.map { v in "\(v)" }.joined()
    let oslog = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: file)
    os_log("%{public}@", log: oslog, p)
    // NOTE: デバッグメニューのログでもみれるようにprintにも流す
    print(p)
}
