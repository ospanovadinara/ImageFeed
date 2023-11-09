//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Dinara on 13.09.2023.
//

import UIKit
import ProgressHUD
import Kingfisher

final class SingleImageViewController: UIViewController {
    var fullImageUrl: String?
    var image: UIImage? {
        didSet {
            if let image = image {
                guard isViewLoaded else { return }
                imageView.image = image
                rescaleAndCenterImageInScrollView(image: image)
            }
        }
    }

    // MARK: - UI
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var scrollView: UIScrollView!


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        showFullImage()

        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }

    // MARK: - Actions
    @IBAction private func didTapBackButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func didTapShareButton(_ sender: UIButton) {
        guard let image = image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
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

    private func showFullImage() {
        if let imageUrl = fullImageUrl,
           let url = URL(string: imageUrl) {
            UIBlockingProgressHUD.show()
            imageView.kf.setImage(with: url) { [weak self] result in
                UIBlockingProgressHUD.dismiss()
                guard let self = self else { return }
                switch result {
                case .success(let fullImage):
                    self.image = fullImage.image
                case .failure:
                    self.showAlert()
                }
            }
        }
    }

    private func showAlert() {
        let alert = UIAlertController(title: "Ошибка",
                                      message: "Что-то пошло не так. Попробовать ещё раз?",
                                      preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Не надо", style: .cancel, handler: nil)
        let tryAgainAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.showFullImage()
        }

        alert.addAction(cancelAction)
        alert.addAction(tryAgainAction)

        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

