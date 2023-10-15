//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Dinara on 11.09.2023.
//

import UIKit
import SnapKit
import Kingfisher

final class ProfileViewController: UIViewController {
    private let profileService = ProfileService.shared
    private var authToken = OAuth2TokenStorage.shared.token
    private var profileImageServiceObserver: NSObjectProtocol?
    private var profile: Profile?
    private let profileImageService = ProfileImageService.shared

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
        fetchProfile()
        profileImageServiceObserver = NotificationCenter.default
                   .addObserver(
                       forName: ProfileImageService.DidChangeNotification,
                       object: nil,
                       queue: .main
                   ) { [weak self] _ in
                       guard let self = self else { return }
                       self.updateAvatar()
                   }
               updateAvatar()
        updateAvatar()
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

    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let _ = URL(string: profileImageURL)
        else { return }
        let downloader = ImageDownloader.default
        let imageView = UIImageView()
        guard let username = profile?.username else { return }
        profileImageService.fetchProfileImageURL(username: username) { _ in
        }
        let imageUrlPath = "https://unsplash.com/\(username)/profile"
        let imageUrl = URL(string: imageUrlPath)

        let processor = RoundCornerImageProcessor(cornerRadius: 20)
        imageView.kf.indicatorType = .activity

        imageView.kf.setImage(with: imageUrl,
                              placeholder: UIImage(named: "placeholder.jpeg"),
                              options: [
                                .processor(processor)
                              ]) { result in
                                  switch result {
                                  case .success(let value):
                                      print(value.image)
                                      print(value.cacheType)
                                      print(value.source)
                                  case .failure(let error):
                                      print(error)
                                  }
                              }

        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache()
    }

    private func fetchProfile() {
        profileService.fetchProfile(authToken ?? "") { result in
            switch result {
            case .success(let profile):
                self.updateProfileDetails(profile: profile)
            case .failure(let error):
                print("Error fetching profile: \(error)")
            }
        }
    }

    private func updateProfileDetails(profile: Profile) {
            nameLabel.text = profile.name
            userNameLabel.text = profile.loginName
            statusLabel.text = profile.bio
    }

    // MARK: - Actions
    @objc private func exitButtonDidTap() {
        print("Exit button tapped")
    }
}
