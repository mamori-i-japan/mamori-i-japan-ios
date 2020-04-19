//
//  InputJobViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/17.
//

import UIKit

final class InputJobViewController: UIViewController, KeyboardCloseProtocol {
    @IBOutlet weak var jobTextField: UITextField!
    @IBOutlet weak var nextButton: ActionButton!

    // TODO: 値渡しのやり方考える
    var prefecture: PrefectureModel!

    override func viewDidLoad() {
        super.viewDidLoad()

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
        let profile = Profile(prefecture: prefecture, job: jobTextField.text)
        gotoInputPhoneNumber(profile: profile)
    }

    func gotoInputPhoneNumber(profile: Profile) {
        let vc = InputPhoneNumberViewController.instantiate()
        vc.profile = profile
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension InputJobViewController: UITextFieldDelegate {
}
