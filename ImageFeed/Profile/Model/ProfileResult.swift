//
//  ProfileResult.swift
//  ImageFeed
//
//  Created by Dinara on 11.10.2023.
//

import Foundation

struct ProfileResult: Codable {
    let id: String
    let updatedAt: String
    let username: String
    let name: String
    let firstName: String
    let lastName: String
    let instagramUsername: String?
    let twitterUsername: String?
    let portfolioUrl: String?
    let bio: String?
    let location: String?
    let totalLikes: Int
    let totalPhotos: Int
    let totalCollections: Int
    let followedByUser: Bool
    let followersCount: Int
    let followingCount: Int
    let downloads: Int

    struct Social: Codable {
        let instagramUsername: String
        let portfolioUrl: String
        let twitterUsername: String
    }

    let social: Social

    struct ProfileImage: Codable {
        let small: String
        let medium: String
        let large: String
    }

    let profileImage: ProfileImage

    struct Badge: Codable {
        let title: String
        let primary: Bool
        let slug: String
        let link: String
    }

    let badge: Badge

    struct Links: Codable {
        let selfLink: String
        let html: String
        let photos: String
        let likes: String
        let portfolio: String
    }

    let links: Links
}

enum CodingKeys: String, CodingKey {
    case selfLink = "self"
}
