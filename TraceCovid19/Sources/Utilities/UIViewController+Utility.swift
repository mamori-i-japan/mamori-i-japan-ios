//
//  UIViewController+Utility.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/05/07.
//

import UIKit

extension UIViewController {
    var topBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height +
            (navigationController?.navigationBar.bounds.height ?? 0.0)
    }
}
