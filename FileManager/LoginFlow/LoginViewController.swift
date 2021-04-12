//
//  LoginViewController.swift
//  FileManager
//
//  Created by Egor Badaev on 12.04.2021.
//

import UIKit
import EBFoundation

class LoginViewController: UIViewController {

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

        setupUI()
    }

    // MARK: - UI

    func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            container.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 300),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            container.widthAnchor.constraint(equalToConstant: 300)
        ])

    }

    private func setLoginMode() {
        // TODO: Check if password has been set
        mode = .registration
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

    }

    @objc private func buttonTapped(_ sender: UIButton) {
        guard originalMode != .update else {
            navigationController?.popViewController(animated: true)
            return
        }
        navigationController?.performSegue(withIdentifier: segueIdentifier, sender: sender)
    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == segueIdentifier else { return }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
