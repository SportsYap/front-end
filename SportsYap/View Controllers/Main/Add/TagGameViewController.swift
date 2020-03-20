//
//  TabGameViewController.swift
//  SportsYap
//
//  Created by Alex Pelletier on 4/23/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit
import Alamofire

class TagGameViewController: UIViewController, TagGameTableViewCellDelegate {
    
    static var preselectedGame: Game?
    
    @IBOutlet var addShotView: UIView!
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var uploadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var stateIndicatorImageView: UIImageView!
    @IBOutlet var addedSuccessLbl: UILabel!
    @IBOutlet var successTopSpace: NSLayoutConstraint!
    @IBOutlet weak var cancelBttn: UIButton!
    @IBOutlet weak var closeBttn: UIButton!
    
    @IBOutlet weak var previewImageView: UIImageView!
    
    @IBOutlet var atGameButton: UIButton!
    @IBOutlet var watchGameButton: UIButton!
    
    var media: UserMedia!
    var games = [Game]()
    var uploadCanceled = false
    
    var selectedGame: Game?
    var selectedTeam: Team?
    
    var atGame: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        atGameButton.layer.cornerRadius = 10
        atGameButton.layer.masksToBounds = false
        
        watchGameButton.layer.cornerRadius = 10
        watchGameButton.layer.masksToBounds = false
        
        if let g = TagGameViewController.preselectedGame{
            games = [g]
        }else{
            ApiManager.shared.searchGames(for: Date(), onSuccess: { (games) in
                self.games = games
                self.tableView.reloadData()
            }) { (err) in }
        }
        
        if media.photo != nil{
            previewImageView.image = media.photo
        }
    }

    func transitionToClose(){
        ParentScrollingViewController.shared.scrollToTabs()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        if TagGameViewController.preselectedGame == nil{
            ParentScrollingViewController.shared.enabled(is: true)
            TagGameViewController.preselectedGame = nil
        }
    }
    func uploadSuccess(){
        if let team = selectedTeam{
            self.addedSuccessLbl.text = "Added to \(team.name)'s Game Day"
        }
        self.stateIndicatorImageView.alpha = 1
        self.uploadingIndicator.alpha = 0
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            self.transitionToClose()
        })
        self.cancelBttn.alpha = 0
    }
    func uploadError(){
        self.stateIndicatorImageView.alpha = 1
        self.uploadingIndicator.alpha = 0
        self.stateIndicatorImageView.image = #imageLiteral(resourceName: "UploadFailed")
        self.addedSuccessLbl.text = "Uploaded Failed"
        self.cancelBttn.alpha = 0
        self.closeBttn.alpha = 1
        DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
            self.uploadStopped()
        })
    }
    func uploadStopped(){
        uploadCanceled = true
        Alamofire.SessionManager.default.session.getAllTasks { (tasks) in
            tasks.forEach{ $0.cancel() }
        }
        
        self.successTopSpace.constant = 1000
        self.cancelBttn.alpha = 1
        self.closeBttn.alpha = 0
        self.stateIndicatorImageView.image = #imageLiteral(resourceName: "shot_added_icon")
        self.uploadingIndicator.alpha = 1
        self.stateIndicatorImageView.alpha = 0
        self.addShotView.isUserInteractionEnabled = true
    }
    
    //MARK IBAction
    @IBAction func backBttnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func addShotBttnPressed(_ sender: Any) {
        if let game = selectedGame, let team = selectedTeam, let atGame = atGame {
            addShotView.isUserInteractionEnabled = false
            uploadCanceled = false
            
            if let photo = media.photo{
                ApiManager.shared.uploadPhoto(contentHeight: media!.contentHeight, game: game, team: team, atGame: atGame, photo: photo, onSuccess: {
                    self.uploadSuccess()
                }) { (err) in
                    if !self.uploadCanceled{
                        self.uploadError()
                    }
                }
            }else if let url = media.videoUrl{
                let thumb = MediaMerger.thumbnail(for: media)
                ApiManager.shared.uploadVideo(contentHeight: media!.contentHeight, game: game, team: team, atGame: atGame, video: url, thumbnail: thumb, onSuccess: {
                    self.uploadSuccess()
                }) { (err) in
                    if !self.uploadCanceled{
                        self.uploadError()
                    }
                }
            }
            
            self.successTopSpace.constant = 0
            self.addedSuccessLbl.text = "Uploading..."
        }
    }
    @IBAction func cancelBttnPressed(_ sender: Any) {
        uploadStopped()
    }
    
    
    @IBAction func atGamePressed(_ sender: Any) {
        if let atGame = atGame, atGame {
            self.atGame = nil
        } else {
            self.atGame = true
        }
        toggleGameButton()
    }
    
    @IBAction func watchingGamePressed(_ sender: Any) {
        if let atGame = atGame, !atGame {
            self.atGame = nil
        } else {
            self.atGame = false
        }
        toggleGameButton()
    }
    
    private func toggleGameButton() {
        if let atGame = atGame {
            atGameButton.backgroundColor = atGame ? UIColor(hex: "009BFF") : UIColor.lightGray
            watchGameButton.backgroundColor = atGame ? UIColor.lightGray : UIColor(hex: "009BFF")
            
        } else {
            atGameButton.backgroundColor = UIColor.lightGray
            watchGameButton.backgroundColor = UIColor.lightGray
        }
        
        if selectedGame != nil && atGame != nil {
            addShotView.backgroundColor = UIColor(hex: "009BFF")
        } else {
            addShotView.backgroundColor = UIColor.lightGray
        }
    }
    
    //MARK: TagGameTableViewCellDelegate
    func teamPressed(game: Game, team: Team){
        if team.id == selectedTeam?.id{
            selectedGame = nil
            selectedTeam = nil
        }else{
            selectedGame = game
            selectedTeam = team
        }
        tableView.reloadData()
        
        if selectedGame != nil && atGame != nil {
            addShotView.backgroundColor = UIColor(hex: "009BFF")
        } else {
            addShotView.backgroundColor = UIColor.lightGray
        }
        //addShotView.backgroundColor = selectedGame != nil ? UIColor(hex: "009BFF") : UIColor.lightGray
    }
}

