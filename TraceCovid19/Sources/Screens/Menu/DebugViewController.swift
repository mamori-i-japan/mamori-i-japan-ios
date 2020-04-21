//
//  DebugViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/11.
//

import UIKit

#if DEBUG
final class DebugViewController: UIViewController {
    @IBOutlet weak var controlScrollView: UIScrollView!
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var idStartLabel: UILabel!
    @IBOutlet weak var idEndLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var keepContactTextField: UITextField!
    @IBOutlet weak var deepContactJudgedTextField: UITextField!
    @IBOutlet weak var allEncounterDeleteButton: UIButton!
    @IBOutlet weak var firebaseIdLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var debugLogSwitch: UISwitch!
    @IBOutlet weak var logControlSwitch: UISwitch!
    @IBOutlet weak var blePermissionSwitch: UISwitch!
    @IBOutlet weak var btPowerSwitch: UISwitch!
    @IBOutlet weak var pushPermissionSwitch: UISwitch!

    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var bleTablewView: UITableView!

    var keychain: KeychainService!
    var loginService: LoginService!
    var ble: BLEService!
    var push: PushNotificationService!
    var coreData: CoreDataService!
    var deepContactCheck: DeepContactCheckService!
    var positiveContact: PositiveContactService!
    var tempId: TempIdService!

    private let refreshControl = UIRefreshControl()
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        bleTablewView.delegate = self
        bleTablewView.dataSource = self

        NotificationCenter.default.addObserver(self, selector: #selector(refreshAccessControl), name: UIApplication.didBecomeActiveNotification, object: nil)

        let gesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        controlScrollView.addGestureRecognizer(gesture)

        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        bleTablewView.refreshControl = refreshControl

        timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            self?.refreshData()
        }
    }

    deinit {
        timer?.invalidate()
        timer = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshAccessControl()
        refreshData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        controlScrollView.flashScrollIndicators()
    }

    @objc
    func refreshAccessControl() {
        let tempID = tempId.currentTempId
        uuidLabel.text = tempID?.tempId
        idStartLabel.text = tempID?.startTime.toString(format: "yyyy/MM/dd HH:mm:ss.SSS")
        idEndLabel.text = tempID?.endTime.toString(format: "yyyy/MM/dd HH:mm:ss.SSS")
        modelLabel.text = DeviceUtility.machineName()
        firebaseIdLabel.text = loginService.uid
        phoneNumberLabel.text = loginService.phoneNumber
        debugLogSwitch.isOn = !PrintUtility.shared.isHidden
        logControlSwitch.isOn = !PrintUtility.shared.isUserInteractionEnabled && !PrintUtility.shared.isAutoScrolling
        blePermissionSwitch.isOn = ble.isBluetoothAuthorized()
        btPowerSwitch.isOn = ble.isBluetoothOn()
        push.getAuthorization { [weak self] isAuthorized in
            DispatchQueue.main.async { [weak self] in
                self?.pushPermissionSwitch.isOn = isAuthorized
            }
        }
    }

    @objc
    func refreshData() {
        keepContactTextField.text = String(Int(deepContactCheck.deepContactSequenceDudation))
        deepContactJudgedTextField.text = String(Int(deepContactCheck.deepContactJudgedDudation))
        DispatchQueue.global(qos: .userInitiated).async {
            // CoreData直接参照について、処理が重いので別スレッドで反映
            self.traceData = self.coreData.getTraceDataList().filter { $0.isValidConnection }
        }
        deepContactCheck.checkStart { [weak self] _ in
            guard let sSelf = self else { return }
            self?.deepContactUsers = sSelf.deepContactCheck.getDeepContactUsers()

            DispatchQueue.main.async { [weak self] in
                self?.bleTablewView.reloadData()
                self?.refreshControl.endRefreshing()
                self?.timestampLabel.text = "最終更新: \(Date().toString(format: "yyyy/MM/dd HH:mm:ss.SSS"))"
            }
        }
    }

    @objc
    func closeKeyboard() {
        if keepContactTextField.isFirstResponder || deepContactJudgedTextField.isFirstResponder {
            view.endEditing(true)
            if let duration = TimeInterval(deepContactJudgedTextField.text ?? "") {
                deepContactCheck.setDeepContactJudgedDudation(duration)
            }
            if let duration = TimeInterval(keepContactTextField.text ?? "") {
                deepContactCheck.setDeepContactSequenceDudation(duration)
            }
            refreshData()
        }
    }

    private var traceData: [TraceData] = []
    private var deepContactUsers: [DeepContactUser] = []

    @IBAction func tappedCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func tappedIdButton(_ sender: Any) {
        // Debug3で表示
        navigationController?.pushViewController(Debug3ViewController.instantiate(), animated: true)
    }

    @IBAction func tappedPositiveListButton(_ sender: Any) {
        // Debug2で表示
        navigationController?.pushViewController(Debug2ViewController.instantiate(), animated: true)
    }

    @IBAction func tappedAllEncounterDeleteButton(_ sender: Any) {
        // swiftlint:disable:next trailing_closure
        showAlertWithCancel(
            message: "追跡データおよび濃厚接触者情報を削除しますか？",
            okAction: { [weak self] _ in
                self?.coreData.deleteAllTraceData()
                self?.coreData.deleteAllDeepContactUsers()
                DispatchQueue.main.async { [weak self] in
                    self?.refreshData()
                }
            }
        )
    }

    @IBAction func switchedLog(_ sender: UISwitch) {
        PrintUtility.shared.isHidden = !sender.isOn
    }

    @IBAction func switchedLogControl(_ sender: UISwitch) {
        PrintUtility.shared.isUserInteractionEnabled = sender.isOn
        PrintUtility.shared.isAutoScrolling = !sender.isOn
    }

    @IBAction func tappedLogoutButton() {
        print("did logout: \(loginService.logout())")

        /// スプラッシュに雑に戻す
        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true) {
            NotificationCenter.default.post(name: .splashStartNotirication, object: nil)
        }
    }
}

