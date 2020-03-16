//
//  GifCell.swift
//  SportsYap
//
//  Created by Solomon W on 9/2/19.
//  Copyright © 2019 Alex Pelletier. All rights reserved.
//

import UIKit
import Gifu

class AnimatedImageCell: UICollectionViewCell {
    
    let imageView: Gifu.GIFImageView
    let activityIndicator: UIActivityIndicatorView
    let textView: UITextView
    
    override init(frame: CGRect) {
        imageView = Gifu.GIFImageView()
        activityIndicator = UIActivityIndicatorView(style: .gray)
        textView = UITextView()
        
        super.init(frame: frame)
        
        //self.backgroundColor = UIColor(white: 235.0 / 255.0, alpha: 1.0)
        self.backgroundColor = .black
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        contentView.addSubview(imageView)
        imageView.frame = contentView.bounds
        imageView.autoresizingMask =  [.flexibleWidth, .flexibleHeight]
        
        textView.frame = CGRect(x: 0, y: imageView.frame.height - 40, width: imageView.frame.width, height: 40)
        textView.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        textView.textColor = .white
        textView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        
        let layer = CAGradientLayer()
        layer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        layer.locations = [0.5, 1.0]
        layer.frame = imageView.frame
        imageView.layer.insertSublayer(layer, at: 0)
        
        contentView.addSubview(activityIndicator)
        contentView.addSubview(textView)
        contentView.bringSubviewToFront(textView)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        contentView.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.prepareForReuse()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
