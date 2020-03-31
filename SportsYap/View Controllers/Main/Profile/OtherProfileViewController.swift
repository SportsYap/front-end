//
//  OtherProfileViewController.swift
//  SportsYap
//
//  Created by Master on 2020/3/31.
//  Copyright © 2020 Alex Pelletier. All rights reserved.
//

import UIKit

class OtherProfileViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var teamsLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    
    @IBOutlet weak var teamsStackView: UIStackView!
    @IBOutlet weak var teamsStackViewSpace: NSLayoutConstraint!

    var user: User!
    private var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backButton.alpha = navigationController?.viewControllers.count == 1 ? 0 : 1
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.gray
        tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadContent()
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ShotViewController, let game = sender as? Game{
            vc.game = game
            vc.posts = game.posts.reversed()
        } else if let vc = segue.destination as? ViewUsersViewController, let m = sender as? ViewUsersMode {
            vc.mode = m
            vc.rootUser = user
        }
    }
}

extension OtherProfileViewController {
    private func displayUser() {
        let user = User.me
        
        profileImageView.sd_setImage(with: user.profileImage, placeholderImage: #imageLiteral(resourceName: "default-profile"))
        nameLabel.text = user.name
        locationLabel.text = user.location

        teamsLabel.text = "\(user.teams.count)"
        followingLabel.text = "\(user.followingCnt)"
        followersLabel.text = "\(user.followerCnt)"

        for subview in teamsStackView.arrangedSubviews {
            if let subview = subview as? TeamBadgeView {
                teamsStackView.removeArrangedSubview(subview)
                subview.removeFromSuperview()
            }
        }
        
        var index = 1
        for team in user.teams {
            if let teamView = Bundle.main.loadNibNamed("TeamBadgeView", owner: nil, options: nil)?.first as? TeamBadgeView {
                teamView.team = team
                teamsStackView.insertArrangedSubview(teamView, at: index)
                index += 1
            }
        }
        
        let contentWidth = teamsStackView.bounds.size.width - teamsStackViewSpace.constant * 2
        if contentWidth > view.bounds.size.width - 40 {
            teamsStackViewSpace.constant = 20
        } else {
            teamsStackViewSpace.constant = (contentWidth - view.bounds.size.width) / 2
        }
    }
    
    @objc private func reload() {
        user = nil
    }
    
    private func loadContent() {
        displayUser()
        
        ApiManager.shared.user(for: user.id, onSuccess: { (user) in
            self.user = user
            self.displayUser()
            self.tableView.reloadData()
        }) { (err) in }
    }
    
    @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
        loadContent()
        refreshControl.endRefreshing()
    }
}

extension OtherProfileViewController {
    //MARK: IBAction
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onFollow(_ sender: Any) {
        if user.id != User.me.id {
            if user.followed {
                ApiManager.shared.unfollow(user: user.id, onSuccess: {
                    self.followButton.setTitle(NSLocalizedString("Follow", comment: ""), for: .normal)
                }, onError: voidErr)
            } else {
                ApiManager.shared.follow(user: user.id, onSuccess: {
                    self.followButton.setTitle(NSLocalizedString("Unfollow", comment: ""), for: .normal)
                }, onError: voidErr)
            }
            user.followed = !user.followed
            tableView.reloadData()
        } else {
            performSegue(withIdentifier: "settings", sender: nil)
        }
    }

    @IBAction func onTapTeams(_ sender: Any) {
        performSegue(withIdentifier: "viewTeams", sender: nil)
    }

    @IBAction func onTapFollowings(_ sender: Any) {
        performSegue(withIdentifier: "viewUsers", sender: ViewUsersMode.following)
    }
    
    @IBAction func onTapFollowers(_ sender: Any) {
        performSegue(withIdentifier: "viewUsers", sender: ViewUsersMode.followers)
    }
}

extension OtherProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "gameCard") as? ProfilePostTableViewCell {
            let post = user.posts[indexPath.row]
            cell.post = post
            cell.selectionStyle = .none
            return cell
        }

        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        performSegue(withIdentifier: "showPost", sender: user.games[indexPath.row])
    }
}
