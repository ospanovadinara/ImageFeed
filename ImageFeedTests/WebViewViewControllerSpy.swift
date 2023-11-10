//
//  WebViewViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Dinara on 10.11.2023.
//

import ImageFeed
import Foundation

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var loadRequestCalled: Bool = false
    var presenter: ImageFeed.WebViewPresenterProtocol?

    func load(request: URLRequest) {
        loadRequestCalled = true
    }

    func setProgressValue(_ newValue: Float) {

    }

    func setProgressHidden(_ isHidden: Bool) {

    }
}
