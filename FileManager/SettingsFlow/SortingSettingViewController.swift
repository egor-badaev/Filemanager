//
//  SettingsViewController.swift
//  FileManager
//
//  Created by Egor Badaev on 12.04.2021.
//

import UIKit

class SortingSettingViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let tableView = UITableView()

        tableView.toAutoLayout()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self

        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Sorting style"

        setupSubviews()
    }

    private func setupSubviews() {
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension SortingSettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section == 0 else { return 0 }
        return SortingStyle.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self)),
              let sortingStyle = SortingStyle(rawValue: indexPath.row) else {
            return UITableViewCell()
        }

        cell.textLabel?.text = SortingStyle.label(for: sortingStyle)
        cell.accessoryType = Settings.shared.sorting == sortingStyle ? .checkmark : .none

        return cell
    }

}

extension SortingSettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard indexPath.section == 0,
              let sortingStyle = SortingStyle(rawValue: indexPath.row) else { return }

        let oldValue = Settings.shared.sorting
        Settings.shared.sorting = sortingStyle

        // allow for deselect animation to finish
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            tableView.reloadRows(at: [IndexPath(row: oldValue.rawValue, section: 0), IndexPath(row: sortingStyle.rawValue, section: 0)], with: .none)
        }
    }
}
