//
//  MovieListCollectionViewCell.swift
//  RentoMovie
//
//  Created by Shailesh.Chandavar on 07/12/18.
//  Copyright © 2018 Shailesh.Chandavar. All rights reserved.
//

import UIKit
import Kingfisher

//MovieListCollectionViewCell show the movie info and its gets expanded when user taps
//and whole synopsis will be shown.

class MovieListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var certificateLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var synopsisLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureShadow()
    }
    
    func configureShadow() {
        contentView.layer.cornerRadius = 2.0
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 3.0
        layer.shadowOpacity = 0.2
        layer.masksToBounds = false
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        ratingLabel.layer.cornerRadius =  (ratingLabel.bounds.height * 0.5)
        ratingLabel.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
    
    
    func configureWithMovie(movie: Movie) {
        titleLabel.text = movie.title
        if let imageURL = movie.imageURL() {
            thumbnailImageView.kf.setImage(with: imageURL)
        }
        releaseDateLabel.text =  movie.releaseDateDescription()
        synopsisLabel.text = movie.overView
        ratingLabel.text = "\(movie.voteAverage)"
        certificateLabel.text = movie.certificate()
        synopsisLabel.numberOfLines = (movie.synopsisShown ? 0 : 2)
        
    }
    
    
    
}
