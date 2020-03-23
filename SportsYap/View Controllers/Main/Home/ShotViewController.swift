//
//  ShotViewController.swift
//  SportsYap
//
//  Created by Alex Pelletier on 2/8/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit
import AVKit
import QuartzCore

class ShotViewController: UIViewController {

    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var timeAgoLbl: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    
    @IBOutlet var optionBttn: UIButton!
    @IBOutlet var likeBttn: UIButton!
    @IBOutlet var awayHomeTown: UILabel!
    @IBOutlet var awayTeamName: UILabel!
    @IBOutlet var awayScore: UILabel!
    @IBOutlet var homeHomeTown: UILabel!
    @IBOutlet var homeTeamName: UILabel!
    @IBOutlet var homeScore: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet var fanMeterLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var progressBar: UIView!
    @IBOutlet var progressWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet var imageBackgroundView: UIImageView!
    @IBOutlet var videoContainerView: UIView!
    @IBOutlet weak var challengeIndicatorImageView: UIImageView!
    
    var game: Game!
    var posts = [Post]()
    var activePost = 0
    
    var media: UserMedia!
    var player: AVPlayer?
    var photoTimer: Timer?
    var viewLaidOut = false
    private var isAnimatingProgressBar = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressWidthConstraint.constant = 1
        optionBttn.alpha = 0
        
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        
        if posts.count == 0{
            ApiManager.shared.story(for: game, page: 1, onSuccess: { (posts) in
                self.posts = posts
                self.showPost()
            }) { (err) in }
        }else{
            self.showPost()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        player?.currentItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        player?.currentItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        player?.currentItem?.removeObserver(self, forKeyPath: "playbackBufferFull")
        player = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewLaidOut = true
    }
    
    func setUI(){
        guard game.awayTeam != nil && game.homeTeam != nil else {
            ApiManager.shared.games(for: game.id, onSuccess: { (g) in
                self.game = g
                self.setUI()
            }, onError: voidErr)
            return
        }
        
        ApiManager.shared.fanMeter(for: game, onSuccess: { (val) in
            self.game.fanMeter = val
            self.setFanMeter()
        }) { (err) in }
        
        awayHomeTown.text = game.awayTeam.homeTown
        awayTeamName.text = game.awayTeam.name
        awayScore.text = "\(game.awayScore)"
        
        homeHomeTown.text = game.homeTeam.homeTown
        homeTeamName.text = game.homeTeam.name
        homeScore.text = "\(game.homeScore)"
        
        timeLbl.text = game.startTime
        
        setFanMeter()
        
        challengeIndicatorImageView.alpha = game.challenge != nil ? 1 : 0
    }
    
    func setFanMeter(){
        let val = game.fanMeter ?? 0.5
        fanMeterLeadingConstraint.constant = (UIScreen.main.bounds.width - 40) * CGFloat(val)
    }
    
