//
//  ViewLiveStreamViewController.swift
//  SportsYap
//
//  Created by Alex Pelletier on 6/6/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit
import AVKit

class ViewLiveStreamViewController: UIViewController {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var streamingContentView: UIView!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    var user: User!
    var player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }

        titleLbl.text = user.name
        
        if let url = user.streamingUrl{
            player = AVPlayer(url: url)
            player?.volume = 1
            player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.new, .old], context: nil)
            let playerController = AVPlayerViewController()
            playerController.player = player
            playerController.showsPlaybackControls = false
            playerController.videoGravity = AVLayerVideoGravity(rawValue: AVLayerVideoGravity.resizeAspectFill.rawValue)
            self.addChild(playerController)
            playerController.view.frame = streamingContentView.bounds
            streamingContentView.addSubview(playerController.view)
            
            player?.play()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus" {
            print("[STATUS] \(player!.timeControlStatus)")
            if player?.timeControlStatus == AVPlayer.TimeControlStatus.playing{
                loadingActivityIndicator.alpha = 0
            }
        }
    }
    
    //MARK: IBAction
    @IBAction func backBttnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
