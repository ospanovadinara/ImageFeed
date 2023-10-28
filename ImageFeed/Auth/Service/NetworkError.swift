//
//  NetworkError.swift
//  ImageFeed
//
//  Created by Dinara on 04.10.2023.
//

import Foundation

enum NetworkError: Error {

    case decodingError(Error)
    case urlRequestError(Error)
    case urlSessionError
    case httpStatusCode(Int)
    case invalidStatusCode
    case invalidRequest
    case noData
    case unauthorized
}
