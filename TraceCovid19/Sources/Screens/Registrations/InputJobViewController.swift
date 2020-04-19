//
//  InputJobViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/17.
//

import UIKit
import NVActivityIndicatorView

final class InputJobViewController: UIViewController, ProfileChangeable, NVActivityIndicatorViewable, KeyboardCloseProtocol {
    @IBOutlet weak var jobTextField: UITextField!
    @IBOutlet weak var nextButton: ActionButton!

    var profileService: ProfileService!

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
            gotoInputPhoneNumber(profile: Profile(prefecture: prefecture, job: jobTextField.text))
        case .change(var profile):
            requestProfile(profile: profile.update(job: jobTextField.text))
        case .none:
            break
        }
    }

    func gotoInputPhoneNumber(profile: Profile) {
        let vc = InputPhoneNumberViewController.instantiate()
        vc.profile = profile
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension InputJobViewController: UITextFieldDelegate {
}
