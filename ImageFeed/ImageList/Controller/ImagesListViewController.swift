//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Dinara on 27.08.2023.
//

import UIKit
import Kingfisher

 final class ImagesListViewController: UIViewController {

    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    private let imageListService = ImageListService.shared
    private var photos: [Photo] = []
    private var likedPhotoIds: Set<String> = []
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter
    }()

    // MARK: - UI
    @IBOutlet weak private var tableView: UITableView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(
            top: 12,
            left: 0,
            bottom: 12,
            right: 0
        )
        tableView.dataSource = self
        tableView.delegate = self

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTableViewAnimated),
            name: ImageListService.DidChangeNotification,
            object: nil)

        imageListService.fetchPhotosNextPage()
    }

     deinit {
         NotificationCenter.default.removeObserver(self)
     }

    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?
    ) {
        if segue.identifier == ShowSingleImageSegueIdentifier {
            if let viewController = segue.destination as? SingleImageViewController,
               let indexPath = sender as? IndexPath {
                viewController.fullImageUrl = photos[indexPath.row].fullImageUrl
            }
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return photos.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        )

        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }

        imageListCell.delegate = self

        imageListCell.imageLoadCompletion = { [weak tableView, indexPath] in
            tableView?.reloadRows(at: [indexPath], with: .automatic)
        }
        imageListCell.imageLoadFailure  = { error in
            print("Error fetching photos: \(error)")
        }
        imageListCell.configCell(withPhoto: photos[indexPath.row])
        return imageListCell
    }
}


// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        performSegue(
            withIdentifier: ShowSingleImageSegueIdentifier,
            sender: indexPath
        )
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        guard let image = UIImage(named: "\(indexPath.row)") else {
            return 0
        }
            let imageInsets = UIEdgeInsets(top: 4,
                                           left: 16,
                                           bottom: 4,
                                           right: 16)
            let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
            let imageWidth = image.size.width
            let scale = imageViewWidth / imageWidth
            let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
            return cellHeight
    }

    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if indexPath.row + 1 == imageListService.photos.count {
            imageListService.fetchPhotosNextPage()
        } else {
            return
        }
    }

    @objc func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imageListService.photos.count
        photos = imageListService.photos
        if oldCount != newCount {
            var indexPaths = [IndexPath]()
            tableView.performBatchUpdates {
            indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
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
}

