//
//  NavigationProtocol+Registerations.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/28.
//

import Foundation

protocol InputPrefectureAccessable: NavigationProtocol {
    func pushToInputPrefecture(flow: InputPrefectureViewController.Flow)
}

extension InputPrefectureAccessable {
    func pushToInputPrefecture(flow: InputPrefectureViewController.Flow = .start) {
        let vc = InputPrefectureViewController.instantiate()
        vc.flow = flow
        navigationController?.pushViewController(vc, animated: true)
    }
}

protocol InputJobAccessable: NavigationProtocol {
    func pushToInputJob(flow: InputJobViewController.Flow)
}

extension InputJobAccessable {
    func pushToInputJob(flow: InputJobViewController.Flow) {
        let vc = InputJobViewController.instantiate()
        vc.flow = flow
        navigationController?.pushViewController(vc, animated: true)
    }
}

protocol InputPhoneNumberAccessable: NavigationProtocol {
    func pushToInputPhoneNumber(profile: Profile)
}

extension InputPhoneNumberAccessable {
    func pushToInputPhoneNumber(profile: Profile) {
        let vc = InputPhoneNumberViewController.instantiate()
        vc.profile = profile
        navigationController?.pushViewController(vc, animated: true)
    }
}

protocol AuthSMSAccessable: NavigationProtocol {
    func pushToAuthSMS(verificationID: String, profile: Profile)
}

extension AuthSMSAccessable {
    func pushToAuthSMS(verificationID: String, profile: Profile) {
        let authVC = AuthSMSViewController.instantiate()
        authVC.verificationID = verificationID
        authVC.profile = profile
        navigationController?.pushViewController(authVC, animated: true)
    }
}
