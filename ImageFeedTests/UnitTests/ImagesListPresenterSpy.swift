//
//  ImagesListPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Dinara on 13.11.2023.
//

import ImageFeed
import Foundation

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImageFeed.ImagesListViewControllerProtocol?
    var allPhotos: Int = 0
    var viewDidLoadCalled: Bool = false
    var checkAndLoadNextPhotosIfNeededCalled: Bool = false
    var updateTableViewAnimatedCalled: Bool = false
    var imagesListCellDidTapLikeCalled: Bool = false
    var returnPhotosFromArrayCalled: Bool = false
    var returnPhotosFromArrayGotIndex: Bool = false
    var returnPhotosFromArrayMockResult: ImageFeed.Photo?

    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func checkAndLoadNextPhotosIfNeeded(indexPath: IndexPath) {
        checkAndLoadNextPhotosIfNeededCalled = true
    }
    
    func updateTableViewAnimated() {
        updateTableViewAnimatedCalled = true
    }
    
    func imagesListCellDidTapLike(_ cell: ImageFeed.ImagesListCell, indexPath: IndexPath) {
        imagesListCellDidTapLikeCalled = true
    }

    func returnPhotosFromArray(indexPath: IndexPath) -> ImageFeed.Photo? {
        returnPhotosFromArrayCalled = true
        if indexPath == IndexPath(row: 1, section: 0) {
            returnPhotosFromArrayGotIndex = true
        }
        return returnPhotosFromArrayMockResult
    }
}
