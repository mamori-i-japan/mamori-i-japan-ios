//
//  Agreement1ViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/11.
//

import UIKit

final class Agreement1ViewController: UIViewController, NavigationBarHiddenApplicapable, Agreement2Accessable {
    var profile: Profile!

    @IBAction func tappedNextButton(_ sender: Any) {
        pushToAgreement2(profile: profile)
    }
}
