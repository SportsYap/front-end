//
//  PostTableViewCell.swift
//  SportsYap
//
//  Created by Alex Pelletier on 5/3/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit
import AVKit

protocol PostTableViewCellDelegate {
    func likeBttnPressed(post: Post)
    func commentBttnPressed(post: Post)
    func userBttnPressed(user: User)
    func optionsBttnPressed(post: Post)
}

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var aspectRatioConstraint: NSLayoutConstraint!
    
    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var teamLbl: UILabel!
    @IBOutlet var timeAgoLbl: UILabel!
    @IBOutlet var userProfileImageView: UIImageView!
    @IBOutlet var verificiedIcon: UIImageView!
    @IBOutlet var likeBttn: UIButton!
    @IBOutlet weak var likeCountLbl: UILabel!
    
    @IBOutlet var mediaImageView: UIImageView!
    @IBOutlet var mediaVideoContainer: UIView!
    @IBOutlet weak var playBttnImageView: UIImageView!
    
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    var delegate: PostTableViewCellDelegate!
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var post: Post!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        loadingActivityIndicator.startAnimating()
        
        mediaImageView.isUserInteractionEnabled = true
        clipToBounds = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        mediaImageView.image = nil
        loadingActivityIndicator.alpha = 1
        playBttnImageView.alpha = 0
        
        if let layers = mediaVideoContainer.layer.sublayers{
            for layer in layers{
                layer.removeFromSuperlayer()
            }
        }
    }
    
    func playVideo(from url: URL){
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = mediaVideoContainer.bounds
        playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        mediaVideoContainer.layer.addSublayer(playerLayer!)
        player?.volume = 0
        player?.play()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: player?.currentItem)
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        if let playerItem: AVPlayerItem = player?.currentItem {
            playerItem.seek(to: CMTime.zero, completionHandler: nil)
            player?.play()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "rate" {
            loadingActivityIndicator.alpha = 0
        }
    }
    
    func setLikeCnt(cnt: Int){
        let normalized = cnt >= 0 ? cnt : 0 //max(0, cnt)
        likeCountLbl.text = "\(normalized) Like\(normalized != 1 ? "s" : "")"
        
        post.likeCnt = normalized
    }
    
    //MARK: IBAction
    @IBAction func likeBttnPressed(_ sender: Any) {
        /*
        delegate.likeBttnPressed(post: post)
        post.liked = !post.liked
        likeBttn.setImage(!post.liked ? #imageLiteral(resourceName: "like_bttn_empty") : #imageLiteral(resourceName: "like_bttn_selected"), for: .normal)
        let currentCnt = post.likeCnt ?? 0
        
        if post.liked{
            setLikeCnt(cnt: currentCnt + 1)
        }else{
            setLikeCnt(cnt: currentCnt - 1)
        }
        */
        
        if User.me.likedPosts.contains(post.id) {
            // already liked
            ApiManager.shared.unlike(post: post.id, onSuccess: {
                //likeBttn.setImage(!post.liked ? #imageLiteral(resourceName: "like_bttn_empty") : #imageLiteral(resourceName: "like_bttn_selected"), for: .normal)
                self.likeBttn.setImage(#imageLiteral(resourceName: "like_bttn_empty"), for: .normal)
                let currentCnt = self.post.likeCnt ?? 0
                self.setLikeCnt(cnt: currentCnt - 1)
                
                User.me.likedPosts.removeAll(where: {$0 == self.post.id})
                
            }, onError: voidErr)
            
        } else {
            // didn't like yet
            ApiManager.shared.like(post: post.id, onSuccess: {
                self.likeBttn.setImage(#imageLiteral(resourceName: "like_bttn_selected"), for: .normal)
                let currentCnt = self.post.likeCnt ?? 0
                self.setLikeCnt(cnt: currentCnt + 1)
                
                User.me.likedPosts.append(self.post.id)
                
            }, onError: voidErr)
        }

    }
    @IBAction func commentBttnPressed(_ sender: Any) {
        delegate.commentBttnPressed(post: post)
    }
    @IBAction func userBttnPressed(_ sender: Any) {
        delegate.userBttnPressed(user: post.user)
    }
    @IBAction func optionsBttnPressed(_ sender: Any) {
        delegate.optionsBttnPressed(post: post)
    }
}
