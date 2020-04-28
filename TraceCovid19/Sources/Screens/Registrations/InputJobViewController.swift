//
//  InputJobViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/17.
//

import UIKit
import NVActivityIndicatorView

// TODO: 廃止予定

final class InputJobViewController: UIViewController, ProfileChangeable, NVActivityIndicatorViewable, KeyboardCloseProtocol, InputPhoneNumberAccessable {
    @IBOutlet weak var jobTextField: UITextField!
    @IBOutlet weak var nextButton: ActionButton!

    var profileService: ProfileService!
    var loginService: LoginService!

    enum Flow {
        case start(PrefectureModel)
        case change(Profile)
    }

    // TODO: 値渡しのやり方考える
    var flow: Flow!

    override func viewDidLoad() {
        super.viewDidLoad()

        if case .change(let profile) = flow {
            // 変更フローの場合はテキストに設定
            jobTextField.text = profile.job
            nextButton.setTitle("更新する", for: .normal)
        }

        jobTextField.delegate = self
        setupKeyboardClose()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        jobTextField.becomeFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        closeKeyboard()
        return false
    }

    @objc
    func closeKeyboard() {
        view.endEditing(true)
    }

    @IBAction func tappedNextButton(_ sender: Any) {
        switch flow {
        case .start(let prefecture):
            pushToInputPhoneNumber(profile: Profile(prefecture: prefecture, job: jobTextField.text))
        case .change(var profile):
            requestProfile(profile: profile.update(job: jobTextField.text))
        case .none:
            break
        }
    }

    func forceLogout() {
        loginService.logout()
        backToSplash()
    }
}

extension InputJobViewController: UITextFieldDelegate {
}
