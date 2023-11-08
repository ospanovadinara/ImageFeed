//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Dinara on 11.09.2023.
//

import UIKit
import SnapKit
import Kingfisher
import WebKit
import SwiftKeychainWrapper


final class ProfileViewController: UIViewController {
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private let profileImageService = ProfileImageService.shared
    private var profile: Profile?

    // MARK: - UI
    private lazy var avatarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "avatar")
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true

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
        view.backgroundColor = UIColor(named: "YP Black")
        setupViews()
        setupConstraints()

        if let url = profileImageService.avatarURL {
            updateAvatar(url: url)
        }

        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                self?.updateAvatar(notification: notification)
            }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let profile = profileService.profile {
            updateProfileDetails(profile: profile)
        } else {
            assertionFailure("No saved profile")
        }
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
            make.size.equalTo(70)
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

    @objc
    private func updateAvatar(notification: Notification) {
        guard
            isViewLoaded,
            let userInfo = notification.userInfo,
            let profileImageURL = userInfo["URL"] as? String,
            let url = URL(string: profileImageURL)
        else { return }
        updateAvatar(url: url)
    }

    private func updateAvatar(url: URL) {
        avatarImage.kf.indicatorType = .activity
        let processor = RoundCornerImageProcessor(cornerRadius: 61)
        avatarImage.kf.setImage(with: url,
                                options: [
                                .processor(processor)])
    }

    private func updateProfileDetails(profile: Profile) {
            nameLabel.text = profile.name
            userNameLabel.text = profile.loginName
            statusLabel.text = profile.bio
    }

    // MARK: - Actions
    @objc private func exitButtonDidTap() {
        let alert = UIAlertController(title: "Пока, пока!",
                                      message: "Уверены что хотите выйти?",
                                      preferredStyle: .alert)

        let approveAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self = self else { return }
            KeychainWrapper.standard.removeAllKeys()
            self.clean()
            self.goToSplashViewController()
        }

        let cancelAction = UIAlertAction(title: "Нет", style: .cancel)

        alert.addAction(approveAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    private func clean() {
       HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
       WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
          records.forEach { record in
             WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, 
                                                     for: [record],
                                                     completionHandler: {})
          }
       }
    }

    private func goToSplashViewController() {
        let viewController = SplashViewController()
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        window.rootViewController = viewController
    }
}
