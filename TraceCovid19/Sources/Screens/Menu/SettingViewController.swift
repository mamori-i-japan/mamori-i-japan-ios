//
//  SettingViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/17.
//

import UIKit
import NVActivityIndicatorView

final class SettingViewController: UITableViewController, NVActivityIndicatorViewable, NavigationBarHiddenApplicapable {
    @IBOutlet weak var prefectureLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var prefectureTableViewCell: UITableViewCell!
    @IBOutlet weak var jobTableViewCell: UITableViewCell!

    var profileService: ProfileService!
    var loginService: LoginService!

    private var profile: Profile?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        clearProfile()
        requestProfile()
    }

    func requestProfile() {
        startAnimating(type: .circleStrokeSpin)

        profileService.get { [weak self] result in
            self?.stopAnimating()

            switch result {
            case .success(let profile):
                self?.profile = profile
                self?.update(profile: profile)
            case .failure(.network):
                // TODO: ネットワークエラー
                self?.showAlertWithCancel(message: "TODO: ネットワークエラー。再読み込みしますか？", okButtonTitle: "再読み込み", okAction: { [weak self] _ in self?.requestProfile() })
            case .failure(.auth):
                self?.forceLogout()
            case  .failure(.parse):
                // TODO: パースエラー
                self?.showAlert(message: "TODO: parse error")
            case .failure(.unknown(let error)):
                // TODO: そのたエラー
                self?.showAlert(message: error?.localizedDescription ?? "nil")
            }
        }
    }

    func clearProfile() {
        profile = nil
        jobLabel.text = nil
        prefectureLabel.text = nil
    }

    func update(profile: Profile) {
        let normalColor = UIColor(hex: 0x05182E)
        let blankColor = UIColor(hex: 0x9E9FA8)

        if let job = profile.job, !job.isEmpty {
            jobLabel.text = job
            jobLabel.textColor = normalColor
        } else {
            jobLabel.text = L10n.noSetting
            jobLabel.textColor = blankColor
        }

        if let perefecture = PrefectureModel(index: profile.prefecture) {
            prefectureLabel.text = perefecture.rawValue
            prefectureLabel.textColor = normalColor
        } else {
            prefectureLabel.text = L10n.noSetting
            prefectureLabel.textColor = blankColor
        }
    }

    func gotoChangePrefecture() {
        guard let profile = profile else { return }
          let vc = InputPrefectureViewController.instantiate()
          vc.flow = .change(profile)
          navigationController?.pushViewController(vc, animated: true)
    }

    func gotoChangeJob() {
        guard let profile = profile else { return }
        let vc = InputJobViewController.instantiate()
        vc.flow = .change(profile)
        navigationController?.pushViewController(vc, animated: true)
    }

    func forceLogout() {
        loginService.logout()
        backToSplash()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch tableView.cellForRow(at: indexPath) {
        case prefectureTableViewCell:
            gotoChangePrefecture()
        case jobTableViewCell:
            gotoChangeJob()
        default:
            break
        }
    }
}
