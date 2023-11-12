//
//  ImagesListTests.swift
//  ImageFeedTests
//
//  Created by Dinara on 13.11.2023.
//

@testable import ImageFeed
import XCTest

final class ImagesListTests: XCTestCase {

    // MARK: - ImagesListPresenter Tests
    func testViewDidLoadCalled() {
        //given
        let imagesListPresenter = ImagesListPresenterSpy()
        let imagesListViewController = ImagesListViewController()
        imagesListPresenter.view = imagesListViewController
        imagesListViewController.presenter = imagesListPresenter

        //when
        _ = imagesListViewController.view

        //then
        XCTAssertTrue(imagesListPresenter.viewDidLoadCalled)
    }

    func testcheckAndLoadNextPhotosIfNeededCalled() {
        //given
        let imagesListPresenter = ImagesListPresenterSpy()
        let imagesListViewController = ImagesListViewController()
        imagesListPresenter.view = imagesListViewController
        imagesListViewController.presenter = imagesListPresenter

        //when
        _ = imagesListViewController.view
        let indexPath = IndexPath(row: 1, section: 0)
        imagesListPresenter.checkAndLoadNextPhotosIfNeeded(indexPath: indexPath)

        //then
        XCTAssertTrue(imagesListPresenter.checkAndLoadNextPhotosIfNeededCalled)
    }

    func testUpdateTableViewAnimated() {
        //given
        let imagesListPresenter = ImagesListPresenterSpy()
        let imagesListViewController = ImagesListViewController()
        imagesListPresenter.view = imagesListViewController
        imagesListViewController.presenter = imagesListPresenter

        //when
        _ = imagesListViewController.view
        imagesListPresenter.updateTableViewAnimated()

        //then
        XCTAssertTrue(imagesListPresenter.updateTableViewAnimatedCalled)
    }

    func testImagesListCellDidTapLike() {
        //given
        let imagesListPresenter = ImagesListPresenterSpy()
        let imagesListViewController = ImagesListViewController()
        imagesListPresenter.view = imagesListViewController
        imagesListViewController.presenter = imagesListPresenter

        //when
        _ = imagesListViewController.view
        let indexPath = IndexPath(row: 1, section: 0)
        imagesListPresenter.imagesListCellDidTapLike(ImagesListCell(), indexPath: indexPath)

        //then
        XCTAssertTrue(imagesListPresenter.imagesListCellDidTapLikeCalled)
    }

    func testReturnPhotosFromArray() {
        //given
        let imagesListPresenter = ImagesListPresenterSpy()
        let imagesListViewController = ImagesListViewController()
        imagesListPresenter.view = imagesListViewController
        imagesListViewController.presenter = imagesListPresenter

        //when
        _ = imagesListViewController.view
        let indexPath = IndexPath(row: 1, section: 0)
        let mockPhoto = ImageFeed.Photo(id: "1",
                                        size: CGSize(width: 100, height: 100),
                                        createdAt: Date(),
                                        welcomeDescription: "",
                                        thumbImageURL: "",
                                        largeImageURL: "",
                                        fullImageUrl: "",
                                        isLiked: false)
        imagesListPresenter.returnPhotosFromArrayMockResult = mockPhoto
        let returnedPhoto = imagesListPresenter.returnPhotosFromArray(indexPath: indexPath)

        //then
        XCTAssertTrue(imagesListPresenter.returnPhotosFromArrayCalled)
        XCTAssertEqual(returnedPhoto, mockPhoto)
    }
}

extension ImageFeed.Photo: Equatable {
    public static func == (lhs: ImageFeed.Photo, rhs: ImageFeed.Photo) -> Bool {
        return lhs.id == rhs.id && lhs.fullImageUrl == rhs.fullImageUrl && lhs.isLiked == rhs.isLiked
    }
}
