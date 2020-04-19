//
//  InputPrefectureViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/11.
//

import UIKit

final class InputPrefectureViewController: UIViewController {
    @IBOutlet weak var prefectureTextField: UITextField!
    @IBOutlet weak var nextButton: ActionButton!

    private let pickerView = UIPickerView()
    private var observers = [NSKeyValueObservation]()

    override func viewDidLoad() {
        super.viewDidLoad()

        prefectureTextField.delegate = self
        setupPickerView()
        setupKeyboardClose()
        setupKVO()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        prefectureTextField.becomeFirstResponder()
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

        pickerView.selectRow(PrefectureModel.tokyo.index, inComponent: 0, animated: false)
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

    @IBAction func tappedNextButton(_ sender: Any) {
        guard let prefecture = PrefectureModel(rawValue: prefectureTextField.text ?? "") else { return }
        gotoInputJob(prefecture: prefecture)
    }

    func gotoInputJob(prefecture: PrefectureModel) {
        let vc = InputJobViewController.instantiate()
        vc.prefecture = prefecture
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc
    func done() {
        prefectureTextField.endEditing(true)
        prefectureTextField.text = PrefectureModel.rawValues[pickerView.selectedRow(inComponent: 0)]
    }
}

extension InputPrefectureViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        PrefectureModel.allCases.count
    }
}

extension InputPrefectureViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return PrefectureModel.rawValues[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    }
}

extension InputPrefectureViewController: UITextFieldDelegate {
}

extension InputPrefectureViewController: KeyboardCloseProtocol {
    func closeKeyboard() {
        done()
    }
}
