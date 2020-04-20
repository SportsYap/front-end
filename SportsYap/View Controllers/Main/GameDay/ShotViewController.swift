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
import SideMenu

class ShotViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!

    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var fistbumpButton: UIButton!
    @IBOutlet weak var fistbumpLabel: UILabel!
    
    @IBOutlet weak var fanMeterView: UIView!
    @IBOutlet weak var expandFanMeterButton: UIButton!
    @IBOutlet weak var fanMeterViewBottom: NSLayoutConstraint!
    @IBOutlet weak var viewFanMeterLabel: UILabel!
    
    @IBOutlet weak var awayHomeTownLabel: UILabel!
    @IBOutlet weak var awayTeamNameLabel: UILabel!
    @IBOutlet weak var awayScoreLabel: UILabel!
    @IBOutlet weak var homeHomeTownLabel: UILabel!
    @IBOutlet weak var homeTeamNameLabel: UILabel!
    @IBOutlet weak var homeScoreLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var fanMeterLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var progressBar: UIView!
    @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageBackgroundView: UIImageView!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var challengeIndicatorImageView: UIImageView!
    
    var game: Game!
    var posts = [Post]()
    
    private var activePost = 0
    private var media: UserMedia!
    private var player: AVPlayer?
    private var photoTimer: Timer?
    private var viewLaidOut = false
    private var isAnimatingProgressBar = false
    private var isFanMeterExpanded: Bool = true
    
    private var myLikes = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressWidthConstraint.constant = 1
        
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        
        if posts.count == 0 {
            ApiManager.shared.story(for: game, page: 1, onSuccess: { (posts) in
                self.posts = posts
                self.showPost()
            }) { (err) in }
        } else {
            showPost()
        }
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

extension ShotViewController {
    private func setUI() {
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
        
        awayHomeTownLabel.text = game.awayTeam.homeTown
        awayTeamNameLabel.text = game.awayTeam.name
        awayScoreLabel.text = "\(game.awayScore)"
        
        homeHomeTownLabel.text = game.homeTeam.homeTown
        homeTeamNameLabel.text = game.homeTeam.name
        homeScoreLabel.text = "\(game.homeScore)"
        
        timeLabel.text = game.startTime
        
        setFanMeter()
        
        challengeIndicatorImageView.alpha = game.challenge != nil ? 1 : 0
    }
    
    private func setFanMeter() {
        let val = game.fanMeter ?? 0.5
        fanMeterLeadingConstraint.constant = (UIScreen.main.bounds.width - 40) * CGFloat(val)
    }
    
    private func showPost() {
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
        myLikes = post.myLikes
        
        titleLabel.text = post.user.name
        teamNameLabel.text = post.team?.name ?? ""
        timeAgoLabel.text = post.createdAt.timeAgoSince()
        
        commentButton.setImage(UIImage(named: (post.myComments == 0) ? "comment_bubble" : "comment bubble"), for: .normal)
        fistbumpButton.setImage(UIImage(named: (post.myLikes == 0) ? "fist_bubble" : "fist bubble"), for: .normal)
        if post.myLikes > 0 {
            fistbumpLabel.text = "+\(post.myLikes)"
            fistbumpLabel.textColor = UIColor(hex: "009BFF")
        } else {
            fistbumpLabel.text = "\(post.likeCnt)"
            fistbumpLabel.textColor = UIColor.white
        }
        
        loadingActivityIndicator.alpha = 1
        
        let media = post.media!
        if let url = media.photoUrl {
            imageBackgroundView.alpha = 1
            imageBackgroundView.sd_setImage(with: url) { (_, _, _, _) in
                self.photoTimer = Timer.scheduledTimer(withTimeInterval: 6, repeats: false, block: { (t) in
                    self.nextPost()
                })
                self.animateProgressBar()
            }
        } else if let url = media.videoUrl {
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
    
    private func animateProgressBar(time: Double = 6) {
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
    
    @objc private func nextPost() {
        activePost += 1
        if activePost >= posts.count {
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
    
    @objc private func backPost() {
        activePost = max(0, activePost - 1)
        showPost()
    }
}

extension ShotViewController {
    //MARK: IBActions
    @IBAction func onOptions(_ sender: Any) {
        player?.pause()
        progressBar.layer.removeAllAnimations()
        photoTimer?.invalidate()
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if posts[activePost].media.thumbnailUrl == nil {
            // its a picture so add option to save photo
            if let imageUrl = posts[activePost].media.photoUrl {
                let data = NSData(contentsOf: imageUrl)
                let image = UIImage(data: data! as Data)
                
                let saveAction = UIAlertAction(title: "Save Image", style: .default) { (action) in
                    UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                }
                
                alertController.addAction(saveAction)
            }
        }

        if posts[activePost].user.id == User.me.id {
            let deleteButton = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
                let post = self.posts[self.activePost]
                self.posts = self.posts.filter({ $0.id != post.id })
                self.activePost = max(self.activePost-1, 0)
                self.showPost()
                ApiManager.shared.deletePost(post: post.id, onSuccess: { }, onError: voidErr)
            })
            
            alertController.addAction(deleteButton)
        } else {
            let reportButton = UIAlertAction(title: "Report Abuse", style: .default) { (action) in
                let post = self.posts[self.activePost]
                
                let reports = UserDefaults.standard.object(forKey:"reports") as? [Int] ?? [Int]()
                
                if !reports.contains(post.id) {
                    // report post
                    ApiManager.shared.report(post: post.id, onSuccess: { deleted in
                        if deleted {
                            NotificationCenter.default.post(name: NSNotification.Name(Post.deletePostNotification), object: post)
                        }
                    }, onError: voidErr)
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
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onBack(_ sender: Any) {
        backPost()
    }
    
    @IBAction func onNext(_ sender: Any) {
        nextPost()
    }
    
    @IBAction func onComment(_ sender: Any) {
        player?.pause()
        progressBar.layer.removeAllAnimations()
        photoTimer?.invalidate()
        
        performSegue(withIdentifier: "comments", sender: posts[activePost])
    }
    
    @IBAction func onFistBump(_ sender: Any) {
        myLikes += 1
        
        let post = posts[activePost]

        self.fistbumpButton.setImage(UIImage(named: "fist bubble"), for: .normal)
        self.fistbumpLabel.text = "+\(myLikes)"
        self.fistbumpLabel.textColor = UIColor(hex: "009BFF")

        ApiManager.shared.like(post: post.id, onSuccess: {
            post.liked = true
            post.myLikes += 1
            post.likeCnt += 1

            if !User.me.likedPosts.contains(post.id) {
                User.me.likedPosts.append(post.id)
            }
        }, onError: {_ in

        })
    }
    
    @IBAction func onAdd(_ sender: Any) {
        TagGameViewController.preselectedGame = game
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
    
    @IBAction func onExpandFanMeter(_ sender: Any) {
        isFanMeterExpanded = !isFanMeterExpanded
        
        UIView.animate(withDuration: 0.1, animations: {
            self.viewFanMeterLabel.alpha = self.isFanMeterExpanded ? 0 : 1
            self.fanMeterView.alpha = self.isFanMeterExpanded ? 1 : 0
            self.fanMeterViewBottom.constant = self.isFanMeterExpanded ? 0 : (self.fanMeterView.bounds.size.height - 10)
        }) { (_) in
            self.expandFanMeterButton.setImage(UIImage(named: self.isFanMeterExpanded ? "collapse_fanmeter" : "expand_fanmeter"), for: .normal)
        }
    }
}
