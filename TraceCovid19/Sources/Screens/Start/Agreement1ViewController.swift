//
//  Agreement1ViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/11.
//

import UIKit

final class Agreement1ViewController: UIViewController {
    @IBAction func tappedNextButton(_ sender: Any) {
        gotoAgreement2()
    }

    func gotoAgreement2() {
        navigationController?.pushViewController(Agreement2ViewController.instantiate(), animated: true)
    }
}
