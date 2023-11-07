//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Dinara on 30.08.2023.
//

import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    weak var delegate: ImagesListCellDelegate?
    
    static let reuseIdentifier = "ImagesListCell"

    // MARK: - UI
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!


    @IBAction func likeButtonClicked(_ sender: UIButton) {
        delegate?.imageListCellDidTapLike(self)
    }


    func setIsLiked(_ isLiked: Bool) {
        if isLiked {
            self.likeButton.imageView?.image = UIImage(named: "like_active")
        } else {
            self.likeButton.imageView?.image = UIImage(named: "like_not_active")
        }
    }
}

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

