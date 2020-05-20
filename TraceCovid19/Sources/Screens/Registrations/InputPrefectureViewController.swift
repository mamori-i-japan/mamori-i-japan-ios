//
//  InputPrefectureViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/11.
//

import UIKit
import NVActivityIndicatorView

final class InputPrefectureViewController: UIViewController, NVActivityIndicatorViewable, NavigationBarHiddenApplicapable, PermissionSettingAccessable {
    @IBOutlet weak var prefectureTextField: UITextField!
    @IBOutlet weak var errorLabel: BaseLabel!
    @IBOutlet weak var nextButton: ActionButton!

    var profileService: ProfileService!
    var loginService: LoginService!

    enum Flow {
        case start
        case change(Profile)
    }

    var flow: Flow!

    private let pickerView = UIPickerView()
    private var observers = [NSKeyValueObservation]()

    override func viewDidLoad() {
        super.viewDidLoad()

        if case .change(let profile) = flow {
            // 変更フローの場合はテキストに設定
            prefectureTextField.text = PrefectureModel(index: profile.prefecture)?.rawValue
            nextButton.setTitle("更新する", for: .normal)
        }

        prefectureTextField.delegate = self
        setupErrorText(text: nil)
        setupPickerView()
        setupKeyboardClose()
        setupKVO()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        prefectureTextField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        prefectureTextField.resignFirstResponder()
    }

    private func setupPickerView() {
        pickerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: pickerView.bounds.size.height)
        pickerView.delegate = self
        pickerView.dataSource = self

        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 44))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)

        prefectureTextField.inputView = pickerView
        prefectureTextField.inputAccessoryView = toolbar

        let defaultPrefecture = PrefectureModel(rawValue: prefectureTextField.text ?? "") ?? .tokyo
        pickerView.selectRow(defaultPrefecture.rawIndex, inComponent: 0, animated: false)
    }

    private func setupKVO() {
        // KVOでテキストフィールドの入力状態と次へボタンの活性を連動
        observers.append(
            prefectureTextField.observe(\.text, options: [.initial, .new]) { [weak self] _, change in
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

    @IBAction func tappedNextButton(_ sender: Any) {
        guard let prefecture = PrefectureModel(rawValue: prefectureTextField.text ?? "") else { return }
        setupErrorText(text: nil)

        switch flow {
        case .start:
            login(profile: Profile(prefecture: prefecture, organizationCode: nil))
        case .change(var profile):
            requestProfile(profile: profile.update(prefecture: prefecture))
        case .none:
            break
        }
    }

    @objc
    func done() {
        prefectureTextField.endEditing(true)
        prefectureTextField.text = PrefectureModel.rawValues[pickerView.selectedRow(inComponent: 0)]
    }
}

// MARK: - 登録処理
extension InputPrefectureViewController {
    private func login(profile: Profile) {
        startAnimating(type: .circleStrokeSpin)
        loginService.signInAnonymously(profile: profile) { [weak self] result in
            self?.stopAnimating()

            switch result {
            case .success:
                self?.pushToPermissionSetting()
            case .failure(let error):
                self?.showError(error: error)
            }
        }
    }

    private func showError(error: LoginService.SignInError) {
        switch error {
        case .network:
            showAlert(title: L10n.Error.Network.title, message: L10n.Error.Network.message)
        case .unknown(let error):
            print("[InputPrefecture] error: \(error.localizedDescription)")
            showAlert(title: L10n.Error.Unknown.title, message: L10n.Error.Unknown.message)
        }
    }
}

extension InputPrefectureViewController: ProfileChangeable {
    func showNetworkError() {
        // ネットワークエラー時の文言を変更
        showAlert(title: L10n.Error.Prefecture.title)
    }
}

// MARK: - UIPickerViewDataSource
extension InputPrefectureViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        PrefectureModel.allCases.count
    }
}

// MARK: - UIPickerViewDelegate
extension InputPrefectureViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        PrefectureModel.rawValues[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    }
}

// MARK: - UITextFieldDelegate
extension InputPrefectureViewController: UITextFieldDelegate {
}

extension InputPrefectureViewController: KeyboardCloseProtocol {
    func closeKeyboard() {
        done()
    }
}
