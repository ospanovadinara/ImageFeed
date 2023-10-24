//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Dinara on 03.10.2023.
//

import UIKit
import SnapKit

final class SplashViewController: UIViewController {

    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let oauth2Service = OAuth2Service.shared
    private var oauth2TokenStorage = OAuth2TokenStorage.shared

    private var profile: Profile?
    private let alertPresenter = AlertPresenter()


    // MARK: - UI

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "auth_screen_logo")
        imageView.translatesAutoresizingMaskIntoConstraints = false 
        return imageView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let token = oauth2TokenStorage.token {
            profileService.fetchProfile(token) { [weak self] result in
                switch result {
                case .success(_ ):
                    self?.switchToTabBarController()
                    if let username = self?.profileService.profile?.username {
                        self?.profileImageService.fetchProfileImageURL(username: username) { result in
                            switch result {
                            case .success(let imageUrl):
                                print("Avatar URL: \(imageUrl)")
                            case .failure(let error):
                                self?.showAlert(error: error)
                            }
                        }
                    }
                case .failure(let error):
                    self?.showAlert(error: error)
                }
            }
        } else {
            showAuthController()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func showAuthController() {
        let storyboard = UIStoryboard(name: "Main",
                                      bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "AuthViewControllerID")
        guard let authViewController = viewController as? AuthViewController else {
            fatalError("Invalid AuthViewController Configuration")}
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }


    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }

    private func setupViews() {
        view.addSubview(logoImageView)
        view.backgroundColor = UIColor(named: "YP black")
    }

    private func setupConstraints() {
        logoImageView.snp.makeConstraints { make in
            make.size.equalTo(60)
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
}

// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }

    private func fetchOAuthToken(_ code: String) {
        UIBlockingProgressHUD.show()
        oauth2Service.fetchOAuthToken(code) { [weak self] authResult in
            switch authResult {
            case .success(let token):
                self?.fetchProfile(token) { [weak self] in
                    if let username = self?.profileService.profile?.username {
                        self?.profileImageService.fetchProfileImageURL(username: username) { result in
                            switch result {
                            case .success(let imageUrl):
                                print("Avatar URL: \(imageUrl)")
                            case .failure(let error):
                                self?.showAlert(error: error)
                            }
                        }
                    }
                    UIBlockingProgressHUD.dismiss()
                }
            case .failure(let error):
                self?.showAlert(error: error)
                UIBlockingProgressHUD.dismiss()
            }
        }
    }

    private func fetchProfile(_ token: String, completion: @escaping () -> Void) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token, completion: { [weak self] profileResult in
            switch profileResult {
            case .success(_):
                self?.switchToTabBarController()
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                self?.showAlert(error: error)
            }
            completion()
        })
    }

    private func showAlert(error: Error) {
        alertPresenter.showAlert(title: "Что-то пошло не так :(",
                                 message: "Не удалось войти в систему",
                                 preferredStyle: .alert)
    }
}




