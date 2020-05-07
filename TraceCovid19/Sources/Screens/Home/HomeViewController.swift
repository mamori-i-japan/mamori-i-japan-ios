//
//  HomeViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/01.
//

import UIKit
import KeychainAccess
import NVActivityIndicatorView
import SnapKit

enum UserStatus {
    case usual(count: Int)
    case semiUsual(count: Int)
    // NOTE: Ph1では未実装
//    case attension(latest: DeepContactUser)
//    case positive

    static let usualUpperLimitCount = 25
}

final class HomeViewController: UIViewController, NVActivityIndicatorViewable, MenuAccessable, TraceDataUploadAccessable {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerBaseView: UIView!
    @IBOutlet weak var topMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var homeActionContentsView: HomeActionContentsView!
    @IBOutlet weak var homeInformationView: HomeInformationView!
    @IBOutlet weak var homePositiveContentsView: HomePositiveContentsView!

    var keychain: KeychainService!
    var ble: BLEService!
    var deepContactCheck: DeepContactCheckService!
    var positiveContact: PositiveContactService!
    var tempId: TempIdService!
    var loginService: LoginService!
    var profileService: ProfileService!
    var informationService: InformationService!

    private var information: Information?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()

        if fetchTempIDIfNotHave() == false {
            // 持っているならばBLEをオンにする
            ble.turnOn()
        }

