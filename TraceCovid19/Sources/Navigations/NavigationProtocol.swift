//
//  NavigationProtocol.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/28.
//

import UIKit

protocol PushNavigationProtocol {
    var navigationController: UINavigationController? { get }
    func push(to viewController: UIViewController)
    func setViewControllers(to viewControllers: [UIViewController])
}

extension PushNavigationProtocol {
    func push(to viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }

    func setViewControllers(to viewControllers: [UIViewController]) {
        navigationController?.setViewControllers(viewControllers, animated: true)
    }
}

protocol ModalNavigationProtocol {
    var presenter: UIViewController { get }
    func present(to viewController: UIViewController)
}

extension ModalNavigationProtocol {
    func present(to viewController: UIViewController) {
        let navigationController = CustomNavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        presenter.present(navigationController, animated: false, completion: nil)
    }
}

extension ModalNavigationProtocol where Self: UIViewController {
    var presenter: UIViewController {
        self
    }
}
