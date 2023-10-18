//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Dinara on 11.10.2023.
//

import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private let session = URLSession.shared
    private var task: URLSessionTask?
    private var authToken = OAuth2TokenStorage.shared.token
    private(set) var profile: Profile?

    init() {}

    func fetchProfile(_ token: String,
                      completion: @escaping (Result <Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        if authToken == token { return }
        task?.cancel()
        authToken = token

        guard let authToken = authToken else { return }
        let request = makeRequest(token: authToken)
        task = session.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let profileResult):
                let loginName = "@" + profileResult.username
                let name = "\(profileResult.firstName) \(profileResult.lastName)"
                let profile = Profile(username: profileResult.username,
                                      name: name,
                                      loginName: loginName,
                                      bio: profileResult.bio)
                completion(.success(profile))
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

    private func makeRequest(token: String) -> URLRequest {
        //Создание URL c использованием URLComponents
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.unsplash.com"
        urlComponents.path = "/users/me"

        guard let url = urlComponents.url else {
            fatalError("Failed to create URL")
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


