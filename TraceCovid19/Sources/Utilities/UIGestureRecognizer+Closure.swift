//
//  UIGestureRecognizer+Closure.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/09.
//

import UIKit

/// ジェスチャーをClosureパターンで書けるようにするためのラッパー
class GestureClosureWrapper<T: UIGestureRecognizer> {
    private let closure: (_ gesture: T) -> Void

    init(_ closure: @escaping (_ gesture: T) -> Void) {
        self.closure = closure
    }

    @objc
    func invoke(_ gesture: Any) {
        guard let gesture = gesture as? T else { return }
        closure(gesture)
    }
}

private let key = "_closureWrapper"

// MARK: - UITapGestureRecognizer

extension UITapGestureRecognizer: HasAssociatedObjects {
    private var closureWrapper: GestureClosureWrapper<UITapGestureRecognizer>? {
        get {
            return associatedObjects[key] as? GestureClosureWrapper
        }
        set {
            associatedObjects[key] = newValue
        }
    }
}

extension UITapGestureRecognizer {
    /// ClosureでAction定義をできるようにする拡張
    ///
    /// - Parameter closureWrapper:
    convenience init(closureWrapper: GestureClosureWrapper<UITapGestureRecognizer>) {
        // ジェスチャー実行時に処理を受けられるように、ラッパーを保持しておく
        self.init(target: closureWrapper, action: #selector(GestureClosureWrapper.invoke(_:)))
        self.closureWrapper = closureWrapper
    }
}

// MARK: - UIPanGestureRecognizer

extension UIPanGestureRecognizer: HasAssociatedObjects {
    private var closureWrapper: GestureClosureWrapper<UIPanGestureRecognizer>? {
        get {
            return associatedObjects[key] as? GestureClosureWrapper
        }
        set {
            associatedObjects[key] = newValue
        }
    }
}

extension UIPanGestureRecognizer {
    /// ClosureでAction定義をできるようにする拡張
    ///
    /// - Parameter closureWrapper:
    convenience init(closureWrapper: GestureClosureWrapper<UIPanGestureRecognizer>) {
        // ジェスチャー実行時に処理を受けられるように、ラッパーを保持しておく
        self.init(target: closureWrapper, action: #selector(GestureClosureWrapper.invoke(_:)))
        self.closureWrapper = closureWrapper
    }
}
