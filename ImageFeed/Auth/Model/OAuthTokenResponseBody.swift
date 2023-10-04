//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Dinara on 03.10.2023.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
}
