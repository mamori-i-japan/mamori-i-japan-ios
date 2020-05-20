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
        className
    }

    static var storyboardBundle: Bundle {
        Bundle(for: self)
    }

    private static var storyboard: UIStoryboard {
        UIStoryboard(name: storyboardName, bundle: storyboardBundle)
    }
}

extension StoryboardInstantiatable where Self: UIViewController {
    static func instantiate() -> Self {
        storyboard.instantiateInitialViewController() as? Self ?? { fatalError("InitialViewControllerを変換できない") }()
    }

    static func instantiate(identifier: String) -> Self {
        storyboard.instantiateViewController(withIdentifier: identifier) as? Self ?? { fatalError("\(identifier)をViewControllerに変換できない") }()
    }
}

extension UIViewController: StoryboardInstantiatable {}
