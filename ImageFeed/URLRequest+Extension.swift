//
//  URLRequest+Extension.swift
//  ImageFeed
//
//  Created by Dinara on 20.10.2023.
//

import Foundation


final class URLRequestBuilder {
    static let shared = URLRequestBuilder()
    private let storage: OAuth2TokenStorage

    init(storage: OAuth2TokenStorage = .shared) {
        self.storage = storage
    }

    func makeRequest(path: String, httpMethod: String, baseURL: String) -> URLRequest? {
        guard
            let url = URL(string: "https://unsplash.com"),
            let baseUrl = URL(string: path, relativeTo: url)
        else { return nil }

        var request = URLRequest(url: baseUrl)

        request.httpMethod = httpMethod

        if let token = storage.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}

