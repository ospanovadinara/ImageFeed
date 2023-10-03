//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Dinara on 03.10.2023.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    let access_token: String
    let token_type: String
    let scope: String
    let created_at: Int
}
