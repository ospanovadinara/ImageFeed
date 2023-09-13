//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Dinara on 13.09.2023.
//

import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage! {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }

    @IBOutlet var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }

// MARK: - Actions
    @IBAction func didTapBackButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
