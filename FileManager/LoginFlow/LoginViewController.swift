//
//  LoginViewController.swift
//  FileManager
//
//  Created by Egor Badaev on 12.04.2021.
//

import UIKit
import EBFoundation

class LoginViewController: UIViewController, AlertPresenter {

    enum Mode {
        case registration
        case confirmation
        case signin
        case update
    }


    // MARK: - Constants
    private let segueIdentifier = "showApplication"
    private let controlHeight: CGFloat = 42.0
    private let margin: CGFloat = 32.0

    // MARK: - Password management
    private let password = Password()

    // MARK: - Subviews
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()

        scrollView.toAutoLayout()
        scrollView.addSubview(contentView)

        return scrollView
    }()

    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.toAutoLayout()
        contentView.addSubview(container)
        return contentView
    }()

    private lazy var container: UIStackView = {
        let container = UIStackView()
        container.toAutoLayout()
        container.axis = .vertical
        container.spacing = 32

        let labelContainer = innerContainer()
        [titleLabel, subtitleLabel].forEach {
            labelContainer.addArrangedSubview($0)
        }

        let controlContainer = innerContainer()
        [textField, button].forEach {
            controlContainer.addArrangedSubview($0)
        }

        [labelContainer, controlContainer].forEach {
            container.addArrangedSubview($0)
        }

        return container
    }()

    private let innerContainer: () -> UIStackView = {
        let container = UIStackView()
        container.toAutoLayout()
        container.axis = .vertical
        container.spacing = 10
        return container
    }

    private let titleLabel: UILabel = {
        let titleLabel = UILabel()

        titleLabel.toAutoLayout()
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .label

        return titleLabel
    }()

    private let subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()

        subtitleLabel.toAutoLayout()
        subtitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textColor = .secondaryLabel

        return subtitleLabel
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.toAutoLayout()
        textField.isSecureTextEntry = true
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.heightAnchor.constraint(equalToConstant: controlHeight).isActive = true
        textField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        return textField
    }()

    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.toAutoLayout()
        button.setTitleColor(.white, for: .normal)

        let backgroundImage = UIColor.systemBlue.image()
        button.setBackgroundImage(backgroundImage, for: .normal)
        button.setBackgroundImage(backgroundImage.alpha(0.8), for: .highlighted)
        button.setBackgroundImage(backgroundImage.alpha(0.8), for: .selected)

        button.layer.cornerRadius = 4.0
        button.layer.masksToBounds = true

        button.heightAnchor.constraint(equalToConstant: controlHeight).isActive = true

        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)

        return button
    }()

    // MARK: - Properties
    // TODO: Move to view model
    private var mode: Mode = .registration {
        didSet {
            titleLabel.text = screenTitle
            subtitleLabel.text = subtitle
            button.setTitle(buttonTitle, for: .normal)
        }
    }

    private var originalMode: Mode

    private var screenTitle: String {
        switch mode {
        case .registration,
             .confirmation:
            return "Registration"
        case .signin:
            return "Sign in"
        case .update:
            return "Change password"
        }
    }

    private var subtitle: String {
        switch mode {
        case .registration,
             .update:
            return "Come up with a new password"
        case .confirmation:
            return "Type that password once again"
        case .signin:
            return "Enter your password"
        }
    }

    private var buttonTitle: String {
        switch mode {
        case .registration:
            return "Create password"
        case .update:
            return "Change password"
        case .confirmation:
            return "Confirm password"
        case .signin:
            return "Login"
        }

    }

    private var passwordInput: String = ""
    private var initialPasswordInput: String = ""

    // MARK: - Initializers

    required init?(coder: NSCoder) {
        originalMode = .registration
        super.init(coder: coder)
        setLoginMode()
    }

    init(for mode: Mode) {
        originalMode = .update
        super.init(nibName: nil, bundle: nil)
        defer {
            self.mode = mode
        }
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print(type(of: self), #function)
        setupUI()
    }

    // MARK: - UI

    func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            container.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            container.widthAnchor.constraint(equalToConstant: 300)
        ])

    }

    private func setLoginMode() {
        if password.isSet {
            mode = .signin
        } else {
            mode = .registration
        }
    }

    func animateModeSwitch(to mode: Mode) {
        UIView.animate(withDuration: 0.3) {
            self.subtitleLabel.alpha = 0
            self.button.titleLabel?.alpha = 0
        } completion: { _ in
            self.mode = mode
            UIView.animate(withDuration: 0.3) {
                self.subtitleLabel.alpha = 1
                self.button.titleLabel?.alpha = 1
            }
        }
    }

    // MARK: - Actions

    @objc private func textFieldEditingChanged(_ sender: UITextField) {
        print(type(of: self), #function)
        guard let password = sender.text else { return }
        if password.count > 4 {
            presentErrorAlert("Password should be no longer than 4 characters!")
            textField.text = String(password.prefix(4))
        }

        passwordInput = password

    }

    @objc private func buttonTapped(_ sender: UIButton) {

        guard passwordInput.count > 1 else {
            presentErrorAlert("Password cannot be empty!")
            return
        }

        switch mode {
        case .registration,
             .update:
            initialPasswordInput = passwordInput
            textField.text = nil
            print("passwordInput after setting textField to nil: \(passwordInput)")
            mode = .confirmation
        case .confirmation:
            if passwordInput == initialPasswordInput {
                password.save(passwordInput) { (success, error) in
                    guard success,
                          error == nil else {
                        if let error = error {
                            self.presentErrorAlert(error.localizedDescription)
                        }
                        return
                    }
                    self.performLogin()
                }
            } else {
                presentErrorAlert("Passwords mimatch!")
                passwordInput = ""
                initialPasswordInput = ""
                textField.text = nil
                mode = .registration
                return
            }
        case .signin:
            guard password.isValid(passwordInput) else {
                presentErrorAlert("Wrong password. Try again")
                return
            }
            performLogin()
        }
    }

    private func performLogin() {
        guard originalMode != .update else {
            navigationController?.popViewController(animated: true)
            return
        }
        navigationController?.performSegue(withIdentifier: segueIdentifier, sender: nil)
    }
}
