//
//  UIViewController+Instantiate.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/02.
//

import UIKit

 protocol StoryboardInstantiatable {
    static var storyboardName: String { get }
    static var storyboardBundle: Bundle { get }
}

extension StoryboardInstantiatable where Self: NSObject {
    static var storyboardName: String {
        return className
    }

    static var storyboardBundle: Bundle {
        return Bundle(for: self)
    }

    private static var storyboard: UIStoryboard {
        return UIStoryboard(name: storyboardName, bundle: storyboardBundle)
    }
}

extension StoryboardInstantiatable where Self: UIViewController {
    static func instantiate() -> Self {
        return storyboard.instantiateInitialViewController() as? Self ?? { fatalError("InitialViewControllerを変換できない") }()
    }

    static func instantiate(identifier: String) -> Self {
        return storyboard.instantiateViewController(withIdentifier: identifier) as? Self ?? { fatalError("\(identifier)をViewControllerに変換できない") }()
    }
}

extension UIViewController: StoryboardInstantiatable {}
