//
//  Tutorial3ViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/11.
//

import UIKit

final class Tutorial3ViewController: UIViewController, NavigationBarHiddenApplicapable, InputPrefectureAccessable {
    @IBAction func tappedNextButton(_ sender: Any) {
        pushToInputPrefecture()
    }
}
