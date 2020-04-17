//
//  Tutorial1ViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/09.
//

import UIKit

final class Tutorial1ViewController: UIViewController, NavigationBarHiddenApplicapable {
    @IBAction func tappedNextButton(_ sender: Any) {
        gotoTutorial2()
    }

    func gotoTutorial2() {
        navigationController?.pushViewController(Tutorial2ViewController.instantiate(), animated: true)
    }
}
