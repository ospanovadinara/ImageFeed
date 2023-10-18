//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Dinara on 14.10.2023.
//

import Foundation

final class ProfileImageService {

    static let shared = ProfileImageService()
    private (set) var avatarURL: String?
    private let session = URLSession.shared
    private var task: URLSessionTask?
    private var lastUserName: String?
    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    func fetchProfileImageURL(username: String,
                              _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastUserName == username { return }
        task?.cancel()
        lastUserName = username

        let request = makeRequest(username: username)
        task = session.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            switch result {
            case .success(let userResult):
                if let avatarURL = self?.avatarURL {
                    completion(.success(avatarURL))
                    return
                }
                self?.avatarURL = userResult.profileImage.small
                completion(.success(userResult.profileImage.small))
                self?.task = nil
                self?.lastUserName = nil
            case .failure(let error):
                fatalError("Error: \(error)")
            }
            if let task = self?.task {
                task.resume()
            } else {
                print("Error unwrapping task")
            }
        }
    }

    private func makeRequest(username: String) -> URLRequest {
        //Создание URL c использованием URLComponents
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "unsplash.com"
        urlComponents.path = "/users/\(username)"

        guard let url = urlComponents.url else {
            fatalError("Failed to create Avatar URL")
        }

        //Создание HTTP-запроса
        var request = URLRequest(url: url)

        //Создание HTTP-метода
        request.httpMethod = "GET"

        if let token = OAuth2TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        }
        return request
    }
}



