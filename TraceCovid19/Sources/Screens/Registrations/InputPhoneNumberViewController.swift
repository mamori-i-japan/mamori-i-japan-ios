//
//  InputPhoneNumberViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/09.
//

import UIKit
import NVActivityIndicatorView
import FirebaseAuth

final class InputPhoneNumberViewController: UIViewController, KeyboardCloseProtocol, NVActivityIndicatorViewable {
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var nextButton: ActionButton!

    var smsService: SMSService!

    // TODO: 画面渡しのやり方
    var profile: Profile!

    private var observers = [NSKeyValueObservation]()
    private var isRequesting = false

    override func viewDidLoad() {
        super.viewDidLoad()

        phoneNumberTextField.delegate = self
        setupKeyboardClose()
        setupKVO()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !isRequesting {
            // リクエスト中でなければキーボード表示
            phoneNumberTextField.becomeFirstResponder()
        }
    }

    @objc
    func closeKeyboard() {
        view.endEditing(true)
    }

    @IBAction func tappedNextButton(_ sender: Any) {
        sendSMS(phoneNumber: phoneNumberTextField.text ?? "")
    }

    func clearText() {
        phoneNumberTextField.text = nil
    }

    private func setupKVO() {
        // KVOでテキストフィールドの入力状態と次へボタンの活性を連動
        observers.append(
            phoneNumberTextField.observe(\.text, options: [.initial, .new]) { [weak self] _, change in
                if let text = change.newValue as? String, text.phoneNumberValidation() {
                    self?.nextButton.isEnabled = true
                } else {
                    self?.nextButton.isEnabled = false
                }
            }
        )
    }

    func sendSMS(phoneNumber: String) {
        startAnimating(type: .circleStrokeSpin)
        closeKeyboard()
        isRequesting = true

        smsService.sendSMS(phoneNumber: phoneNumber) { [weak self] result in
            self?.stopAnimating()
            self?.isRequesting = false
            switch result {
            case .success(let verificationID):
                self?.gotoAuthSMS(verificationID: verificationID)
            case .failure(.upperLimit):
                // TODO: 送信上限
                self?.showAlert(message: "TODO: 送信が制限されました。時間を置いてから実行してください")
            case .failure(.network):
                // TODO: リトライ
                self?.showAlertWithCancel(message: "TODO: ネットワークエラー。再実行しますか？", okButtonTitle: "再試行", okAction: { [weak self] _ in self?.sendSMS(phoneNumber: phoneNumber) })
            case .failure(.unknown(let error)):
                // TODO: そのたエラー
                self?.showAlert(message: error?.localizedDescription ?? "nil")
            }
        }
    }

    func gotoAuthSMS(verificationID: String) {
        let authVC = AuthSMSViewController.instantiate()
        authVC.verificationID = verificationID
        authVC.profile = profile
        navigationController?.pushViewController(authVC, animated: true)
    }
}

extension InputPhoneNumberViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let currentString = textField.text, let _range = Range(range, in: currentString) {
            let newString = currentString.replacingCharacters(in: _range, with: string)
            guard newString.isPhoneNumberAcceptInput else { return false }
            // テキストフィールドを直接書き換え（KVOに反応させるため）
            textField.text = newString
            return false
        }
        return true
    }
}
