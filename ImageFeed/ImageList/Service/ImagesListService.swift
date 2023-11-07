//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Dinara on 30.10.2023.
//

import Foundation
import Kingfisher

final class ImageListService {
    static let shared = ImageListService()
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    let perPage = 10

    private init(
        photos: [Photo] = [],
        lastLoadedPage: Int? = nil
    ) {
        self.photos = photos
        self.lastLoadedPage = lastLoadedPage
    }

    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        guard let request = makeFetchPhotosRequest(page: nextPage) else {
            assertionFailure("Invalid request")
            return
        }
        let session = URLSession.shared
        let task = session.objectTask(for: request) { [weak self]
            (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let photoResult):
                    let photo = photoResult.map { photoResult in
                        return Photo(
                            id: photoResult.id,
                            size: CGSize(width: photoResult.width, height: photoResult.height),
                            createdAt: Date(),
                            welcomeDescription: photoResult.description,
                            thumbImageURL: photoResult.urls.thumb,
                            largeImageURL: photoResult.urls.full,
                            fullImageUrl: photoResult.urls.full,
                            isLiked: photoResult.likedByUser
                        )
                    }
                    self.photos.append(contentsOf: photo)
                    self.lastLoadedPage = nextPage
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(
                            name: ImageListService.DidChangeNotification,
                            object: self
                        )
                        UIBlockingProgressHUD.dismiss()
                    }
                case .failure(let error):
                    print("Failed to fetch photos: \(error.localizedDescription)")
                    UIBlockingProgressHUD.dismiss()
                }
            }
        }
        task.resume()
    }
}

extension ImageListService {
    private func makeFetchPhotosRequest(page: Int) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(page)&per_page=\(perPage)"),
              let token = OAuth2TokenStorage.shared.token else {
            fatalError("Failed to create URL")
        }

        var request = URLRequest(url: url)

        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }
}

extension ImageListService {

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping(Result<Void, Error>) -> Void) {

        guard let request = makeFetchLikeRequest(photoId: photoId, isLike: isLike) else {
            assertionFailure("Invalid request")
            return
        }
        let session = URLSession.shared
        let task = session.objectTask(for: request) { [weak self]
            (result: Result<LikeResponse, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let likeResponse):
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        self.photos[index].isLiked = likeResponse.photo.likedByUser
                    }
                    completion(.success(()))
                case .failure(let error):
                    print("Failed to fetch likes: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }


    private func makeFetchLikeRequest(photoId: String, isLike: Bool) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like"),
              let token = OAuth2TokenStorage.shared.token else {
            fatalError("Failed to create URL")
        }

        var request = URLRequest(url: url)

        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }
}


