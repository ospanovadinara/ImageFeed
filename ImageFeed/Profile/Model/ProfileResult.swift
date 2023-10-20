//
//  ProfileResult.swift
//  ImageFeed
//
//  Created by Dinara on 11.10.2023.
//

import Foundation

struct ProfileResult: Codable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    let profileImage: ProfileImage?
}

struct ProfileImage: Codable {
    let small: String?
    let medium: String?
    let large: String?
}



