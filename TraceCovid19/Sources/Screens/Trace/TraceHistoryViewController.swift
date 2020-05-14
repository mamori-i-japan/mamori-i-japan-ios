//
//  TraceHistoryViewController.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/26.
//

import UIKit
import NVActivityIndicatorView

final class TraceHistoryViewController: UIViewController, NVActivityIndicatorViewable {
    @IBOutlet weak var tableView: UITableView!

    var deepContactCheck: DeepContactCheckService!
    private var deepContactUsers: [DeepContactUser] = [] {
        didSet {
            sectionData.removeAll()

            sectionData = deepContactUsers.reduce(into: [SectionData]()) { section, deepContactUser in
                guard var last = section.last else {
                    // 空の場合
                    return section.append(SectionData(section: deepContactUser.dateForHeader, data: [deepContactUser]))
                }

                if last.section == deepContactUser.dateForHeader {
                    // 同じセクションなら、データに追加して上書き
                    last.data.append(deepContactUser)
                    section[section.count - 1] = last
                } else {
                    return section.append(SectionData(section: deepContactUser.dateForHeader, data: [deepContactUser]))
                }
            }
        }
    }
    private var sectionData: [SectionData] = []

    struct SectionData {
        let section: String
        var data: [DeepContactUser]
    }

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

extension TraceHistoryViewController: NavigationBarHiddenApplicapable {
}

extension TraceHistoryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionData.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionData[section].data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TraceHistoryTableViewCell = tableView.dequeue(indexPath: indexPath)
        let isLastCell = sectionData[indexPath.section].data.count - 1 == indexPath.row
        cell.update(deepContactUser: sectionData[indexPath.section].data[indexPath.row], isLastCell: isLastCell)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TraceHistorySectionHeaderView.hight
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // フッターサイズ調整
        return 14.0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = TraceHistorySectionHeaderView(frame: .init(x: 0, y: 0, width: view.bounds.width, height: TraceHistorySectionHeaderView.hight))
        headerView.update(dateString: sectionData[section].section)
        return headerView
    }
}

extension TraceHistoryViewController: UITableViewDelegate {
}

final class TraceHistoryTableViewCell: UITableViewCell, NibInstantiatable {
    @IBOutlet weak var label: BaseLabel!
    @IBOutlet weak var separatorViewLeadingConstraint: NSLayoutConstraint!

    private static let defaultSeparatorViewLeadingValue: CGFloat = 16.0

    func update(deepContactUser: DeepContactUser, isLastCell: Bool) {
        let timeDuration = "\(deepContactUser.startTime.toString(format: "HH：mm"))〜\(deepContactUser.endTime.toString(format: "HH：mm"))"
        label.text = timeDuration

        separatorViewLeadingConstraint.constant = isLastCell ? 0.0 : type(of: self).defaultSeparatorViewLeadingValue
    }
}

private extension DeepContactUser {
    var dateForHeader: String {
        return startTime.toString(format: "yyyy年 M月 d日")
    }
}
