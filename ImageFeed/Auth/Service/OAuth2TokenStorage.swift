//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Dinara on 03.10.2023.
//

import Foundation

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()

    private let userDefaults = UserDefaults.standard
    private let tokenKey = "ImageFeedOAuth2Token"

    var token: String? {
        get {
            return userDefaults.string(forKey: tokenKey)
        }
        set {
            userDefaults.set(newValue, forKey: tokenKey)
        }
    }
}
