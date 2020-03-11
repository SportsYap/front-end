//
//  ProfileViewController.swift
//  SportsYap
//
//  Created by Alex Pelletier on 2/6/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet var backBttn: UIButton!
    @IBOutlet var settingsBttn: UIButton!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var tableView: UITableView!
    
    var user: User!
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backBttn.alpha = navigationController?.viewControllers.count == 1 ? 0 : 1
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.gray
        tableView.addSubview(refreshControl)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: NSNotification.Name(rawValue: "api-token-changed"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadContent()
    }
    
    @objc func reload(){
        user = nil
    }
    
    func loadContent(){
        if user == nil{
            user = User.me
            settingsBttn.alpha = 1
        }
        
        ApiManager.shared.user(for: user.id, onSuccess: { (user) in
            self.user = user
            self.tableView.reloadData()
        }) { (err) in }
        
        titleLbl.text = user.firstname
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        loadContent()
        refreshControl.endRefreshing()
    }
    
    //MARK: IBAction
    @IBAction func backBttnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func settingBttnPressed(_ sender: Any) {
        guard user.id == User.me.id else { return }
        self.performSegue(withIdentifier: "settings", sender: nil)
    }
    @IBAction func reportBttnPressed(_ sender: Any) {
        showAbuseAlert()
    }
    
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ShotViewController, let game = sender as? Game{
            vc.game = game
            vc.posts = game.posts.reversed()
        }else if let vc = segue.destination as? ViewUsersViewController, let m = sender as? ViewUsersMode{
            vc.mode = m
            vc.rootUser = user
        }
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource, ProfileHeaderTableViewCellDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : user.games.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as? ProfileHeaderTableViewCell{
                cell.nameLbl.text = user.name
                cell.locationLbl.text = user.location
                cell.shotCntLbl.text = "\(user.shotsCnt)"
                cell.followingCntLbl.text = "\(user.followingCnt)"
                cell.followerCntLbl.text = "\(user.followerCnt)"
                cell.teams = user.teams
                cell.isVerifiedImageView.alpha = user.verified ? 1 : 0
                cell.followBttn.alpha = User.me.id == user.id ? 0 : 1
                cell.followBttn.setTitle(user.followed ? "Following" : "Follow", for: .normal)
                if let url = user.profileImage{
                    cell.profileImageView.imageFromUrl(url: url)
                }else{
                    cell.profileImageView.image = #imageLiteral(resourceName: "default-profile")
                }
                cell.delegate = self
                cell.selectionStyle = .none
                return cell
            }
        }else if indexPath.section == 1{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "gameCard") as? ProfilePostTableViewCell{
                let game = user.games[indexPath.row]
                cell.card.load(game: game)
                cell.selectionStyle = .none
                return cell
            }
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return User.me.id != user.id ? 295 : 257
        }
        return 160
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1{
            self.performSegue(withIdentifier: "showPost", sender: user.games[indexPath.row])
        }
    }
    
    //MARK: ProfileHeaderTableViewCellDelegate
    func followingBttnPressed(){
        self.performSegue(withIdentifier: "viewUsers", sender: ViewUsersMode.following)
    }
    func followersBttnPressed(){
        self.performSegue(withIdentifier: "viewUsers", sender: ViewUsersMode.followers)
    }
    func followBttnPressed(){
        if user.followed{
            ApiManager.shared.unfollow(user: user.id, onSuccess: { }, onError: voidErr)
        }else{
            ApiManager.shared.follow(user: user.id, onSuccess: { }, onError: voidErr)
        }
        user.followed = !user.followed
        tableView.reloadData()
    }
}
