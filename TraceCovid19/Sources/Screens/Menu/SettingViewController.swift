//
//  SettingViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/17.
//

import UIKit
import NVActivityIndicatorView

final class SettingViewController: UITableViewController, NVActivityIndicatorViewable, InputOrganizationAccessable, InputPrefectureAccessable {
    @IBOutlet weak var prefectureLabel: UILabel!
    @IBOutlet weak var organizationLabel: UILabel!
    @IBOutlet weak var prefectureTableViewCell: UITableViewCell!
    @IBOutlet weak var organizationTableViewCell: UITableViewCell!
    @IBOutlet weak var clearOrganizationButton: BorderButton!

    var profileService: ProfileService!
    var loginService: LoginService!

    private var profile: Profile?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        resetProfile()
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

    func resetProfile() {
        profile = nil
        organizationLabel.text = nil
        prefectureLabel.text = nil
        clearOrganizationButton.isHidden = true
    }

    func update(profile: Profile) {
        let normalColor = UIColor.systemBlack
        let blankColor = UIColor.systemLightGray

        if let organization = profile.organizationCode, !organization.isEmpty {
            organizationLabel.text = organization
            organizationLabel.textColor = normalColor
            clearOrganizationButton.isHidden = false
        } else {
            organizationLabel.text = L10n.noSetting
            organizationLabel.textColor = blankColor
            clearOrganizationButton.isHidden = true
        }

        if let perefecture = PrefectureModel(index: profile.prefecture) {
            prefectureLabel.text = perefecture.rawValue
            prefectureLabel.textColor = normalColor
        } else {
            prefectureLabel.text = L10n.noSetting
            prefectureLabel.textColor = blankColor
        }
    }

    @IBAction func tappedClearOrganizationButton(_ sender: Any) {
        showConfirmationToClear()
    }

    private func showConfirmationToClear() {
        showAlertWithCancel(
            title: "組織コードをクリアします",
            message: "この組織との連携が解除されます",
            okAction: { [weak self] _ in
                self?.requestClearOrganization()
            }
        )
    }

    func forceLogout() {
        loginService.logout()
        backToSplash()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let profile = profile else { return }
        switch tableView.cellForRow(at: indexPath) {
        case prefectureTableViewCell:
            pushToInputPrefecture(flow: .change(profile))
        case organizationTableViewCell:
            pushToInputOrganization(flow: .change(profile))
        default:
            break
        }
    }
}

extension SettingViewController: NavigationBarHiddenApplicapable {
    var navigationBackgroundImage: UIImage? {
        // シャドウ部分は消すが、ナビゲーション部分はデフォルトままにする
        return nil
    }
}

extension SettingViewController {
    func requestClearOrganization() {
        // TODO: クリア処理は変更となる
        guard let profile = profile else { return }
        startAnimating(type: .circleStrokeSpin)
        profileService.update(profile: profile, organization: nil) { [weak self] result in
            self?.stopAnimating()
            switch result {
            case .success:
                // TODO: 成功時、再度取得しにいくしかない？
                self?.requestProfile()
            case .failure(.network):
                // TODO: リトライ
                self?.showAlertWithCancel(message: "TODO: ネットワークエラー。再実行しますか？", okButtonTitle: "再試行", okAction: { [weak self] _ in self?.requestClearOrganization() })
            case .failure(.auth):
                self?.forceLogout()
            case .failure(.unknown(let error)):
                // TODO:
                self?.showAlert(message: error?.localizedDescription ?? "error")
            }
        }
    }
}
