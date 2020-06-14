//
//  GameDayChatTableViewCell.swift
//  SportsYap
//
//  Created by Master on 2020/6/14.
//  Copyright © 2020 Alex Pelletier. All rights reserved.
//

import UIKit

class GameDayChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var message: Message! {
        didSet {
            contentLabel.text = message.content
            dateLabel.text = message.sentDate.timeAgoSince()
            nameLabel.text = message.senderName
            avatarImageView.sd_setImage(with: URL(string: message.avatar), placeholderImage: #imageLiteral(resourceName: "default-profile"))
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

}
