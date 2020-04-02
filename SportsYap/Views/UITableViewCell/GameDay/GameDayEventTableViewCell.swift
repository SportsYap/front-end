//
//  GameDayEventTableViewCell.swift
//  SportsYap
//
//  Created by Master on 2020/3/21.
//  Copyright © 2020 Alex Pelletier. All rights reserved.
//

import UIKit
import SDWebImage

class GameDayEventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    var event: Event? {
        didSet {
            if let event = event {
                thumbImageView.sd_setImage(with: event.thumbnail)
                descriptionLabel.text = event.name
                costLabel.text = (event.minCost == event.maxCost) ? event.minCost.formattedString() : "\(event.minCost.formattedString()) - \(event.maxCost.formattedString())"

                if let date = event.date {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH aa"
                    timeLabel.text = dateFormatter.string(from: date)
                } else {
                    timeLabel.text = "None"
                }
                
                locationLabel.text = event.location
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        thumbImageView.sd_cancelCurrentImageLoad()
        thumbImageView.image = nil
    }
}
