//
//  Tutorial2ViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/11.
//

import UIKit

final class Tutorial2ViewController: UIViewController, NavigationBarHiddenApplicapable, Tutorial3Accessable {
    @IBAction func tappedNextButton(_ sender: Any) {
        pushToTutorial3()
    }
}
