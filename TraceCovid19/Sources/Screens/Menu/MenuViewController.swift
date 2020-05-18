//
//  MenuViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/09.
//

import UIKit
import NVActivityIndicatorView

final class MenuViewController: UITableViewController, NVActivityIndicatorViewable, AboutAccessable, SettingAccessable, TraceDataUploadAccessable {
    @IBOutlet weak var settingTableViewCell: UITableViewCell!
    @IBOutlet weak var deleteSharingTableViewCell: UITableViewCell!
    @IBOutlet weak var dataUploadTableViewCell: UITableViewCell!
    @IBOutlet weak var aboutTableViewCell: UITableViewCell!

    var profileService: ProfileService!
    var loginService: LoginService!
    var cancelPositiveService: CancelPositiveService!

    static let dataUploadIndexPath = IndexPath(row: 2, section: 0)
    // NOTE: 組織コードに関わらず常に非表示するように対応
    private var isHideDataUploadCell = true

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //        getProfile()
    }

    private func showDeleteSharing() {
        showAlertWithCancel(
            message: "センターへの情報共有を取り消しますか？",
            okAction: { [weak self] _ in
                self?.requestDeleteSharing()
            }
        )
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch tableView.cellForRow(at: indexPath) {
        case settingTableViewCell:
            pushToSetting()
        case deleteSharingTableViewCell:
            showDeleteSharing()
        case dataUploadTableViewCell:
            pushToTraceDataUpload()
        case aboutTableViewCell:
            pushToAbout()
        default:
            break
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isHideDataUploadCell && indexPath == type(of: self).dataUploadIndexPath {
            // データアップロードのセルを隠す場合、対象のセルの高さを0として扱う
            return 0.0
        }

        return tableView.rowHeight
    }
}

extension MenuViewController: NavigationBarHiddenApplicapable {
    var navigationBackgroundImage: UIImage? {
        // シャドウ部分は消すが、ナビゲーション部分はデフォルトままにする
        return nil
    }
}

extension MenuViewController {
    func getProfile() {
        startAnimating(type: .circleStrokeSpin)
        profileService.get { [weak self] result in
            self?.stopAnimating()
            switch result {
            case .success(let profile):
                if let code = profile.organizationCode, !code.isEmpty {
                    self?.isHideDataUploadCell = false
                } else {
                    self?.isHideDataUploadCell = true
                }
                self?.tableView.reloadData()
            case .failure(.auth):
                // 認証エラーのみハンドリングする
                self?.loginService.logout()
                self?.backToSplash()
            case .failure:
                break
            }
        }
    }

    func requestDeleteSharing() {
        startAnimating(type: .circleStrokeSpin)
        cancelPositiveService.cancel { [weak self] result in
            self?.stopAnimating()
            switch result {
            case .success:
                self?.showAlert(message: "取り消しました")
            case .failure(.auth):
                self?.loginService.logout()
                self?.backToSplash()
            case .failure(.network):
                // TODO: 文言は仮のものをLocalizableに記述している
                self?.showAlert(title: L10n.Error.FailedDeleteSharing.title, message: L10n.Error.FailedDeleteSharing.message)
            case .failure(.unknown(let error)):
                print("[Cancel] error: \(error?.localizedDescription ?? "nil")")
                self?.showAlert(title: L10n.Error.Unknown.title)
            }
        }
    }
}
