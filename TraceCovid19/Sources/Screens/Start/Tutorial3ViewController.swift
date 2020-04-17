//
//  Tutorial3ViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/11.
//

import UIKit

final class Tutorial3ViewController: UIViewController, NavigationBarHiddenApplicapable {
    @IBAction func tappedNextButton(_ sender: Any) {
        gotoAgreement1()
    }

    func gotoAgreement1() {
        navigationController?.pushViewController(Agreement1ViewController.instantiate(), animated: true)
    }
}
