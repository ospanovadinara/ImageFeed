//
//  AuthConfiguration.swift
//  ImageFeed
//
//  Created by Dinara on 02.10.2023.
//

import Foundation

let AccessKey = "FrneTot1kTvW9ByNnXAgglh6JPr_lZ-tGgNXN1z3p_8"
let SecretKey = "H6EYmUCWlNzrSQD2JQ0ZnoSXNw58aIl9A72M8QSj0bA"
let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
let AccessScope = "public+read_user+write_likes+write_user"
let DefaultBaseURL = URL(string: "https://api.unsplash.com")!
let TokenKey = "ImageFeedOAuth2Token"

fileprivate let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String

    init(accessKey: String, 
         secretKey: String,
         redirectURI: String,
         accessScope: String,
         defaultBaseURL: URL,
         authURLString: String)
    {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }

    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: AccessKey,
                                 secretKey: SecretKey,
                                 redirectURI: RedirectURI,
                                 accessScope: AccessScope,
                                 defaultBaseURL: DefaultBaseURL,
                                 authURLString: UnsplashAuthorizeURLString)
    }
}

