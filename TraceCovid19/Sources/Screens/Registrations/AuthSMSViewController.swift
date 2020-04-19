//
//  AuthSMSViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/09.
//

import UIKit
import NVActivityIndicatorView
import FirebaseAuth

final class AuthSMSViewController: UIViewController, KeyboardCloseProtocol, NVActivityIndicatorViewable {
    @IBOutlet weak var codeInputView: CodeInputView!
    @IBOutlet weak var errorLabel: UILabel!

    var verificationID: String!
    var profile: Profile!

    var keychain: KeychainService!
    var loginService: LoginService!

    private let smsLength = 6

    override func viewDidLoad() {
        super.viewDidLoad()

        setupKeyboardClose()
        codeInputView.setup(length: smsLength, delegate: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        clearInput()
        setError(text: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        codeInputView.becomeFirstResponder()
    }

    @IBAction func tappedChangePhoneNumber(_ sender: Any) {
        guard let inputPhoneNumberViewController = navigationController?.viewControllers.first(
            where: { vc -> Bool in
                vc is InputPhoneNumberViewController
            }
        ) as? InputPhoneNumberViewController else { return }

        inputPhoneNumberViewController.clearText()
        navigationController?.popToViewController(inputPhoneNumberViewController, animated: true)
    }

    private func authSMS(code: String) {
        startAnimating(type: .circleStrokeSpin)
        closeKeyboard()

        loginService.signIn(verificationID: verificationID, code: code, profile: profile) { [weak self] result in
            self?.stopAnimating()

            switch result {
            case .success:
                self?.gotoBLEPermissionSetting()
            case .failure(let error):
                // TODO: エラーのUX
                self?.setError(text: error.localizedDescription)
                self?.clearInput()
                self?.codeInputView.becomeFirstResponder()
            }
        }
    }

    private func clearInput() {
        codeInputView.text = ""
    }

    private func setError(text: String?) {
        errorLabel.text = text
        if errorLabel.text == nil || errorLabel.text!.isEmpty {
            errorLabel.isHidden = true
        } else {
            errorLabel.isHidden = false
        }
    }

    func gotoBLEPermissionSetting() {
        navigationController?.pushViewController(BLEPermissionSettingViewController.instantiate(), animated: true)
    }
}

extension AuthSMSViewController: CodeInputViewDelegate {
    func didInput(code: String) {
        authSMS(code: code)
    }
}
