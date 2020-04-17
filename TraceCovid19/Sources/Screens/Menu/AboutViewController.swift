//
//  AboutViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/09.
//

import UIKit

final class AboutViewController: UIViewController {
    @IBOutlet weak var appVersionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        appVersionLabel.text = "アプリのバージョン\(AppVersion.currentAppVersion.versionString)"
    }
}
