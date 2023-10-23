//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Dinara on 11.10.2023.
//

import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private(set) var profile: Profile?
    private let session = URLSession.shared
    private var lastToken: String?
    private var currentTask: URLSessionTask?

    func fetchProfile(_ token: String) {
        self.fetchProfile(token) { result in
            switch result {
            case .success(let profile):
                self.profile = profile
            case .failure(let error):
                fatalError("Error: \(error)")
            }
        }
    }


    func fetchProfile(_ token: String, completion: @escaping (Result <Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastToken == token { return }
        currentTask?.cancel()
        lastToken = token

        guard let request = makeFetchProfileRequest(token: token) else {
            assertionFailure("Invalid request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        currentTask = session.objectTask(for: request) {
            [weak self] (response: Result<ProfileResult, Error>) in
            switch response {
            case .success(let profileResult):
                let profile = Profile(username: profileResult.username,
                                      name: "\(profileResult.firstName)\(profileResult.lastName ?? "")",
                                      loginName: "@\(profileResult.username)",
                                      bio: profileResult.bio)
                self?.profile = profile
                completion(.success(profile))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension ProfileService {
    private func makeFetchProfileRequest(token: String) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.unsplash.com"
        urlComponents.path = "/me"

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






