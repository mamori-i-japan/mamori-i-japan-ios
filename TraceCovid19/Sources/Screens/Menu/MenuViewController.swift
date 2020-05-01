//
//  MenuViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/09.
//

import UIKit
import NVActivityIndicatorView

final class MenuViewController: UITableViewController, NVActivityIndicatorViewable, AboutAccessable, SettingAccessable {
    @IBOutlet weak var settingTableViewCell: UITableViewCell!
    @IBOutlet weak var dataUploadTableViewCell: UITableViewCell!
    @IBOutlet weak var aboutTableViewCell: UITableViewCell!
    @IBOutlet weak var contactTableViewCell: UITableViewCell!

    var profileService: ProfileService!
    var loginService: LoginService!

    static let dataUploadIndexPath = IndexPath(row: 1, section: 0)
    var isHideDataUploadCell = true

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        getProfile()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch tableView.cellForRow(at: indexPath) {
        case aboutTableViewCell:
            pushToAbout()
        case settingTableViewCell:
            pushToSetting()
        case contactTableViewCell:
            // TODO
            break
        case dataUploadTableViewCell:
            // TODO
            break
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
}
