//
//  GameDayNewsTableViewCell.swift
//  SportsYap
//
//  Created by Alex Pelletier on 5/22/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit
import SDWebImage

class GameDayNewsTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var coverPhotoImageView: UIImageView!
    
    var news: News? {
        didSet {
            if let news = news {
                titleLabel.text = news.title
                detailLabel.text = "\(news.author)" + (news.author == "" ? "" : " ∙ ") + news.createdAt.timeAgoSince()
                coverPhotoImageView.sd_setImage(with: news.thumbnail)
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        coverPhotoImageView.sd_cancelCurrentImageLoad()
        coverPhotoImageView.image = nil
    }
}
