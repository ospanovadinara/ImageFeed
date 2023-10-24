//
//  AlertPresenter.swift
//  ImageFeed
//
//  Created by Dinara on 20.10.2023.
//

import UIKit

final class AlertPresenter{
    weak var delegate: UIViewController?

    func showAlert(title: String,
                   message: String,
                   preferredStyle: UIAlertController.Style) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)

        let alertAction = UIAlertAction(title: "OK", style: .default, handler: { _ in })
        alert.addAction(alertAction)
        delegate?.present(alert, animated: true)
    }
}
