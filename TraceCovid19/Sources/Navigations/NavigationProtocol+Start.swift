//
//  NavigationProtocol+Start.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/28.
//

import UIKit

protocol Tutorial1Accessable: ModalNavigationProtocol {
    func modalToTutorial1()
}

extension Tutorial1Accessable {
    func modalToTutorial1() {
        present(to: Tutorial1ViewController.instantiate())
    }
}

protocol Tutorial2Accessable: PushNavigationProtocol {
    func pushToTutorial2()
}

extension Tutorial2Accessable {
    func pushToTutorial2() {
        push(to: Tutorial2ViewController.instantiate())
    }
}

protocol Tutorial3Accessable: PushNavigationProtocol {
    func pushToTutorial3()
}

extension Tutorial3Accessable {
    func pushToTutorial3() {
        push(to: Tutorial3ViewController.instantiate())
    }
}

protocol Agreement1Accessable: PushNavigationProtocol {
    func pushToAgreement1(profile: Profile)
}

extension Agreement1Accessable {
    func pushToAgreement1(profile: Profile) {
        let vc = Agreement1ViewController.instantiate()
        vc.profile = profile
        push(to: vc)
    }
}

protocol Agreement2Accessable: PushNavigationProtocol {
    func pushToAgreement2(profile: Profile)
}

extension Agreement2Accessable {
    func pushToAgreement2(profile: Profile) {
        let vc = Agreement2ViewController.instantiate()
        vc.profile = profile
        push(to: vc)
    }
}
