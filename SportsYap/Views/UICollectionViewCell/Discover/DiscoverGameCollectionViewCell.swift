//
//  DiscoverGameCollectionViewCell.swift
//  
//
//  Created by Alex Pelletier on 3/20/18.
//

import UIKit

class DiscoverGameCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var fieldNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var awayTeamNameLabel: UILabel!
    @IBOutlet weak var awayScoreLabel: UILabel!
    
    @IBOutlet weak var homeTeamNameLabel: UILabel!
    @IBOutlet weak var homeScoreLabel: UILabel!
    
    @IBOutlet weak var sportBgImageView: UIImageView!
    
    @IBOutlet weak var shotsView: UIView!
    @IBOutlet weak var shotsStackView: UIStackView!
    
    @IBOutlet weak var startingTimeView: UIView!
    @IBOutlet weak var startingTimeLabel: UILabel!

    var game: Game? {
        didSet {
            if let game = game {
                if game.awayTeam != nil {
                    awayTeamNameLabel.text = game.awayTeam.name
                    awayScoreLabel.text = "\(game.awayScore)"
                }
                if game.homeTeam != nil {
                    homeTeamNameLabel.text = game.homeTeam.name
                    homeScoreLabel.text = "\(game.homeScore)"
                }
                sportBgImageView.image = game.sport.image
                fieldNameLabel.text = game.venue.name
                
                timeLabel.text = game.startTime
                
                // if start time is past 5 hours the current date add 'final' instead of start time
                if let startFiveHours = Calendar.current.date(byAdding: .hour, value: 5, to: game.start) {
                    timeLabel.text = startFiveHours < Date() ? "Final" : game.startTime
                }
                
                
                shotsView.isHidden = game.posts.isEmpty
                for shotView in shotsStackView.arrangedSubviews {
                    shotsStackView.removeArrangedSubview(shotView)
                    shotView.removeFromSuperview()
                }

                var index = 0
                for post in game.posts {
                    if index >= 3 {
                        break
                    }
                    
                    let imageView = UIImageView()
                    imageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
                    imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
                    imageView.contentMode = .scaleAspectFill
                    imageView.cornerRadius = 10
                    imageView.clipsToBounds = true
                    
                    if index < 2 || (index == 2 && index == game.posts.count - 1) {
                        imageView.sd_setImage(with: post.user.profileImage, placeholderImage: #imageLiteral(resourceName: "default-profile"))
                    } else {
                        imageView.image = UIImage(named: "more_shots")
                    }
                    shotsStackView.addArrangedSubview(imageView)
                    
                    index += 1
                }
                
                if game.start.compare(Date()) == .orderedDescending {
                    startingTimeLabel.text = NSLocalizedString("Starting", comment: "") + " " + game.startTime
                    startingTimeView.isHidden = false
                    
                    awayScoreLabel.alpha = 0
                    homeScoreLabel.alpha = 0
                    timeLabel.alpha = 0
                } else {
                    startingTimeView.isHidden = true
                    
                    awayScoreLabel.alpha = 1
                    homeScoreLabel.alpha = 1
                    timeLabel.alpha = 1
                }
            }
        }
    }
}
