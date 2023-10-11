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
        
        let request = makeRequest(token: authToken ?? "")
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                //Проверяем значение HTTP-кода
                guard let httpResponse = response as? HTTPURLResponse,
                      (200..<300).contains(httpResponse.statusCode) else {
                    completion(.failure(NetworkError.invalidStatusCode))
                    return
                }

                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let profileResult = try decoder.decode(ProfileResult.self, from: data)
                        let loginName = "@" + profileResult.username
                        let name = "\(profileResult.firstName) \(profileResult.lastName)"
                        let profile = Profile(username: profileResult.username,
                                              name: name,
                                              loginName: loginName,
                                              bio: profileResult.bio ?? "")
                        completion(.success(profile))
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(NetworkError.noData))
                }
            }
        }
        task.resume()
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
