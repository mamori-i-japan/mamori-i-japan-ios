//
//  NavigationProtocol+Start.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/28.
//

import UIKit

protocol Tutorial1Accessable: NavigationProtocol {
    var tutorialPresenter: UIViewController { get }
    func modalToTutorial1()
}

extension Tutorial1Accessable where Self: UIViewController {
    var tutorialPresenter: UIViewController {
        return self
    }
}

extension Tutorial1Accessable {
    func modalToTutorial1() {
        let navigationController = CustomNavigationController(rootViewController: Tutorial1ViewController.instantiate())
        navigationController.modalPresentationStyle = .fullScreen
        tutorialPresenter.present(navigationController, animated: false, completion: nil)
    }
}

protocol Tutorial2Accessable: NavigationProtocol {
    func pushToTutorial2()
}

extension Tutorial2Accessable {
    func pushToTutorial2() {
        navigationController?.pushViewController(Tutorial2ViewController.instantiate(), animated: true)
    }
}

protocol Tutorial3Accessable: NavigationProtocol {
    func pushToTutorial3()
}

extension Tutorial3Accessable {
    func pushToTutorial3() {
        navigationController?.pushViewController(Tutorial3ViewController.instantiate(), animated: true)
    }
}

protocol Agreement1Accessable: NavigationProtocol {
    func pushToAgreement1(profile: Profile)
}

extension Agreement1Accessable {
    func pushToAgreement1(profile: Profile) {
        let vc = Agreement1ViewController.instantiate()
        vc.profile = profile
        navigationController?.pushViewController(vc, animated: true)
    }
}

protocol Agreement2Accessable: NavigationProtocol {
    func pushToAgreement2(profile: Profile)
}

extension Agreement2Accessable {
    func pushToAgreement2(profile: Profile) {
        let vc = Agreement2ViewController.instantiate()
        vc.profile = profile
        navigationController?.pushViewController(vc, animated: true)
    }
}
