//
//  ProfileViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Dinara on 12.11.2023.
//

import Foundation
import ImageFeed
import UIKit

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ImageFeed.ProfilePresenterProtocol?

    var viewDidUpdateAvatar: Bool = false
    var viewDidUpdateProfileDetails: Bool = false

    var nameLabel = UILabel()
    var userNameLabel = UILabel()
    var statusLabel = UILabel()

    func updateProfileDetails(_ profile: ImageFeed.Profile?) {
        viewDidUpdateProfileDetails = true
        if let profile {
            nameLabel.text = profile.name
            userNameLabel.text = profile.loginName
            statusLabel.text = profile.bio
        }
    }
    
    func updateAvatar(url: URL) {
        viewDidUpdateAvatar = true
    }
}
