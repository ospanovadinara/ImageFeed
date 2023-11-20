//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Dinara on 30.08.2023.
//

import UIKit
import Kingfisher

public final class ImagesListCell: UITableViewCell {
    weak var delegate: ImagesListCellDelegate?
    
    static let reuseIdentifier = "ImagesListCell"

    var imageLoadCompletion: (() -> Void)?
    var imageLoadFailure: ((Error) -> Void)?

    // MARK: - UI
    @IBOutlet weak private var cellImage: UIImageView!
    @IBOutlet weak private var likeButton: UIButton!
    @IBOutlet weak private var dateLabel: UILabel!



    @IBAction func likeButtonClicked(_ sender: UIButton) {
        delegate?.imageListCellDidTapLike(self)
    }

    func configCell(withPhoto photo: Photo) {
        if photo.isLiked {
            self.likeButton.imageView?.image = UIImage(named: "like_active")
        } else {
            self.likeButton.imageView?.image = UIImage(named: "like_not_active")
        }


        if let url = URL(string: photo.thumbImageURL) {
            cellImage.kf.indicatorType = .activity
            cellImage.kf.setImage(
                with: url,
                placeholder: UIImage(named: "placeholder"),
                options: []) { result in
                    switch result {
                    case .success(_):
                        self.imageLoadCompletion?()
                    case .failure(let error):
                        self.imageLoadFailure?(error)
                    }
                }
        }

        if let createdAt = photo.createdAt {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM yyyy"
            dateLabel.text = dateFormatter.string(from: createdAt)
        } else {
            dateLabel.text = "Дата неизвестна"
        }
    }


    func setIsLiked(_ isLiked: Bool) {
        self.likeButton.imageView?.image = isLiked ? UIImage(named: "like_active") : UIImage(named: "like_not_active")
    }
}

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

