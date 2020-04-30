//
//  TraceHistoryViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/26.
//

import UIKit
import NVActivityIndicatorView

final class TraceHistoryViewController: UIViewController, NavigationBarHiddenApplicapable, NVActivityIndicatorViewable {
    @IBOutlet weak var tableView: UITableView!

    var deepContactCheck: DeepContactCheckService!
    private var deepContactUsers: [DeepContactUser] = []

    // TODO: ひまたぎの考慮

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetchDeepContact { [weak self] in
            self?.tableView.reloadData()
        }
    }

    private func fetchDeepContact(completion: @escaping () -> Void) {
        // セルから直接都度読み込むとデータ不整合のもちになるので、いったんプロパティに保持する

        startAnimating(type: .circleStrokeSpin)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.deepContactUsers = sSelf.deepContactCheck.getDeepContactUsers()

            DispatchQueue.main.async { [weak self] in
                self?.stopAnimating()
                completion()
            }
        }
    }
}

extension TraceHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deepContactUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TraceHistoryTableViewCell = tableView.dequeue(indexPath: indexPath)
        cell.update(deepContactUser: deepContactUsers[indexPath.row])
        return cell
    }
}

extension TraceHistoryViewController: UITableViewDelegate {
}

final class TraceHistoryTableViewCell: UITableViewCell, NibInstantiatable {
    @IBOutlet weak var label: BaseLabel!

    func update(deepContactUser: DeepContactUser) {
        let date = "\(deepContactUser.startTime.toString(format: "yyyy年M月d日"))"
        let timeDuration = "\(deepContactUser.startTime.toString(format: "HH:mm"))〜\(deepContactUser.endTime.toString(format: "HH:mm"))"
        label.text = "\(date)\n\(timeDuration)"
    }
}
