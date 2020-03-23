//
//  ViewUsersViewController.swift
//  SportsYap
//
//  Created by Alex Pelletier on 5/22/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

enum ViewUsersMode {
    case following
    case followers
    
    func title() -> String{
        switch self {
            case .following: return "Following"
            case .followers: return "Followers"
        }
    }
}

class ViewUsersViewController: UIViewController {

    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var tableView: UITableView!
    
    var users = [User]()
    var rootUser: User!
    
    var mode: ViewUsersMode!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLbl.text = mode.title()
        
        let onSuccess: (_ users: [User])->Void = { (users) in
            ApiManager.shared.following(user: User.me.id, onSuccess: { (followingUsers) in
                let followingUserIds = followingUsers.map({ $0.id })
                self.users = users.map({ (user) -> User in
                    user.followed = followingUserIds.contains(user.id)
                    return user
                })
                self.tableView.reloadData()
            }, onError: voidErr)
        }
        
        if mode == .followers{
            ApiManager.shared.followers(user: rootUser.id, onSuccess: onSuccess, onError: voidErr)
        }else if mode == .following{
            ApiManager.shared.following(user: rootUser.id, onSuccess: onSuccess, onError: voidErr)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //MARK: IBAction
    @IBAction func backBttnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Nav
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ProfileViewController{
            if let user = sender as? User{
                vc.user = user
            }
        }
    }
}

extension ViewUsersViewController: UITableViewDataSource, UITableViewDelegate, UserTableViewCellDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as? UserTableViewCell{
            let user = users[indexPath.row]
            cell.nameLbl.text = user.name
            cell.hometownLbl.text = user.location
            cell.isVerifiedImageView.alpha = user.verified ? 1 : 0
            cell.user = user
            cell.delegate = self
            cell.selectionStyle = .none
            cell.profileImageView.sd_setImage(with: user.profileImage, placeholderImage: #imageLiteral(resourceName: "default-profile"))
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        performSegue(withIdentifier: "showProfile", sender: user)
    }
    
    func followBttnPressed(user: User){
        if user.followed{
            ApiManager.shared.unfollow(user: user.id, onSuccess: {
            }) { (err) in }
        }else{
            ApiManager.shared.follow(user: user.id, onSuccess: {
            }) { (err) in }
        }
    }
}
