//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Dinara on 12.11.2023.
//

import Foundation

public protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    var allPhotos: Int { get }
    func viewDidLoad()
    func checkAndLoadNextPhotosIfNeeded(indexPath: IndexPath)
    func updateTableViewAnimated()
    func imagesListCellDidTapLike(_ cell: ImagesListCell, indexPath: IndexPath)
    func returnPhotosFromArray(indexPath: IndexPath) -> Photo?
}

final class ImagesListPresenter {
    var photos: [Photo] = []
    var allPhotos: Int {
      photos.count
    }
    weak var view: ImagesListViewControllerProtocol?
    private let imageListService = ImageListService.shared
    private var likedPhotoIds: Set<String> = []
}

extension ImagesListPresenter: ImagesListPresenterProtocol {
    func viewDidLoad() {
        view?.configureTableView()
        configureImageListService()
    }

    func checkAndLoadNextPhotosIfNeeded(indexPath: IndexPath) {
        if indexPath.row + 1 == imageListService.photos.count {
            imageListService.fetchPhotosNextPage()
        }
    }

    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imageListService.photos.count
        photos = imageListService.photos
        if oldCount != newCount {
            var indexPaths = [IndexPath]()
            view?.tableView.performBatchUpdates {
                indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                view?.tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }

    func imagesListCellDidTapLike(_ cell: ImagesListCell, indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()

        imageListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.photos[indexPath.row].isLiked.toggle()
                    if self.photos[indexPath.row].isLiked {
                        self.likedPhotoIds.insert(photo.id)
                    } else {
                        self.likedPhotoIds.remove(photo.id)
                    }
                    cell.setIsLiked(self.photos[indexPath.row].isLiked)
                case .failure(let error):
                    print("Error accured while changing like: \(error)")
                }
                UIBlockingProgressHUD.dismiss()
            }
        }
    }

    func returnPhotosFromArray(indexPath: IndexPath) -> Photo? {
        photos[indexPath.row]
    }
}

extension ImagesListPresenter {
    func configureImageListService() {
        imageListService.fetchPhotosNextPage()
    }
}
