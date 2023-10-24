//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Dinara on 03.10.2023.
//

import UIKit

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let storage: OAuth2TokenStorage
    private let session: URLSession
    private var lastCode: String?
    private var currentTask: URLSessionTask?

    init(
        session: URLSession = .shared,
        storage: OAuth2TokenStorage = .shared
    ) {
        self.session = session
        self.storage = storage
    }

    func fetchOAuthToken(_ code: String,
                        completion: @escaping (Result<String, Error>) -> Void) {

        guard code != lastCode else {
            return
        }

        lastCode = code

        guard let request = authTokenRequest(code: code) else {
            assertionFailure("Invalid request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        currentTask = session.objectTask(for: request) {
            [weak self] (response: Result<OAuthTokenResponseBody, Error>) in
            self?.currentTask = nil
            switch response {
            case .success(let body):
                let authToken = body.accessToken
                self?.storage.token = authToken
                completion(.success(authToken))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension OAuth2Service {
    private func  authTokenRequest(code: String) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "unsplash.com"
        urlComponents.path = "/oauth/token"

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: AccessKey),
            URLQueryItem(name: "client_secret", value: SecretKey),
            URLQueryItem(name: "redirect_uri", value: RedirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents.url else {
            fatalError("Failed to create URL")
        }

        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        return request
    }
}


