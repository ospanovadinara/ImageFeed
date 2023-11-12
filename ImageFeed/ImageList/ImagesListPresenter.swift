//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Dinara on 12.11.2023.
//

import Foundation

public protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
}

final class ImagesListPresenter {
    weak var view: ImagesListViewControllerProtocol?
}

extension ImagesListPresenter: ImagesListPresenterProtocol {

}
