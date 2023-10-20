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
    private var currentTask: URLSessionTask?
    private let session = URLSession.shared
    private let builder: URLRequestBuilder

    init(builder: URLRequestBuilder = .shared) {
        self.builder = builder
    }
    
    func fetchProfile(completion: @escaping (Result <Profile, Error>) -> Void) {
        currentTask?.cancel()
        guard let request = makeFetchProfileRequest() else {
            assertionFailure("Invalid request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        let session = URLSession.shared
        currentTask = session.objectTask(for: request) {
            [weak self] (response: Result<ProfileResult, Error>) in
            self?.currentTask = nil
            switch response {
            case .success(let profileResult):
                let profile = Profile(result: profileResult)
                self?.profile = profile
                completion(.success(profile))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension ProfileService {
    private func makeFetchProfileRequest() -> URLRequest? {
        builder.makeRequest(path: "/me",
                            httpMethod: "GET",
                            baseURL: "api.unsplash.com")
//        var urlComponents = URLComponents()
//        urlComponents.scheme = "https"
//        urlComponents.host = "api.unsplash.com"
//        urlComponents.path = "/users/me"
//
//        guard let url = urlComponents.url else {
//            fatalError("Failed to create URL")
//        }
//
//        //Создание HTTP-запроса
//        var request = URLRequest(url: url)
//
//        //Создание HTTP-метода
//        request.httpMethod = "GET"
//
//        if let token = OAuth2TokenStorage.shared.token {
//            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        }
//
//        return request
    }
}






