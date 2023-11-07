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
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
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

    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?
    ) {
        if segue.identifier == ShowSingleImageSegueIdentifier {
            let viewController = segue.destination as! SingleImageViewController
            guard let indexPath = sender as? IndexPath else { return }
            viewController.imageUrl = photos[indexPath.row].largeImageURL
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

        let image = photos[indexPath.row]

        if let url = URL(string: image.thumbImageURL) {
            imageListCell.cellImage.kf.indicatorType = .activity
            imageListCell.cellImage.kf.setImage(
                with: url,
                placeholder: UIImage(named: "placeholder"),
                options: []) { result in
                    switch result {
                    case .success(_):
                        if let createdAt = image.createdAt {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "dd MMMM yyyy"
                            imageListCell.dateLabel.text = dateFormatter.string(from: createdAt)
                        } else {
                            imageListCell.dateLabel.text = "Дата неизвестна"
                        }
                        imageListCell.setIsLiked(image.isLiked)
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                    case .failure(let error):
                        print(error)
                    }
                }
        }
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

        let defaultCellHeight: CGFloat = 252.0

        guard indexPath.row < photos.count else {
            return defaultCellHeight
        }

        let image = photos[indexPath.row]

        if let image = UIImage(named: image.thumbImageURL) {
            let imageInsets = UIEdgeInsets(top: 4,
                                           left: 16,
                                           bottom: 4,
                                           right: 16)
            let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
            let imageWidth = image.size.width
            let scale = imageViewWidth / imageWidth
            let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
            return cellHeight
        } else {
            return defaultCellHeight
        }
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
                    cell.setIsLiked(self.photos[indexPath.row].isLiked)
                    if let index = self.photos.firstIndex(where: { $0.id == photo.id }) {
                        let photo = self.photos[index]
                        let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: !photo.isLiked
                        )
                        self.photos.remove(at: index)
                        self.photos.insert(newPhoto, at: index)
                    }

                case .failure(let error):
                    print("Error accured while changing like: \(error)")
                }
                UIBlockingProgressHUD.dismiss()
//                showLikeAlert()
            }
        }
    }

    private func showLikeAlert() {
        let alert = UIAlertController(title: "Что-то пошло не так",
                                      message: "Не удалось поставить лайк",
                                      preferredStyle: .alert)

        let action = UIAlertAction(title: "Oк", style: .default, handler: { _ in })

        alert.addAction(action)
        self.present(alert, animated: true)
    }
}

