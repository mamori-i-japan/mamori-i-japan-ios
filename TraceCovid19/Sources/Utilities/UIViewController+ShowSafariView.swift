//
//  UIViewController+ShowSafariView.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/05/14.
//

import UIKit
import SafariServices

extension UIViewController {
    func showSafariView(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.modalPresentationStyle = .overFullScreen
        present(safariVC, animated: true, completion: nil)
    }
}
