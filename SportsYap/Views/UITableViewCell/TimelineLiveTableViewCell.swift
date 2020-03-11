//
//  TimelineLiveTableViewCell.swift
//  SportsYap
//
//  Created by Alex Pelletier on 6/6/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

protocol TimelineLiveTableViewCellDelegate {
    func liveStreamPressed(user: User)
}

class TimelineLiveTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var delegate: TimelineLiveTableViewCellDelegate!
    var users: [User]!{
        didSet{
            collectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }

}

extension TimelineLiveTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "liveUserCell", for: indexPath) as? LiveUserCollectionViewCell{
            let user = users[indexPath.row]
            cell.profileImageView.image = nil
            if let url = user.profileImage{
                cell.profileImageView.imageFromUrl(url: url)
            }else{
                cell.profileImageView.image = #imageLiteral(resourceName: "default-profile")
            }
            cell.verifiedImageView.alpha = user.verified ? 1 : 0
            return cell
        }
        return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        delegate.liveStreamPressed(user: users[indexPath.row])
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 83, height: 83)
    }
}
