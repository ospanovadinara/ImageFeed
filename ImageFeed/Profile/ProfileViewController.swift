//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Dinara on 11.09.2023.
//

import UIKit
import SnapKit

final class ProfileViewController: UIViewController {

    // MARK: - UI
    private lazy var avatarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "avatar")
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.textColor = UIColor.white
        return label
    }()

    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(named: "YP Gray")
        return label
    }()

    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.white
        return label
    }()

    private lazy var labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()

    private lazy var exitButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "exit_button"), for: .normal)
        button.addTarget(self, action: #selector(exitButtonDidTap), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }

    // MARK: - Setup Views
    private func setupViews() {
        [nameLabel,
         userNameLabel,
         statusLabel
        ].forEach { labelStackView.addArrangedSubview($0) }

        [avatarImage,
        exitButton,
         labelStackView
        ].forEach { view.addSubview($0) }
    }

    // MARK: - Setup Constraints
    private func setupConstraints() {
        avatarImage.snp.makeConstraints { make in
            make.size.equalTo(76)
            make.top.equalToSuperview().offset(76)
            make.leading.equalToSuperview().offset(16)
        }

        exitButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.trailing.equalToSuperview().offset(-24)
            make.size.equalTo(44)
        }

        labelStackView.snp.makeConstraints { make in
            make.top.equalTo(avatarImage.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
        }
    }

    // MARK: - Actions
    @objc private func exitButtonDidTap() {
        print("Exit button tapped")
    }
}
