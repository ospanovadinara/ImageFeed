//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Dinara on 03.10.2023.
//

import UIKit

final class SplashViewController: UIViewController {
    // MARK: - ShowAuthenticationScreenSegueIdentifier
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"

    private let profileService = ProfileService.shared

    private let oauth2Service = OAuth2Service.shared
    private var oauth2TokenStorage = OAuth2TokenStorage.shared

    private var profile: Profile?
    private let alertPresenter = AlertPresenter()
    private var wasChecked: Bool = false

//    private let profileImageService = ProfileImageService.shared


    // MARK: - Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let token = oauth2TokenStorage.token {
            profileService.fetchProfile(token) { result in
                switch result {
                case .success(_ ):
                    self.switchToTabBarController()
                case .failure(let error):
                    self.showAlert(error: error)
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
        guard let authViewController = viewController as? AuthViewController else { return }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }


    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
//        fetchProfileImageURL()
    }

//    private func fetchProfileImageURL() {
//        guard let username = profile?.username else { return }
//
//        profileImageService.fetchProfileImageURL(username: username) { _ in
//        }
//    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(ShowAuthenticationScreenSegueIdentifier)") }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
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
                self?.fetchProfile(token, completion: {
                    UIBlockingProgressHUD.dismiss()
                })
            case .failure(let error):
                self?.showAlert(error: error)
                UIBlockingProgressHUD.dismiss()
            }
        }
    }

    private func fetchProfile(_ token: String, completion: @escaping () -> Void) {
        profileService.fetchProfile(token, completion: { [weak self] profileResult in
            switch profileResult {
            case .success(_):
                self?.switchToTabBarController()
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                self?.showAlert(error: error)
            }
            completion()
        })
    }

    private func showAlert(error: Error) {
        alertPresenter.showAlert(title: "Что-то пошло не так :(",
                                 message: "Не удалось войти в систему, \(error.localizedDescription)") {
            self.performSegue(withIdentifier: self.ShowAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
}