extension TagGameViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "gameCell") as? TagGameTableViewCell{
            let game = games[indexPath.row]
            
            if game.awayTeam != nil{
                cell.awayHomeTown.text = game.awayTeam.homeTown
                cell.awayTeamName.text = game.awayTeam.name
                cell.awayScore.text = "\(game.awayScore)"
                cell.awayTeamPrimaryColorView.backgroundColor = game.awayTeam.primaryColor
                cell.awayTeamSecondaryColorView.backgroundColor = game.awayTeam.secondaryColor
            }
            
            if game.homeTeam != nil{
                cell.homeHomeTown.text = game.homeTeam.homeTown
                cell.homeTeamName.text = game.homeTeam.name
                cell.homeScore.text = "\(game.homeScore)"
                cell.homeTeamPrimaryColorView.backgroundColor = game.homeTeam.primaryColor
                cell.homeTeamSecondaryColorView.backgroundColor = game.homeTeam.secondaryColor
            }
            
            cell.sportBg.image = game.sport.image
            if game.venue != nil{
                cell.titleLbl.text = "\(game.venue.name) \(game.startTime)"
            }
            
            cell.game = game
            cell.delegate = self
            
            if selectedGame?.id == game.id{
                if selectedTeam?.id == game.awayTeam.id{
                    cell.awayTeamSelectedView.borderWidth = 6
                    cell.homeTeamSelectedView.borderWidth = 0
                }else{
                    cell.awayTeamSelectedView.borderWidth = 0
                    cell.homeTeamSelectedView.borderWidth = 6
                }
            }else{
                cell.awayTeamSelectedView.borderWidth = 0
                cell.homeTeamSelectedView.borderWidth = 0
            }
            return cell
        }
        return UITableViewCell()
    }
}