        // バックグラウンドから復帰時に陽性者取得を行う
        NotificationCenter.default.addObserver(self, selector: #selector(fetchData), name: UIApplication.willEnterForegroundNotification, object: nil)

        #if DEBUG
        let debugItem = UIBarButtonItem(title: "デバッグ", style: .plain, target: self, action: #selector(gotoDebug))
        navigationItem.leftBarButtonItem = debugItem
        #endif
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetchData()
        reloadViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        scrollView.flashScrollIndicators()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func tappedMenuButton(_ sender: Any) {
        pushToMenu()
    }

    @IBAction func tappedShareButton(_ sender: Any) {
        shareApp()
    }

    @discardableResult
    private func fetchTempIDIfNotHave() -> Bool {
        guard !tempId.hasTempIDs else { return false }
        // TempIDを補充
        tempId.relaodTempIdsIfNeeded()
        // BLEを開始する
        ble.turnOn()
        return true
    }

    private func setupViews() {
        // SafeAreaを考慮したマージン設定
        topMarginConstraint.constant = topBarHeight

        // ScrollViewのContentSize調整
        scrollView.contentInsetAdjustmentBehavior = .never

        // ドロップシャドー
        headerBaseView.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        headerBaseView.layer.shadowRadius = 10.0
        headerBaseView.layer.shadowColor = UIColor(hex: 0x1d2a3e, alpha: 0.1).cgColor
        headerBaseView.layer.shadowOpacity = 1.0

        // 角丸
        headerBaseView.layer.cornerRadius = 8.0
        headerBaseView.clipsToBounds = false

        homePositiveContentsView.setUploadButtonAction { [weak self] in
            self?.gotoUpload()
        }
    }

    private func reloadViews() {
        dateLabel.text = "最終更新: \(Date().toString(format: "MM月dd日HH時"))"
        redrawHeaderView()
        redrawActionContentView()
    }

    private func redrawHeaderView() {
        // ヘッダのSubviewを再描画
        headerBaseView.subviews.forEach { $0.removeFromSuperview() }
        switch status {
        case .usual(let count), .semiUsual(let count):
            if case .usual = status {
                headerImageView.image = Asset.homeUsualHeader.image
            } else {
                headerImageView.image = Asset.homeSemiUsualHeader.image
            }
            let header = HomeUsualHeaderView(frame: headerBaseView.frame)
            header.set(contactCount: count) { [weak self] in
                self?.gotoHistory()
            }
            headerBaseView.addSubview(header)
            header.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
//        case .attension(let latestContactUser):
//            headerImageView.image = Asset.homeAttensionHeader.image
//            let header = HomeAttensionHeaderView(frame: headerBaseView.frame)
//            header.set(positiveContactUser: latestContactUser) { [weak self] in
//                self?.gotoHistory()
//            }
//            headerBaseView.addSubview(header)
//            header.snp.makeConstraints { make in
//                make.edges.equalToSuperview()
//            }
//        case .positive:
//            headerImageView.image = Asset.homePositiveHeader.image
//            let header = HomePositiveHeaderView(frame: headerBaseView.frame)
//            headerBaseView.addSubview(header)
//            header.snp.makeConstraints { make in
//                make.edges.equalToSuperview()
//            }
        }
    }

    func redrawActionContentView() {
//        switch status {
//        case .usual, .semiUsual, .attension:
        homeActionContentsView.isHidden = false
        homePositiveContentsView.isHidden = true
        if let information = information {
            homeInformationView.isHidden = false
            homeInformationView.set(information: information) { [weak self] information in
                // TODO: 画面とかの見せ方
                self?.showAlert(message: information.messageForAppAccess)
            }
        } else {
            homeInformationView.isHidden = true
        }
//        case .positive:
//            homeActionContentsView.isHidden = true
//            homePositiveContentsView.isHidden = false
//        }
    }

    func shareApp() {
        let shareText = "TODO: シェア文言・リンク先・画像"
        let shareURL = URL(string: "https://corona.go.jp/")!
        let shareImage: UIImage = Asset.logo.image

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

    func gotoUpload() {
        modalToTraceDataUpload()
    }

    func gotoHistory() {
        navigationController?.pushViewController(TraceHistoryViewController.instantiate(), animated: true)
    }

    #if DEBUG
    @objc
    func gotoDebug() {
        let navigationController = CustomNavigationController(rootViewController: DebugViewController.instantiate())
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
    #endif
}

extension HomeViewController: NavigationBarHiddenApplicapable {
}

extension HomeViewController {
    private var status: UserStatus {
//        if positiveContact.isPositiveMyself() {
//            return .positive
//        }
//        if let latestPerson = positiveContact.getLatestContactedPositivePeople() {
//            return .attension(latest: latestPerson)
//        }

        let count = deepContactCheck.getDeepContactUsersUniqCountAtYesterday()
        return count >= UserStatus.usualUpperLimitCount ? .semiUsual(count: count) : .usual(count: count)
    }

    @objc
    func fetchData() {
        // TODO: モーダル先からログアウトをする場合、ここの処理が呼ばれてしまうので余裕があればカバーする
        fetchProfile()
    }

    private func fetchProfile() {
        startAnimating(type: .circleStrokeSpin)

        profileService.get { [weak self] result in
            self?.stopAnimating()

            switch result {
            case .success(let profile):
                self?.fetchPosisitiveContacts(profile: profile)
            case .failure(.auth):
                // ログアウト
                self?.loginService.logout()
                self?.backToSplash()
            case .failure(.network):
                // TODO: ネットワークエラー
                print("[Home] network error")
            case .failure(.parse):
                // TODO: エラー表示
                print("[Home] parse error")
            case .failure(.unknown(let error)):
                // TODO: エラー表示
                print("[Home] error: \(String(describing: error))")
            }
        }
    }

    private func fetchPosisitiveContacts(profile: Profile) {
        guard let organizationCode = profile.organizationCode else { return }

        startAnimating(type: .circleStrokeSpin)
        positiveContact.load(organizationCode: organizationCode) { [weak self] result in
            self?.stopAnimating()

            switch result {
            case .success:
                self?.execDeepContactCheck(profile: profile)
            case .failure(.noNeedToLoad):
                break
            case .failure(.error(let error)):
                // TODO: エラー表示
                print("[Home] error: \(String(describing: error))")
            }
        }
    }

    private func execDeepContactCheck(profile: Profile) {
        startAnimating(type: .circleStrokeSpin)
        deepContactCheck.checkStart { [weak self] in
            self?.stopAnimating()
            print("[Home] deep contact check finished: \($0)")
            // TODO: 濃厚接触判定が真だったらに限定する
            self?.fetchInformation(profile: profile)

            self?.reloadViews()
        }
    }

    private func fetchInformation(profile: Profile) {
        guard let organizationCode = profile.organizationCode else { return }

        startAnimating(type: .circleStrokeSpin)
        informationService.get(organizationCode: organizationCode) { [weak self] result in
            self?.stopAnimating()

            print("[Home] fetch infromation] \(result)")
            switch result {
            case .success(let information):
                self?.information = information
                self?.redrawActionContentView()
            case .failure:
                // TODO: エラーハンドリング
                self?.information = nil
                self?.redrawActionContentView()
            }
        }
    }
}

 // TODO: あとできりだす
extension UIViewController {
    var topBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height +
            (navigationController?.navigationBar.bounds.height ?? 0.0)
    }
}