    func showPost(){
        imageBackgroundView.alpha = 0
        videoContainerView.alpha = 0
        player?.pause()
        progressBar.layer.removeAllAnimations()
        isAnimatingProgressBar = false
        photoTimer?.invalidate()
        
        player?.currentItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        player?.currentItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        player?.currentItem?.removeObserver(self, forKeyPath: "playbackBufferFull")
        player = nil
        
        if activePost >= posts.count{
            let alert = UIAlertController(title: "Oh No!", message: "No one has posted to this game yet. Start the excitement- add to the field!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (a) in
                alert.dismiss(animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                    self.dismiss(animated: true, completion: nil)
                })
            }))
            self.present(alert, animated: true) { }
            return
        }
        
        let post = posts[activePost]
        
        titleLbl.text = post.user.name
        timeAgoLbl.text = post.createdAt.timeAgoSince()
        likeCountLabel.text = "\(post.likeCnt ?? 0)"
       // likeBttn.setImage(post.liked ? #imageLiteral(resourceName: "happy_face_icon_selected") : #imageLiteral(resourceName: "happy_face_icon"), for: .normal)
        likeBttn.setImage(User.me.likedPosts.contains(post.id) ? #imageLiteral(resourceName: "happy_face_icon_selected") : #imageLiteral(resourceName: "happy_face_icon"), for: .normal)
        
        optionBttn.alpha = 1
        loadingActivityIndicator.alpha = 1
        
        let media = post.media!
        if let url = media.photoUrl{
            imageBackgroundView.alpha = 1
            imageBackgroundView.sd_setImage(with: url) { (_, _, _, _) in
                self.photoTimer = Timer.scheduledTimer(withTimeInterval: 6, repeats: false, block: { (t) in
                    self.nextPost()
                })
                self.animateProgressBar()
            }
        }else if let url = media.videoUrl{
            videoContainerView.alpha = 1
            player = AVPlayer(url: url)
            player?.volume = 1
            let playerController = AVPlayerViewController()
            playerController.player = player
            playerController.showsPlaybackControls = false
            playerController.videoGravity = AVLayerVideoGravity(rawValue: AVLayerVideoGravity.resizeAspectFill.rawValue)
            self.addChild(playerController)
            playerController.view.frame = videoContainerView.bounds
            videoContainerView.addSubview(playerController.view)
            
            player?.currentItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
            player?.currentItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
            player?.currentItem?.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(nextPost),
                                                   name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: player?.currentItem)
        }
        
    }
    
    func animateProgressBar(time: Double = 6){
        guard !isAnimatingProgressBar else { return }
        isAnimatingProgressBar = true
        
        guard viewLaidOut else {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self.isAnimatingProgressBar = false
                self.animateProgressBar(time: time)
            }
            return
        }
        
        loadingActivityIndicator.alpha = 0
        progressWidthConstraint.constant = CGFloat(activePost) / CGFloat(posts.count) * (self.view.frame.width-10)
        self.view.layoutIfNeeded()
        
        progressWidthConstraint.constant = CGFloat(activePost+1) / CGFloat(posts.count) * (self.view.frame.width-10)
        UIView.animate(withDuration: time, delay: 0, options: .curveLinear, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func nextPost(){
        activePost += 1
        if activePost >= posts.count{
            player?.pause()
            player?.currentItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
            player?.currentItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
            player?.currentItem?.removeObserver(self, forKeyPath: "playbackBufferFull")
            player = nil
            self.dismiss(animated: true, completion: nil)
            return
        }
        showPost()
    }
    @objc func backPost(){
        activePost = max(0, activePost - 1)
        showPost()
    }
    
    //MARK: IBActions
    @IBAction func likeBttnPressed(_ sender: Any) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let post = posts[activePost]
        /*
        if post.liked{
            ApiManager.shared.unlike(post: post.id, onSuccess: {
            }) { (err) in }
        }else{
            ApiManager.shared.like(post: post.id, onSuccess: {
            }) { (err) in }
        }
        post.liked = !post.liked
        likeBttn.setImage(post.liked ? #imageLiteral(resourceName: "happy_face_icon_selected") : #imageLiteral(resourceName: "happy_face_icon"), for: .normal)
        */
        
        if User.me.likedPosts.contains(post.id) {
            // already liked
            ApiManager.shared.unlike(post: post.id, onSuccess: {
                self.likeBttn.setImage(#imageLiteral(resourceName: "happy_face_icon"), for: .normal)
                User.me.likedPosts.removeAll(where: {$0 == post.id})
                
                let cnt = (post.likeCnt ?? 0) - 1
                let normalized = cnt >= 0 ? cnt : 0
                post.likeCnt = normalized
                
                self.likeCountLabel.text = "\(normalized)"
                
                UIApplication.shared.endIgnoringInteractionEvents()
            }, onError: {_ in 
                UIApplication.shared.endIgnoringInteractionEvents()
            })
            
        } else {
            // didn't like yet
            ApiManager.shared.like(post: post.id, onSuccess: {
                self.likeBttn.setImage(#imageLiteral(resourceName: "happy_face_icon_selected"), for: .normal)
                User.me.likedPosts.append(post.id)
                
                let cnt = (post.likeCnt ?? 0) + 1
                let normalized = cnt >= 0 ? cnt : 0
                post.likeCnt = normalized

                self.likeCountLabel.text = "\(normalized)"
                
                UIApplication.shared.endIgnoringInteractionEvents()
            }, onError: {_ in 
                UIApplication.shared.endIgnoringInteractionEvents()
            })
        }
        
    }
    
    @IBAction func optionBttnPressed(_ sender: Any) {
        player?.pause()
        progressBar.layer.removeAllAnimations()
        photoTimer?.invalidate()
        
        let alertController = UIAlertController(title: "Options", message: "", preferredStyle: .actionSheet)
        
        if posts[activePost].media.thumbnailUrl == nil {
            // its a picture so add option to save photo
            
            if let imageUrl = posts[activePost].media.photoUrl {
                let data = NSData(contentsOf: imageUrl)
                let image = UIImage(data: data! as Data)
                
                let saveAction = UIAlertAction(title: "Save Photo", style: .default) { (action) in
                    
                    UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                }
                
                alertController.addAction(saveAction)
            }
        }

        if posts[activePost].user.id == User.me.id{
            let deleteButton = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
                let post = self.posts[self.activePost]
                self.posts = self.posts.filter({ $0.id != post.id })
                self.activePost = max(self.activePost-1, 0)
                self.showPost()
                ApiManager.shared.deletePost(post: post.id, onSuccess: { }, onError: voidErr)
            })
            
            alertController.addAction(deleteButton)
            
        }else{
            let reportButton = UIAlertAction(title: "Report for abuse", style: .default) { (action) in
                let post = self.posts[self.activePost]
                
                let reports = UserDefaults.standard.object(forKey:"reports") as? [Int] ?? [Int]()
                
                if !reports.contains(post.id) {
                    // report post
                    ApiManager.shared.report(post: post.id, onSuccess: {}, onError: voidErr)
                    self.nextPost()
                }
            }
            alertController.addAction(reportButton)
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            print("Cancel button tapped")
            self.showPost()
        })
        
        alertController.addAction(cancelButton)
        
        self.present(alertController, animated: true, completion: nil)
    }
    @IBAction func backBttnPressed(_ sender: Any) {
        backPost()
    }
    @IBAction func nextBttnPressed(_ sender: Any) {
        nextPost()
    }
    @IBAction func commentBttpPressed(_ sender: Any) {
        player?.pause()
        progressBar.layer.removeAllAnimations()
        photoTimer?.invalidate()
        self.performSegue(withIdentifier: "comments", sender: posts[activePost])
    }
    
    //MARK: Nav
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CommentsViewController, let post = sender as? Post{
            vc.post = post
        }
    }
    
    //MARK: Util
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is AVPlayerItem {
            switch keyPath {
                case "playbackLikelyToKeepUp":
                    if let player = player, let item = player.currentItem, item.status == .readyToPlay{
                        player.play()
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                            let length = Double(CMTimeGetSeconds(item.duration))
                            self.animateProgressBar(time: length)
                        }
                    }
                default: return
            }
        }
    }
}
