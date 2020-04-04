//
//  ViewTeamsViewController.swift
//  SportsYap
//
//  Created by Master on 2020/4/5.
//  Copyright © 2020 Alex Pelletier. All rights reserved.
//

import UIKit

class ViewTeamsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var teams: [Team]!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        teams = teams.alphabetized
        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor(hex: "999999", alpha: 0.2)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}


extension ViewTeamsViewController {
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension ViewTeamsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "teamCell") as? OnboardingTeamTableViewCell {
            let team = teams[indexPath.row]
            cell.team = team
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let team = teams[indexPath.row]
        if team.followed {
            ApiManager.shared.unfollow(team: team.id, onSuccess: {
                team.followed = false
                if let index = User.me.teams.index(of: team) {
                    User.me.teams.remove(at: index)
                }
                
                self.tableView.reloadData()
            }, onError: { (err) in })
        } else {
            ApiManager.shared.follow(team: team.id, onSuccess: {
                team.followed = true
                if !User.me.teams.contains(team) {
                    User.me.teams.append(team)
                }
                
                self.tableView.reloadData()
            }, onError: { (err) in })
        }
    }
}