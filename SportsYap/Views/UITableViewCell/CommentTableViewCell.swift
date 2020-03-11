//
//  CommentTableViewCell.swift
//  SportsYap
//
//  Created by Alex Pelletier on 5/25/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var isVerifiedImageView: UIImageView!
    @IBOutlet var textLbl: UILabel!
    @IBOutlet var timeAgoLbl: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