extension DebugViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.section {
        case 0:
            if indexPath.row < deepContactUsers.count {
                let deepContactUser = deepContactUsers[indexPath.row]
                let uuid = deepContactUser.tempId!
                showAlertWithCancel(
                    message: "\(uuid) \n上記を一時的に陽性者として扱いますか？",
                    okAction: { _ in
                        self.positiveContact.appendPositiveContact(uuid: uuid)
                        self.refreshData()
                    }
                )
            }
        case 1:
            break
        default:
            break
        }
    }
}

extension DebugViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return max(deepContactUsers.count, 1)
        case 1:
            return traceData.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DebugDeepContactUserCell", for: indexPath) as? DebugDeepContactUserCell else {
                return UITableViewCell()
            }
            if deepContactUsers.count == 0 {
                cell.update(text: "濃厚接触者はいません")
            } else {
                let deepContactUser = deepContactUsers[indexPath.row]
                cell.update(deepContactUser: deepContactUser)

                if (positiveContact.positiveContacts.compactMap { $0.tempID }).contains(deepContactUser.tempId!) {
                    cell.tempIDLabel.textColor = .red // 陽性者だった場合は赤にする
                } else {
                    cell.tempIDLabel.textColor = .black
                }
            }
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DebugBLECell", for: indexPath) as? DebugBLECell else {
                return UITableViewCell()
            }
            cell.update(traceData: traceData[indexPath.row])
            return cell
        default:
            return UITableViewCell()
        }
    }
}

final class DebugBLECell: UITableViewCell {
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    @IBOutlet weak var txPowerLabel: UILabel!
    @IBOutlet weak var tempIDLabel: UILabel!

    func update(traceData: TraceData) {
        tempIDLabel.text = traceData.tempId
        dataLabel.text = traceData.timestamp?.toString(format: "yyyy/MM/dd HH:mm:ss.SSS") ?? "Unknown Date"
        rssiLabel.text = traceData.rssi?.stringValue ?? "-"
        txPowerLabel.text = traceData.txPower?.stringValue ?? "-"
        selectionStyle = .none
    }
}

final class DebugDeepContactUserCell: UITableViewCell {
    @IBOutlet weak var tempIDLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    func update(text: String) {
        tempIDLabel.text = text
        tempIDLabel.textColor = .black
        timeLabel.isHidden = true
        accessoryType = .none
        selectionStyle = .none
        backgroundColor = .white
    }

    func update(deepContactUser: DeepContactUser) {
        tempIDLabel.text = deepContactUser.tempId
        timeLabel.isHidden = false
        timeLabel.text = "\(deepContactUser.startTime!.toString(format: "yyyy/MM/dd HH:mm:ss.SSS"))~\(deepContactUser.endTime!.toString(format: "yyyy/MM/dd HH:mm:ss.SSS"))"
        accessoryType = .disclosureIndicator
        selectionStyle = .default
        backgroundColor = .init(hex: 0xFF0000, alpha: 0.5)
    }
}
#endif
