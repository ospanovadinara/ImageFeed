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
    private let builder: URLRequestBuilder

    init(
        session: URLSession = .shared,
        storage: OAuth2TokenStorage = .shared,
        builder: URLRequestBuilder = .shared
    ) {
        self.session = session
        self.storage = storage
        self.builder = builder
    }

    var isAuthenticated: Bool {
        storage.token != nil
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

        let session = URLSession.shared
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
        builder.makeRequest(path: "/oauth/token"
                            + "?client_id=\(AccessKey)"
                            + "&&client_secret=\(SecretKey)"
                            + "&&redirect_uri=\(RedirectURI)"
                            + "&&code=\(code)"
                            + "&&grant_type=authorization_code",
                            httpMethod: "POST",
                            baseURL: "https://unsplash.com")
    }
}


