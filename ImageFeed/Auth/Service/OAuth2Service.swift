//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Dinara on 03.10.2023.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}

    func fetchAuthToken(_ code: String,
                        completion: @escaping (Result<String, Error>) -> Void) {
        //Создание URL c использованием URLComponents
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "unsplash.com"
        urlComponents.path = "/oauth/token"
        
        guard let url = urlComponents.url else {
            return
        }
        
        //Создание HTTP-запроса
        var request = URLRequest(url: url)
        
        //Создание HTTP-метода
        request.httpMethod = "POST"
        
        let bodyParameters = [
            "client_id": AccessKey,
            "client_secret": SecretKey,
            "redirect_uri": RedirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: bodyParameters)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
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
                    do {
                        let responseBody = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                        completion(.success(responseBody.accessToken))
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
}
