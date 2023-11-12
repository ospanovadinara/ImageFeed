//
//  Photo.swift
//  ImageFeed
//
//  Created by Dinara on 30.10.2023.
//

import Foundation

public struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let fullImageUrl: String
    var isLiked: Bool
}
