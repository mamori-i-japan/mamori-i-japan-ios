//
//  Tutorial3ViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/11.
//

import UIKit

// MARK: PH1では使用しない

final class Tutorial3ViewController: UIViewController, NavigationBarHiddenApplicapable, InputPrefectureAccessable {
    @IBAction func tappedNextButton(_ sender: Any) {
        pushToInputPrefecture()
    }
}
