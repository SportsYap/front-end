//
//  TabGameViewController.swift
//  SportsYap
//
//  Created by Alex Pelletier on 4/23/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit
import Alamofire
import SideMenu

class TagGameViewController: UIViewController {
    
    @IBOutlet weak var addShotView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var uploadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var stateIndicatorImageView: UIImageView!
    @IBOutlet weak var addedSuccessLabel: UILabel!
    @IBOutlet weak var successTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var previewImageView: UIImageView!
    
    static var preselectedGame: Game?
    var media: UserMedia!

    private var games = [Game]()
    private var uploadCanceled = false
    
    private var selectedGame: Game?
    private var selectedTeam: Team?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let g = TagGameViewController.preselectedGame {
            games = [g]
        } else {
            ApiManager.shared.searchGames(for: Date(), onSuccess: { (games) in
                self.games = games
                self.tableView.reloadData()
            }) { (err) in }
        }
        
        if media.photo != nil {
            previewImageView.image = media.photo
        }
    }
}

extension TagGameViewController {
    private func transitionToClose() {
        if let vc = navigationController as? SideMenuNavigationController {
            vc.dismiss(animated: true) {
                vc.popToRootViewController(animated: true)
            }
        } else if let nav = navigationController,
            nav.viewControllers.count > 2 {
            let vc = nav.viewControllers[nav.viewControllers.count - 3]
            nav.popToViewController(vc, animated: true)
        }
    }
    
    private func uploadSuccess(_ post: Post) {
        if let game = post.game {
            if !game.fans.contains(post.user) {
                game.fans.append(post.user)
            }
            if !game.posts.contains(post) {
                game.posts.append(post)
            }
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Post.newPostNotification), object: post)
        
        if let team = selectedTeam {
            addedSuccessLabel.text = "Added to \(team.name)'s Game Day"
        }
        stateIndicatorImageView.alpha = 1
        uploadingIndicator.alpha = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            self.transitionToClose()
        })
        cancelButton.alpha = 0
    }
    
    private func uploadError() {
        stateIndicatorImageView.alpha = 1
        uploadingIndicator.alpha = 0
        stateIndicatorImageView.image = #imageLiteral(resourceName: "UploadFailed")
        addedSuccessLabel.text = "Uploaded Failed"
        cancelButton.alpha = 0
        closeButton.alpha = 1
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
            self.uploadStopped()
        })
    }
    
    private func uploadStopped() {
        uploadCanceled = true
        
        Alamofire.SessionManager.default.session.getAllTasks { (tasks) in
            tasks.forEach{ $0.cancel() }
        }
        
        successTopConstraint.constant = 1000
        cancelButton.alpha = 1
        closeButton.alpha = 0
        stateIndicatorImageView.image = #imageLiteral(resourceName: "shot_added_icon")
        uploadingIndicator.alpha = 1
        stateIndicatorImageView.alpha = 0
        addShotView.isUserInteractionEnabled = true
    }

    private func toggleGameButton() {
        if selectedGame != nil {
            addShotView.backgroundColor = UIColor(hex: "009BFF")
        } else {
            addShotView.backgroundColor = UIColor.lightGray
        }
    }
}

extension TagGameViewController {
    //MARK IBAction
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onAddShot(_ sender: Any) {
        if let game = selectedGame, let team = selectedTeam {
            addShotView.isUserInteractionEnabled = false
            uploadCanceled = false
            
            if let photo = media.photo {
                ApiManager.shared.uploadPhoto(contentHeight: media!.contentHeight, game: game, team: team, photo: photo, onSuccess: { post in
                    self.uploadSuccess(post)
                }) { (err) in
                    if !self.uploadCanceled{
                        self.uploadError()
                    }
                }
            } else if let url = media.videoUrl {
                let thumb = MediaMerger.thumbnail(for: media)
                ApiManager.shared.uploadVideo(contentHeight: media!.contentHeight, game: game, team: team, video: url, thumbnail: thumb, onSuccess: { post in
                    self.uploadSuccess(post)
                }) { (err) in
                    if !self.uploadCanceled{
                        self.uploadError()
                    }
                }
            }
            
            successTopConstraint.constant = 0
            addedSuccessLabel.text = "Uploading..."
        }
    }
    
    @IBAction func onCancel(_ sender: Any) {
        uploadStopped()
    }
}

extension TagGameViewController: TagGameTableViewCellDelegate {
    func didSelectTeam(game: Game, team: Team) {
        if team.id == selectedTeam?.id {
            selectedGame = nil
            selectedTeam = nil
        } else {
            selectedGame = game
            selectedTeam = team
        }
        tableView.reloadData()
        
        if selectedGame != nil {
            addShotView.backgroundColor = UIColor(hex: "009BFF")
        } else {
            addShotView.backgroundColor = UIColor.lightGray
        }
    }
}

extension TagGameViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "gameCell") as? TagGameTableViewCell {
            let game = games[indexPath.row]
            cell.game = game
            cell.delegate = self
            
            if selectedGame?.id == game.id {
                if selectedTeam?.id == game.awayTeam.id {
                    cell.awayTeamSelectedView.borderWidth = 6
                    cell.homeTeamSelectedView.borderWidth = 0
                } else {
                    cell.awayTeamSelectedView.borderWidth = 0
                    cell.homeTeamSelectedView.borderWidth = 6
                }
            } else {
                cell.awayTeamSelectedView.borderWidth = 0
                cell.homeTeamSelectedView.borderWidth = 0
            }

            return cell
        }
        
        return UITableViewCell()
    }
}
