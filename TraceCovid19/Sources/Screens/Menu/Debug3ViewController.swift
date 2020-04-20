//
//  Debug3ViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/17.
//

import UIKit
import NVActivityIndicatorView

#if DEBUG
// 自身のTempIDリスト表示
final class Debug3ViewController: UIViewController, NVActivityIndicatorViewable {
    @IBOutlet weak var tablewView: UITableView!

    var tempId: TempIdService!
    var positiveContact: PositiveContactService!

    private let refreshControl = UIRefreshControl()

    private var tempUserIDs: [TempIdStruct] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tablewView.delegate = self
        tablewView.dataSource = self

        tablewView.reloadData()

        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tablewView.refreshControl = refreshControl
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }

    @IBAction func tappedDelete(_ sender: Any) {
        tempId.deleteAll()
        tempUserIDs.removeAll()
        tablewView.reloadData()
    }

    @objc
    func refresh() {
        startAnimating(type: .circleStrokeSpin)
        // 再度陽性者情報をリセットしてとりなおす
        tempId.fetchTempIDs { [weak self] _ in
            self?.stopAnimating()
            guard let sSelf = self else { return }
            self?.refreshControl.endRefreshing()
            self?.tempUserIDs = sSelf.tempId.tempIDs
            self?.tablewView.reloadData()
        }
    }
}

extension Debug3ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let uuid = tempUserIDs[indexPath.row].tempId
        showAlertWithCancel(
            message: "\(uuid) \nこのIDを一時的に陽性者として扱いますか？",
            okAction: { _ in
                self.positiveContact.appendPositiveContact(uuid: uuid)
            }
        )
    }
}

extension Debug3ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempUserIDs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DebugTempUserIdCell", for: indexPath) as? DebugTempUserIdCell else {
            return UITableViewCell()
        }
        cell.update(tempId: tempUserIDs[indexPath.row])
        return cell
    }
}

final class DebugTempUserIdCell: UITableViewCell {
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!

    func update(tempId: TempIdStruct) {
        uuidLabel.text = tempId.tempId
        let startDate = tempId.startTime
        startLabel.text = startDate.toString(format: "yyyy/MM/dd HH:mm:ss.SSS")
        let endDate = tempId.endTime
        endLabel.text = endDate.toString(format: "yyyy/MM/dd HH:mm:ss.SSS")

        let now = Date()
        if now >= endDate {
            backgroundColor = .gray
        } else if startDate <= now && now < endDate {
            backgroundColor = .green
        } else {
            backgroundColor = .white
        }
    }
}
#endif
