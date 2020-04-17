//
//  Agreement2ViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/11.
//

import UIKit

final class Agreement2ViewController: UIViewController {
    @IBAction func tappedNextButton(_ sender: Any) {
        gotoInputPrefecture()
    }

    func gotoInputPrefecture() {
        navigationController?.pushViewController(InputPrefectureViewController.instantiate(), animated: true)
    }
}
