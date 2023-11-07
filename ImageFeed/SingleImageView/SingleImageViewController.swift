//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Dinara on 13.09.2023.
//

import UIKit

final class SingleImageViewController: UIViewController {
    var imageUrl: String?
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
            if let image = image {
                rescaleAndCenterImageInScrollView(image: image)
            }
        }
    }

    // MARK: - UI
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        if let image = image {
            imageView.image = image
            rescaleAndCenterImageInScrollView(image: image)
        }
    }

    // MARK: - Actions
    @IBAction func didTapBackButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func didTapShareButton(_ sender: UIButton) {
        let share = UIActivityViewController(
            activityItems: [image!],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }

// MARK: - Rescale and Center image in ScrollView
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}

