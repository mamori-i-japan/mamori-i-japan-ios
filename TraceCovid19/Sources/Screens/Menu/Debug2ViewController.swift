//
//  Debug2ViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/16.
//

import UIKit

#if DEBUG
/// 陽性者リスト表示
final class Debug2ViewController: UIViewController {
    @IBOutlet weak var tablewView: UITableView!

    var positiveContact: PositiveContactService!

    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        tablewView.delegate = self
        tablewView.dataSource = self

        tablewView.reloadData()

        refreshControl.addTarget(self, action: #selector(refreshPositiveContacts), for: .valueChanged)
        tablewView.refreshControl = refreshControl
    }

    @objc
    func refreshPositiveContacts() {
        // 再度陽性者情報をリセットしてとりなおす
        positiveContact.resetGeneration()
        positiveContact.load { [weak self] _ in
            self?.refreshControl.endRefreshing()
            self?.tablewView.reloadData()
        }
    }
}

extension Debug2ViewController: UITableViewDelegate {
}

extension Debug2ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return positiveContact.positiveContacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DebugPositiveContactCell", for: indexPath) as? DebugPositiveContactCell else {
            return UITableViewCell()
        }
        cell.update(positiveContact: positiveContact.positiveContacts[indexPath.row])
        return cell
    }
}

final class DebugPositiveContactCell: UITableViewCell {
    @IBOutlet weak var uuidLabel: UILabel!

    func update(positiveContact: PositiveContact) {
        uuidLabel.text = positiveContact.uuid
    }
}
#endif
