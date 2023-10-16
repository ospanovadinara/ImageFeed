//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Dinara on 03.10.2023.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let session = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?

    private init() {}

    func fetchAuthToken(_ code: String,
                        completion: @escaping (Result<String, Error>) -> Void) {

        assert(Thread.isMainThread)
        if lastCode == code { return }
        task?.cancel()
        lastCode = code

        let request = makeRequest(code: code)
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
                        let responseBody = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                        completion(.success(responseBody.accessToken))
                        self.task = nil
                        if error != nil {
                            self.lastCode = nil
                        }
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(NetworkError.noData))
                }
            }
        }
        self.task = task
        task.resume()
    }

    private func makeRequest(code: String) -> URLRequest {
        //Создание URL c использованием URLComponents
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "unsplash.com"
        urlComponents.path = "/oauth/token"

        let queryItems = [
            URLQueryItem(name: "client_id", value: AccessKey),
            URLQueryItem(name: "client_secret", value: SecretKey),
            URLQueryItem(name: "redirect_uri", value: RedirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]

        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            fatalError("Failed to create URL")
        }

        //Создание HTTP-запроса
        var request = URLRequest(url: url)

        //Создание HTTP-метода
        request.httpMethod = "POST"
        
        return request
    }
}
