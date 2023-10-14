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
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                //Проверяем значение HTTP-кода
                guard let httpResponse = response as? HTTPURLResponse,
                      (200..<300).contains(httpResponse.statusCode)
                else {
                    let httpResponse = response as? HTTPURLResponse
                    completion(.failure(NetworkError.invalidStatusCode))
                    print("Error: \(String(describing: httpResponse?.statusCode))")
                    return
                }
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                if let data = data {
                    do {
                        let userResult = try decoder.decode(UserResult.self, from: data)
                        if let avatarURL = self.avatarURL {
                            completion(.success(avatarURL))
                            return
                        }
                        self.avatarURL = userResult.profileImage.small
                        completion(.success(userResult.profileImage.small))
                        self.task = nil
                        if error != nil {
                            self.lastUserName = nil
                        }
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(NetworkError.noData))
                }
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.DidChangeNotification,
                        object: self,
                        userInfo: ["URL": self.avatarURL ?? ""])
            }
        }
        self.task = task
        task.resume()
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
