//
//  SettingsViewController.swift
//  FileManager
//
//  Created by Egor Badaev on 12.04.2021.
//

import UIKit

class SettingsViewController: UIViewController {

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

        title = "Settings"

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func filesizeSwitchToggle(_ sender: UISwitch) {
        print("toggle")
    }
    
}

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section == 0 else { return 0 }
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .value1, reuseIdentifier: String(describing: UITableViewCell.self))
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Sorting style"
            cell.detailTextLabel?.text = "Windows"
            cell.accessoryView = nil
            cell.accessoryType = .disclosureIndicator
        case 1:
            cell.textLabel?.text = "Display file size"
            cell.detailTextLabel?.text = nil
            let filesizeSwitch = UISwitch()
            filesizeSwitch.setOn(true, animated: false)
            filesizeSwitch.addTarget(self, action: #selector(filesizeSwitchToggle(_:)), for: .valueChanged)
            cell.accessoryView = filesizeSwitch
            cell.accessoryType = .none
        case 2:
            cell.textLabel?.text = "Change password"
            cell.detailTextLabel?.text = nil
            cell.accessoryView = nil
            cell.accessoryType = .disclosureIndicator
        default:
            cell.textLabel?.text = nil
            cell.detailTextLabel?.text = nil
            cell.accessoryType = .none
            cell.accessoryView = nil

        }
        return cell
    }

}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            let settingsVc = SortingSettingViewController()
            navigationController?.pushViewController(settingsVc, animated: true)
        case 2:
            let loginVc = LoginViewController(for: .update)
            navigationController?.pushViewController(loginVc, animated: true)
        default:
            return
        }
    }
}
