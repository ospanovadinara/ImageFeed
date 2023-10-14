//
//  UserResult.swift
//  ImageFeed
//
//  Created by Dinara on 14.10.2023.
//

import UIKit

struct UserResult: Codable {
    let profileImage: ImageURL
}

struct ImageURL: Codable {
    let small: String
}
