//
//  TraceDataUploadCompleteViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/30.
//

import UIKit

final class TraceDataUploadCompleteViewController: UIViewController, NavigationBarHiddenApplicapable {
    override func viewDidLoad() {
        super.viewDidLoad()

        // 戻るボタンを隠す
        let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.leftBarButtonItem = backButton
    }

    @IBAction func tappedBackToHomeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
