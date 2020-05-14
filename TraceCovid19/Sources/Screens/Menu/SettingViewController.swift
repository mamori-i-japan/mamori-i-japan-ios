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
    var keychainService: KeychainService!

    static let organizationColeIndexPath = IndexPath(row: 1, section: 0)
    // NOTE: 常に組織コードは表示しないように対応
    private var isHideOrganiztionCodeCell = true

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
                self?.showAlert(title: L10n.Error.OrganizationCode.title, message: L10n.Error.OrganizationCode.message) { [weak self] _ in
                    // 前に戻る
                    self?.navigationController?.popViewController(animated: true)
                }
            case .failure(.auth):
                self?.showAlert(title: L10n.Error.Authentication.title, message: L10n.Error.Authentication.message, buttonTitle: L10n.logout) { [weak self] _ in
                    self?.loginService.logout()
                    self?.backToSplash()
                }
            case  .failure(.parse):
                self?.showAlert(title: L10n.Error.Unknown.title) { [weak self] _ in
                    // 前に戻る
                    self?.navigationController?.popViewController(animated: true)
                }
            case .failure(.unknown(let error)):
                print("[Setting] error: \(error?.localizedDescription ?? "nil")")
                self?.showAlert(title: L10n.Error.Unknown.title) { [weak self] _ in
                    // 前に戻る
                    self?.navigationController?.popViewController(animated: true)
                }
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

        if let organization = profile.organizationCode, !organization.isEmpty, !isHideOrganiztionCodeCell {
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

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isHideOrganiztionCodeCell && indexPath == type(of: self).organizationColeIndexPath {
            // データアップロードのセルを隠す場合、対象のセルの高さを0として扱う
            return 0.0
        }

        return tableView.rowHeight
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
        startAnimating(type: .circleStrokeSpin)

        let randomIDs = keychainService.randomIDs

        profileService.delete(randomIDs: randomIDs) { [weak self] result in
            self?.stopAnimating()
            switch result {
            case .success:
                // 再度取得しにいく
                self?.requestProfile()
                self?.keychainService.clearRandomIDs()
            case .failure(.network):
                self?.showAlert(title: L10n.Error.ClearOrganizationCode.title, message: L10n.Error.ClearOrganizationCode.message)
            case .failure(.auth):
                self?.showAlert(title: L10n.Error.Authentication.title, message: L10n.Error.Authentication.message, buttonTitle: L10n.logout) { [weak self] _ in
                    self?.loginService.logout()
                    self?.backToSplash()
                }
            case .failure(.unknown(let error)):
                print("[Setting] error: \(error?.localizedDescription ?? "nil")")
                self?.showAlert(title: L10n.Error.Unknown.title)
            }
        }
    }
}
