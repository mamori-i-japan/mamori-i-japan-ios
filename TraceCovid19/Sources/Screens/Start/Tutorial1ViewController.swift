//
//  Tutorial1ViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/09.
//

import UIKit

final class Tutorial1ViewController: UIViewController, NavigationBarHiddenApplicapable, Tutorial2Accessable {
    @IBAction func tappedNextButton(_ sender: Any) {
        pushToTutorial2()
    }
}
