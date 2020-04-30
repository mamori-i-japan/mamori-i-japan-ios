//
//  NavigationProtocol+Registerations.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/28.
//

import Foundation

protocol InputPrefectureAccessable: PushNavigationProtocol {
    func pushToInputPrefecture(flow: InputPrefectureViewController.Flow)
}

extension InputPrefectureAccessable {
    func pushToInputPrefecture(flow: InputPrefectureViewController.Flow = .start) {
        let vc = InputPrefectureViewController.instantiate()
        vc.flow = flow
        push(to: vc)
    }
}

protocol InputJobAccessable: PushNavigationProtocol {
    func pushToInputJob(flow: InputJobViewController.Flow)
}

extension InputJobAccessable {
    func pushToInputJob(flow: InputJobViewController.Flow) {
        let vc = InputJobViewController.instantiate()
        vc.flow = flow
        push(to: vc)
    }
}

protocol InputPhoneNumberAccessable: PushNavigationProtocol {
    func pushToInputPhoneNumber(profile: Profile)
}

extension InputPhoneNumberAccessable {
    func pushToInputPhoneNumber(profile: Profile) {
        let vc = InputPhoneNumberViewController.instantiate()
        vc.profile = profile
        push(to: vc)
    }
}

protocol AuthSMSAccessable: PushNavigationProtocol {
    func pushToAuthSMS(verificationID: String, profile: Profile)
}

extension AuthSMSAccessable {
    func pushToAuthSMS(verificationID: String, profile: Profile) {
        let vc = AuthSMSViewController.instantiate()
        vc.verificationID = verificationID
        vc.profile = profile
        push(to: vc)
    }
}
