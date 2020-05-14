//
//  InputOrganizationViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/17.
//

import UIKit
import NVActivityIndicatorView

// TODO: 廃止予定

final class InputOrganizationViewController: UIViewController, NVActivityIndicatorViewable, KeyboardCloseProtocol, InputPhoneNumberAccessable {
    @IBOutlet weak var organizationTextField: UITextField!
    @IBOutlet weak var errorLabel: BaseLabel!
    @IBOutlet weak var nextButton: ActionButton!

    var profileService: ProfileService!
    var loginService: LoginService!

    enum Flow {
        case change(Profile)
    }

    // TODO: 値渡しのやり方考える
    var flow: Flow!

    private var observers = [NSKeyValueObservation]()

    override func viewDidLoad() {
        super.viewDidLoad()

        if case .change(let profile) = flow {
            // 変更フローの場合はテキストに設定
            organizationTextField.text = profile.organizationCode
            nextButton.setTitle("設定する", for: .normal)
        }

        organizationTextField.delegate = self
        setupErrorText(text: nil)
        setupKeyboardClose()
        setupKVO()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        organizationTextField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        organizationTextField.resignFirstResponder()
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
        setupErrorText(text: nil)

        switch flow {
        case .change(let profile):
            requestOrgnization(profile: profile, organization: organizationTextField.text)
        case .none:
            break
        }
    }

    private func setupKVO() {
        // KVOでテキストフィールドの入力状態と次へボタンの活性を連動
        observers.append(
            organizationTextField.observe(\.text, options: [.initial, .new]) { [weak self] _, change in
                if change.newValue == nil || change.newValue??.isEmpty == true {
                    self?.nextButton.isEnabled = false
                } else {
                    self?.nextButton.isEnabled = true
                }
            }
        )
    }

    private func setupErrorText(text: String?) {
        if let text = text, !text.isEmpty {
            errorLabel.text = text
            errorLabel.isHidden = false
        } else {
            errorLabel.text = nil
            errorLabel.isHidden = true
        }
    }
}

extension InputOrganizationViewController {
    private func requestOrgnization(profile: Profile, organization: String?) {
        closeKeyboard()

        startAnimating(type: .circleStrokeSpin)
        profileService.update(profile: profile, organization: organization) { [weak self] result in
            self?.stopAnimating()
            switch result {
            case .success:
                self?.showAlert(title: "組織コードを確認しました", message: "接触デバイスIDのアップロードをお願いします", buttonTitle: "閉じる") { [weak self] _ in
                    self?.navigationController?.popViewController(animated: true)
                }
            case .failure(.notMatchCode):
                // NOTE: インラインエラーで表示する
                self?.setupErrorText(text: L10n.Error.NoMatchOrganizationCode.title)
                self?.organizationTextField.text = nil
            case .failure(.auth):
                self?.showAlert(title: L10n.Error.Authentication.title, message: L10n.Error.Authentication.message, buttonTitle: L10n.logout) { [weak self] _ in
                    self?.loginService.logout()
                    self?.backToSplash()
                }
            case .failure(.network):
                self?.showAlert(title: L10n.Error.ClearOrganizationCode.title, message: L10n.Error.ClearOrganizationCode.message)
            case .failure(.unknown(let error)):
                print("[InputOrganization] error: \(error?.localizedDescription ?? "nil")")
                self?.showAlert(title: L10n.Error.Unknown.title)
            }
        }
    }
}

extension InputOrganizationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let currentString = textField.text, let _range = Range(range, in: currentString) {
            let newString = currentString.replacingCharacters(in: _range, with: string)
            // TODO: ローカルバリデーションする？
            // テキストフィールドを直接書き換え（KVOに反応させるため）
            textField.text = newString
            return false
        }
        return true
    }
}
