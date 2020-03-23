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
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var fansGoingLabel: UILabel!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    var event: Event? {
        didSet {
            if let event = event {
                nameLabel.text = event.name
                fansGoingLabel.text = "\(event.fansGoing) " + NSLocalizedString("Fans Going", comment: "")
                thumbImageView.sd_setImage(with: event.thumbnail)
                descriptionLabel.text = event.content
                costLabel.text = event.cost.formattedString()

                if let from = event.from,
                    let to = event.to {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HHaa"
                    timeLabel.text = dateFormatter.string(from: from) + " - " + dateFormatter.string(from: to)
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
