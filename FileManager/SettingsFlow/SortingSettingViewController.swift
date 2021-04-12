//
//  SettingsViewController.swift
//  FileManager
//
//  Created by Egor Badaev on 12.04.2021.
//

import UIKit

class SortingSettingViewController: UIViewController {

    private var sortingType = 0 {
        didSet {
            tableView.reloadRows(at: [IndexPath(row: oldValue, section: 0), IndexPath(row: sortingType, section: 0)], with: .none)
        }
    }

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
        configure()

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

    private func configure() {
        sortingType = 1
    }
}

extension SortingSettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section == 0 else { return 0 }
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self)) else {
            return UITableViewCell()
        }

        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Windows"
        case 1:
            cell.textLabel?.text = "macOS / Linux"
        default:
            cell.textLabel?.text = nil
        }

        cell.accessoryType = sortingType == indexPath.row ? .checkmark : .none

        return cell
    }

}

extension SortingSettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section == 0 else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.sortingType = indexPath.row
        }
    }
}
