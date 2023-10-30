//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Dinara on 30.10.2023.
//

import Foundation

final class ImageListService {
    static let shared = ImageListService()
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?

    

    func fetchPhotosNextPage(
        _ nextPage: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
//        let nextPage = lastLoadedPage == nil
//        ? 1
//        : lastLoadedPage!.number + 1
    }
}
