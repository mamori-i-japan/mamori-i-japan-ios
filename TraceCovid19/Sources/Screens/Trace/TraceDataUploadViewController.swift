//
//  TraceDataUploadViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/09.
//

import UIKit
import NVActivityIndicatorView

final class TraceDataUploadViewController: UIViewController, NVActivityIndicatorViewable, NavigationBarHiddenApplicapable, KeyboardCloseProtocol, TraceDataUploadCompleteAccessable {
    @IBOutlet weak var tokenTextField: BaseTextField!
    @IBOutlet weak var nextButton: ActionButton!

    var traceDataUpload: TraceDataUploadService!
    var loginService: LoginService!

    private var observers = [NSKeyValueObservation]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tokenTextField.delegate = self
        setupKeyboardClose()
        setupKVO()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tokenTextField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        tokenTextField.resignFirstResponder()
    }

    private func setupKVO() {
        // KVOでテキストフィールドの入力状態と次へボタンの活性を連動
        observers.append(
            tokenTextField.observe(\.text, options: [.initial, .new]) { [weak self] _, change in
                if change.newValue == nil || change.newValue??.isEmpty == true {
                    self?.nextButton.isEnabled = false
                } else {
                    self?.nextButton.isEnabled = true
                }
            }
        )
    }

    @IBAction func tappedUploadButton(sender: Any) {
        requestUpload()
    }

    func requestUpload() {
        closeKeyboard()

        guard let token = tokenTextField.text else { return }

        startAnimating(type: .circleStrokeSpin)

        traceDataUpload.upload(healthCenterToken: token) { [weak self] result in
            self?.stopAnimating()

            switch result {
            case .success:
                self?.pushToTraceDataUploadComplete()
            case .failure(.auth):
                self?.showAlert(title: L10n.Error.Authentication.title, message: L10n.Error.Authentication.message, buttonTitle: L10n.logout) { [weak self] _ in
                    self?.loginService.logout()
                    self?.backToSplash()
                }
            case .failure(.network):
                self?.showAlert(title: L10n.Error.FailedUploading.title, message: L10n.Error.FailedUploading.message)
            case .failure(.unknown(let error)):
                print("[InputOrganization] error: \(error?.localizedDescription ?? "nil")")
                self?.showAlert(title: L10n.Error.Unknown.title)
            }
        }
    }
}

extension TraceDataUploadViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        closeKeyboard()
        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let currentString = textField.text, let _range = Range(range, in: currentString) {
            let newString = currentString.replacingCharacters(in: _range, with: string)
            // テキストフィールドを直接書き換え（KVOに反応させるため）
            textField.text = newString
            return false
        }
        return true
    }
}
