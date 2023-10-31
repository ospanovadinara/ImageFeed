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
    private var nextPage: Int?
    let perPage = 10

    private init(
        photos: [Photo] = [],
        lastLoadedPage: Int? = nil,
        nextPage: Int? = nil
    ) {
        self.photos = photos
        self.lastLoadedPage = lastLoadedPage
        self.nextPage = nextPage
    }

    func fetchPhotosNextPage(
        _ nextPage: Int,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        let nextPage = lastLoadedPage == nil ? 1 : nextPage + 1

        guard let request = makeFetchPhotosRequest(nextPage: nextPage) else {
            assertionFailure("Invalid request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        let session = URLSession.shared
        let task = session.objectTask(for: request) { [weak self]
            (result: Result<PhotoResult, Error>) in
            guard let self = self else { return }

            switch result {
            case .success(let photoResult):
                let photo = Photo(
                                id: photoResult.id,
                                size: CGSize(width: photoResult.width, height: photoResult.height),
                                createdAt: Date(),
                                welcomeDescription: photoResult.description,
                                thumbImageURL: photoResult.urls.thumb,
                                largeImageURL: photoResult.urls.full,
                                isLiked: photoResult.likedByUser
                            )
                            self.photos.append(photo)
                            self.lastLoadedPage = nextPage
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(
                                    name: ImageListService.DidChangeNotification,
                                    object: self
                                )
                            }
            case .failure(let error):
                print("Failed to fetch photos: \(error)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

extension ImageListService {
    private func makeFetchPhotosRequest(nextPage: Int) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.unsplash.com"
        urlComponents.path = "/photos"
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        guard let url = urlComponents.url else {
            fatalError("Failed to create URL")
        }

        var request = URLRequest(url: url)

        request.httpMethod = "GET"

        if let token = OAuth2TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}

