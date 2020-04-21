//
//  HomeViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/01.
//

import UIKit
import KeychainAccess
import NVActivityIndicatorView

final class HomeViewController: UIViewController, NavigationBarHiddenApplicapable, NVActivityIndicatorViewable {
    @IBOutlet weak var homeBaseView: HomeBaseView!

    var keychain: KeychainService!
    var ble: BLEService!
    var deepContactCheck: DeepContactCheckService!
    var positiveContact: PositiveContactService!
    var tempId: TempIdService!

    enum Status {
        case normal
        case contactedPositive(latest: DeepContactUser)
        case isPositiveOwn
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if fetchTempIDIfNotHave() == false {
            // 持っているならばBLEをオンにする
            ble.turnOn()
        }

        // バックグラウンドから復帰時に陽性者取得を行う
        NotificationCenter.default.addObserver(self, selector: #selector(getPositiveContacts), name: UIApplication.willEnterForegroundNotification, object: nil)

        #if DEBUG
        let debugItem = UIBarButtonItem(title: "デバッグ", style: .plain, target: self, action: #selector(gotoDebug))
        navigationItem.leftBarButtonItem = debugItem
        #endif
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        getPositiveContacts()
        reloadViews()
    }

    @IBAction func tappedMenuButton(_ sender: Any) {
        gotoMenu()
    }

    @IBAction func tappedShareButton(_ sender: Any) {
        shareApp()
    }

    @discardableResult
    private func fetchTempIDIfNotHave() -> Bool {
        guard !tempId.hasTempIDs else { return false }
        // TODO: 多重カウントによるアニメーション管理
        startAnimating(type: .circleStrokeSpin)

        tempId.fetchTempIDs { [weak self] result in
            self?.stopAnimating()

            switch result {
            case .failure:
                // TODO: エラーの見せ方
                self?.showAlert(message: "読み込みに失敗しました", buttonTitle: "再読み込み") { [weak self] _ in
                    self?.fetchTempIDIfNotHave()
                }
            case .success:
                // 成功ならBLEを開始する
                self?.ble.turnOn()
            }
        }
        return true
    }

    private func reloadViews() {
        homeBaseView.setStatus(status)
    }

    func gotoMenu() {
        navigationController?.pushViewController(MenuViewController.instantiate(), animated: true)
    }

    func shareApp() {
        let shareText = "シェア文言"
        let shareURL = NSURL(string: "https://corona.go.jp/")!
        let shareImage = UIImage(named: "Group")!

        let activityViewController = UIActivityViewController(activityItems: [shareText, shareURL, shareImage], applicationActivities: nil)

        // 使用しないタイプ
        let excludedActivityTypes: [UIActivity.ActivityType] = [
            .saveToCameraRoll,
            .print,
            .openInIBooks,
            .assignToContact,
            .addToReadingList,
            .copyToPasteboard,
            .init(rawValue: "com.apple.reminders.RemindersEditorExtension"), // リマインダー
            .init(rawValue: "com.apple.mobilenotes.SharingExtension") // メモ
        ]

        activityViewController.excludedActivityTypes = excludedActivityTypes

        // UIActivityViewControllerを表示
        present(activityViewController, animated: true, completion: nil)
    }

    @objc
    func gotoDebug() {
        let navigationController = CustomNavigationController(rootViewController: DebugViewController.instantiate())
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
}

extension HomeViewController {
    private var status: Status {
        if positiveContact.isPositiveMyself() {
            return .isPositiveOwn
        }
        if let latestPerson = positiveContact.getLatestContactedPositivePeople() {
            return .contactedPositive(latest: latestPerson)
        }
        return .normal
    }

    @objc
    func getPositiveContacts() {
        startAnimating(type: .circleStrokeSpin)

        // TODO: モーダル先からログアウトをする場合、ここの処理が呼ばれてしまうので余裕があればカバーする
        positiveContact.load { [weak self] result in
            self?.stopAnimating()

            switch result {
            case .success:
                self?.execDeepContactCheck()
            case .failure(.noNeedToLoad):
                break
            case .failure(.error(let error)):
                // TODO: エラー表示
                print("[Home] error: \(String(describing: error))")
            }
        }
    }

    private func execDeepContactCheck() {
        startAnimating(type: .circleStrokeSpin)
        deepContactCheck.checkStart { [weak self] in
            self?.stopAnimating()
            print("[Home] deep contact check finished: \($0)")
            self?.reloadViews()
        }
    }
}
