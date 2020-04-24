//
//  Agreement2ViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/11.
//

import UIKit

final class Agreement2ViewController: UIViewController, NavigationBarHiddenApplicapable {
    @IBAction func tappedNextButton(_ sender: Any) {
        gotoInputPrefecture()
    }

    func gotoInputPrefecture() {
        let vc = InputPrefectureViewController.instantiate()
        vc.flow = .start
        navigationController?.pushViewController(vc, animated: true)
    }
}
