//
//  InputWorkViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/17.
//

import UIKit

final class InputWorkViewController: UIViewController, KeyboardCloseProtocol {
    @IBOutlet weak var workTextField: UITextField!
    @IBOutlet weak var nextButton: ActionButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        workTextField.delegate = self
        setupKeyboardClose()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        workTextField.becomeFirstResponder()
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
        gotoInputPhoneNumber()
    }

    func gotoInputPhoneNumber() {
        // TODO: 都道府県情報+職業の引き継ぎ
        navigationController?.pushViewController(InputPhoneNumberViewController.instantiate(), animated: true)
    }
}

extension InputWorkViewController: UITextFieldDelegate {
}
