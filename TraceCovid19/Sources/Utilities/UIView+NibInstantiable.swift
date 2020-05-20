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
    var nibName: String { className }
    var nibBundle: Bundle { Bundle(for: type(of: self)) }
    var nibOwner: Any? { self }
    var nibOptions: [UINib.OptionsKey: Any]? { nil }
    var instantiateIndex: Int { 0 }
}

extension NibInstantiatable where Self: UIView {
    func instantiate() -> UIView? {
        UINib(nibName: nibName, bundle: nibBundle).instantiate(withOwner: nibOwner, options: nibOptions)[instantiateIndex] as? UIView
    }
}

extension UITableView {
    func dequeue<T: NibInstantiatable & NSObject>(indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.className, for: indexPath) as? T else {
            fatalError("\(self)のDequeに失敗")
        }
        return cell
    }
}
