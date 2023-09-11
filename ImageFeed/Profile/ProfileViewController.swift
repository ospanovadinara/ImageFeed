//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Dinara on 11.09.2023.
//

import UIKit

final class ProfileViewController: UIViewController {

    // MARK: - UI
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    @IBOutlet weak var exitButton: UIButton!
    
    // MARK: - Actions
    @IBAction func exitButtonTapped(_ sender: UIButton) {
    }

}
