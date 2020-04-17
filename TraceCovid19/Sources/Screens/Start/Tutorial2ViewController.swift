//
//  Tutorial2ViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/11.
//

import UIKit

final class Tutorial2ViewController: UIViewController, NavigationBarHiddenApplicapable {
    @IBAction func tappedNextButton(_ sender: Any) {
        gotoTutorial3()
    }

    func gotoTutorial3() {
        navigationController?.pushViewController(Tutorial3ViewController.instantiate(), animated: true)
    }
}
