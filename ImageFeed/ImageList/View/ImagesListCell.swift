//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Dinara on 30.08.2023.
//

import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"

    // MARK: - UI
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!

    func isLiked(_ isLiked: Bool) {
        if isLiked {
            self.likeButton.imageView?.image = UIImage(named: "like_active")
        } else {
            self.likeButton.imageView?.image = UIImage(named: "like_not_active")
        }
    }
}

