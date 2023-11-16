//
//  ProfileTests.swift
//  ImageFeedTests
//
//  Created by Dinara on 12.11.2023.
//

@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {

    // MARK: - ProfilePresenter Tests
    func testViewControllerCallsViewDidLoad() {
        //given
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenterSpy()
        profileViewController.presenter = profilePresenter
        profilePresenter.view = profileViewController

        //when
        _ = profileViewController.view

        //then
        XCTAssertTrue(profilePresenter.viewDidLoadCalled)
    }

    func testViewControllerCallsClearAccount() {
        //given
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenterSpy()
        profileViewController.presenter = profilePresenter
        profilePresenter.view = profileViewController

        //when
        _ = profileViewController.view
        profilePresenter.clearAccount()

        //then
        XCTAssertTrue(profilePresenter.viewDidClearAccount)
    }

    func testViewControllerCallsViewWillAppear() {
        //given
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenterSpy()
        profileViewController.presenter = profilePresenter
        profilePresenter.view = profileViewController

        //when
        _ = profileViewController.view
        profilePresenter.viewWillAppear()

        //then
        XCTAssertTrue(profilePresenter.viewDidAppearCalled)
    }

    // MARK: - ProfileViewController Tests
    func testPresenterCallsUpdateProfileDetails() {
        //given
        let profileViewController = ProfileViewControllerSpy()
        let profilePresenter = ProfilePresenter()
        profileViewController.presenter = profilePresenter
        profilePresenter.view = profileViewController

        let user = "test"
        let profile = Profile(username: user,
                              name: user,
                              loginName: user,
                              bio: user)

        //when
        profileViewController.updateProfileDetails(profile)

        //then
        XCTAssertTrue(profileViewController.viewDidUpdateProfileDetails)
        XCTAssertEqual(profileViewController.nameLabel.text, user)
        XCTAssertEqual(profileViewController.userNameLabel.text, user)
        XCTAssertEqual(profileViewController.statusLabel.text, user)
    }

    func testPresenterCallsUpdateAvatar() {
        //given
        let profileViewController = ProfileViewControllerSpy()
        let profilePresenter = ProfilePresenter()
        profileViewController.presenter = profilePresenter
        profilePresenter.view = profileViewController

        let url = URL(string: "https://www.google.com")!

        //when
        profileViewController.updateAvatar(url: url)

        //then
        XCTAssertTrue(profileViewController.viewDidUpdateAvatar)
    }
}
