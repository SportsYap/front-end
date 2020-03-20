//
//  GameDayNewsTableViewCell.swift
//  SportsYap
//
//  Created by Alex Pelletier on 5/22/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

class GameDayNewsTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var coverPhotoImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var news: News? {
        didSet {
            if let news = news {
                titleLabel.text = news.title
                detailLabel.text = "\(news.author)" + (news.author == "" ? "" : " ∙ ") + news.createdAt.timeAgoSince()
                activityIndicator.startAnimating()
                if let url = news.thumbnail{
                    coverPhotoImageView.imageFromUrl(url: url)
                } else {
                    coverPhotoImageView.image = nil
                }
            }
        }
    }
}
