//
//  DisplayPictureViewController.swift
//  TestStoryboard
//
//  Created by Илья Мишин on 29.05.2023.
//

import UIKit
import SDWebImage

class DisplayPictureViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView?
    
    var imageURL = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        imageView?.addGestureRecognizer(tapGesture)

        displayImage()
    }

    @objc private func handleTap() {
        dismiss(animated: true)
    }
    
    // Display the image with an image URL
    private func displayImage() {
        guard let url = URL(string: imageURL) else { return }
        imageView?.sd_setImage(with: url)
    }
}
