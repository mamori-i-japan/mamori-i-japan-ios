//
//  UIViewController+ShowAlert.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/13.
//

import UIKit

extension UIViewController {
    func showAlert(message: String, buttonTitle: String = "OK", action: @escaping (UIAlertAction) -> Void = { _ in }) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: action))
        present(alert, animated: true, completion: nil)
    }

    func showAlertWithCancel(
        message: String,
        okButtonTitle: String = "OK",
        okAction: @escaping (UIAlertAction) -> Void = { _ in },
        cancelButtonTitle: String = "Cancel",
        cancelAction: @escaping (UIAlertAction) -> Void = { _ in }
    ) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okButtonTitle, style: .default, handler: okAction))
        alert.addAction(UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: cancelAction))
        present(alert, animated: true, completion: nil)
    }
}
