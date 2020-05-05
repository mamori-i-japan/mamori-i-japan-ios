//
//  Tutorial1ViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/09.
//

import UIKit
import SafariServices

final class Tutorial1ViewController: UIViewController, NavigationBarHiddenApplicapable, Agreement1Accessable {
    @IBAction func tappedNextButton(_ sender: Any) {
        pushToAgreement1()
    }

    @IBAction func tappedHelpButton(_ sender: Any) {
        // TODO: URL
        let safariVC = SFSafariViewController(url: URL(string: "https://www.yahoo.co.jp")!)
        safariVC.modalPresentationStyle = .overFullScreen
        present(safariVC, animated: true, completion: nil)
    }
}
