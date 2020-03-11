//
//  ProfileHeaderTableViewCell.swift
//  SportsYap
//
//  Created by Alex Pelletier on 3/1/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

protocol ProfileHeaderTableViewCellDelegate {
    func followingBttnPressed()
    func followersBttnPressed()
    func followBttnPressed()
}

class ProfileHeaderTableViewCell: UITableViewCell {

    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var locationLbl: UILabel!
    
    @IBOutlet var shotCntLbl: UILabel!
    @IBOutlet var followerCntLbl: UILabel!
    @IBOutlet var followingCntLbl: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet weak var followBttn: UIButton!
    @IBOutlet weak var isVerifiedImageView: UIImageView!
    
    @IBOutlet var collectionView: UICollectionView!
    
    var teams = [Team](){
        didSet{
            collectionView.reloadData()
        }
    }
    
    var delegate: ProfileHeaderTableViewCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = LeftAlignedCollectionViewFlowLayout()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    @IBAction func followingBttnPressed(_ sender: Any) {
        delegate.followingBttnPressed()
    }
    
    @IBAction func followersBttnPressed(_ sender: Any) {
        delegate.followersBttnPressed()
    }
    
    @IBAction func followBttnPressed(_ sender: Any) {
        delegate.followBttnPressed()
    }
    

}

extension ProfileHeaderTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "teamCell", for: indexPath) as? ProfileTeamCollectionViewCell{
            let team = teams[indexPath.row]
            cell.teamNameLbl.text = team.name
            cell.teamPrimaryColor.backgroundColor = team.primaryColor
            cell.teamSecondaryColor.backgroundColor = team.secondaryColor
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return teams.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let lbl = UILabel()
        lbl.text = teams[indexPath.row].name
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.sizeToFit()
        
        return CGSize(width: 40 + lbl.frame.width, height: 23)
    }
}

class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            
            layoutAttribute.frame.origin.x = leftMargin
            
            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }
        
        return attributes
    }
}
