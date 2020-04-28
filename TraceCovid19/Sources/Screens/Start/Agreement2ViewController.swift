//
//  Agreement2ViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/11.
//

import UIKit
import NVActivityIndicatorView

final class Agreement2ViewController: UIViewController, NavigationBarHiddenApplicapable, NVActivityIndicatorViewable, PermissionSettingAccessable {
    var profile: Profile!

    @IBAction func tappedNextButton(_ sender: Any) {
        login()
    }

    func login() {
        // TODO:
    }
}
