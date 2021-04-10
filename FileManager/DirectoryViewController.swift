//
//  DirectoryViewController.swift
//  FileManager
//
//  Created by Egor Badaev on 09.04.2021.
//

import UIKit
import EBFoundation
import PhotosUI

class DirectoryViewController: UIViewController, AlertPresenter {
    
    //MARK: - Properties
    var directory: Directory
    
    private var directoryName: String?
    
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
        directory = Directory(at: Directory.rootUrl)
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
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Add folder", style: .plain, target: self, action: #selector(addDirectory(_:)))
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
    @objc private func addDirectory(_ sender: Any) {
        print(type(of: self), #function, type(of: sender))
        
        directoryName = nil
        
        let alertController = UIAlertController(title: "Add directory", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Enter directory name"
            textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        }
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] action in
            guard let self = self,
                  let name = self.directoryName else { return }
            self.directory.createDirectory(name) { result in
                switch result {
                case .failure(let error):
                    self.presentErrorAlert(error.localizedDescription)
                case .success(let row):
                    DispatchQueue.main.async {
                        self.tableView.insertRows(at: [IndexPath(row: row, section: 0)], with: .top)
                    }
                }
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        navigationController?.present(alertController, animated: true, completion: nil)
    }
    
    @objc private func textFieldDidChange(_ sender: Any) {
        guard let textField = sender as? UITextField else {
            return
        }
        directoryName = textField.text
    }
    
    @objc private func addPhoto(_ sender: Any) {
        print(type(of: self), #function, type(of: sender))
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        // TODO: select multiple photos
        config.selectionLimit = 1

        let photoPickerVc = PHPickerViewController(configuration: config)
        photoPickerVc.delegate = self
        navigationController?.present(photoPickerVc, animated: true, completion: nil)
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
            cell.accessoryType = .none
        case .directory:
            cell.imageView?.image = UIImage(systemName: "folder")
            cell.accessoryType = .disclosureIndicator
        default:
            cell.imageView?.image = UIImage(systemName: "folder")
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let fsObject = directory.objects[indexPath.row]
        
        let alertTitle = "Удалить \(fsObject.type == .directory ? "папку" : "файл") \"\(fsObject.name)\"?"
        
        let alertController = UIAlertController(title: alertTitle, message: "Действие нельзя будет отменить", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Да, удалить", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            self.directory.deleteItem(at: indexPath.row) { result in
                switch result {
                case .failure(let error):
                    self.presentErrorAlert(error.localizedDescription)
                case .success(_):
                    tableView.deleteRows(at: [indexPath], with: .bottom)
                }
            }
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        navigationController?.present(alertController, animated: true, completion: nil)
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
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        let fsObject = directory.objects[indexPath.row]
        guard fsObject.type != .up else { return .none }
        return .delete
    }
}

// MARK: - PHPickerViewControllerDelegate
extension DirectoryViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)

        guard let result = results.first else { return }
        
        let provider = result.itemProvider
        guard let typeIdentifier = provider.registeredTypeIdentifiers.first else { return }
        
        provider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { [weak self] (url, error) in
            
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.presentErrorAlert(error.localizedDescription)
                }
                return
            }
            
            guard let url = url else { return }
            
            self.directory.moveItem(from: url) { result in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.presentErrorAlert(error.localizedDescription)
                    }
                case .success(let row):
                    DispatchQueue.main.async {
                        self.tableView.insertRows(at: [IndexPath(row: row, section: 0)], with: .top)
                    }
                }
            }
        }
    }
}
