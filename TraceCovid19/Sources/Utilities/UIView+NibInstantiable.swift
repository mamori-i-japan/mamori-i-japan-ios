//
//  UIView+NibInstantiable.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/11.
//

import UIKit

protocol NibInstantiatable {
    var nibName: String { get }
    var nibBundle: Bundle { get }
    var nibOwner: Any? { get }
    var nibOptions: [UINib.OptionsKey: Any]? { get }
    var instantiateIndex: Int { get }
}

extension NibInstantiatable where Self: NSObject {
    var nibName: String { return className }
    var nibBundle: Bundle { return Bundle(for: type(of: self)) }
    var nibOwner: Any? { return self }
    var nibOptions: [UINib.OptionsKey: Any]? { return nil }
    var instantiateIndex: Int { return 0 }
}

extension NibInstantiatable where Self: UIView {
    func instantiate() -> UIView? {
        return UINib(nibName: nibName, bundle: nibBundle).instantiate(withOwner: nibOwner, options: nibOptions)[instantiateIndex] as? UIView
    }
}
