//
//  PictureCollectionViewCell.swift
//  TestStoryboard
//
//  Created by Илья Мишин on 29.05.2023.
//

import UIKit
import SDWebImage

class PictureCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PictureCollectionViewCell"
    
    @IBOutlet weak var pictureView: UIImageView?
    @IBOutlet weak var deleteButton: UIButton?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pictureView?.frame = contentView.bounds
    }
    
    // Configures the cell with an image URL
    public func configure(with url: String) {
        guard let url = URL(string: url) else {
            print("WARNING: Not fetch picture URL!")
            return
        }
        pictureView?.sd_setImage(with: url)
    }
}
