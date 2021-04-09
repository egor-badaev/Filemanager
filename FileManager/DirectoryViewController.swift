//
//  DirectoryViewController.swift
//  FileManager
//
//  Created by Egor Badaev on 09.04.2021.
//

import UIKit
import EBFoundation

class DirectoryViewController: UIViewController {
    
    //MARK: - Properties
    var directory: Directory
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        
        tableView.toAutoLayout()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        
        return tableView
    }()

    // MARK: - Initializers
    required init?(coder: NSCoder) {
        directory = Directory(at: Directory.defaultUrl)
        super.init(coder: coder)
        title = "Documents"
    }
    
    init(title: String, url: URL) {
        directory = Directory(at: url)
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        print(type(of: self), #function)
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Add folder", style: .plain, target: self, action: #selector(addFolder(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add photo", style: .plain, target: self, action: #selector(addPhoto(_:)))
        
        setupSubviews()
    }
    
    // MARK: - Private methods
    private func setupSubviews() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }


    // MARK: - Actions
    @objc private func addFolder(_ sender: Any) {
        print(type(of: self), #function, type(of: sender))
    }
    
    @objc private func addPhoto(_ sender: Any) {
        print(type(of: self), #function, type(of: sender))
    }
}

//MARK: - UITableViewDataSource
extension DirectoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        directory.objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self)) else {
            return UITableViewCell()
        }
        
        let fileSystemObject = directory.objects[indexPath.row]
        cell.textLabel?.text = fileSystemObject.name
        
        switch fileSystemObject.type {
        case .file:
            cell.imageView?.image = UIImage(systemName: "photo")
        case .directory:
            cell.imageView?.image = UIImage(systemName: "folder")
            cell.accessoryType = .disclosureIndicator
        default:
            cell.imageView?.image = UIImage(systemName: "folder")
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension DirectoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let fsObject = directory.objects[indexPath.row]
        if fsObject.type == .directory {
            let vc = DirectoryViewController(title: fsObject.name, url: fsObject.url)
            navigationController?.pushViewController(vc, animated: true)
        } else if fsObject.type == .up {
            navigationController?.popViewController(animated: true)
        }
        
    }
}
