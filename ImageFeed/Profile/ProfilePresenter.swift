//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Dinara on 11.11.2023.
//

import Foundation
import WebKit

// MARK: - ProfilePresenterProtocol
public protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewWillAppear()
    func viewDidLoad()
    func clearAccount()
}

// MARK: - ProfilePresenter Class
final class ProfilePresenter {
    weak var view: ProfileViewControllerProtocol?
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
}

extension ProfilePresenter: ProfilePresenterProtocol {
    func viewDidLoad() {
        updateAvatar()
    }

    func viewWillAppear() {
        guard let profile = profileService.profile else {
            assertionFailure("No saved profile")
            return
        }
        view?.updateProfileDetails(profile)
    }

    func clearAccount() {
        clearCookies()
        goToSplashViewController()
    }
}

private extension ProfilePresenter {
    func updateAvatar() {
        if let url = profileImageService.avatarURL {
            view?.updateAvatar(url: url)
        }
    }

    func clearCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes,
                                                        for: [record],
                                                        completionHandler: {})
            }
        }
    }

    func goToSplashViewController() {
        let viewController = SplashViewController()
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid Configuration")
            return
        }
        window.rootViewController = viewController
    }
}
