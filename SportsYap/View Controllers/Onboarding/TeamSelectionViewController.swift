//
//  TeamSelectionViewController.swift
//  SportsYap
//
//  Created by Alex Pelletier on 2/6/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

class TeamSelectionViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var sportTypeBgViews: [UIView]!
    
    var selectedSport = Sport.football
    var teams = [Team]()
    var selectedTeams = [Team]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        search()
    }

    func search(){
        let q = searchBar.text ?? ""
        ApiManager.shared.teams(for: selectedSport, search: q, onSuccess: { (teams) in
            self.teams = teams.alphabetized
            self.tableView.reloadData()
        }) { (err) in }
    }
    
    //MARK: IBAction
    @IBAction func continueBttnPressed(_ sender: Any) {
        for team in selectedTeams {
            ApiManager.shared.follow(team: team.id, onSuccess: {
                team.followed = true
                if !User.me.teams.contains(team) {
                    User.me.teams.append(team)
                }
            }, onError: { (err) in })
        }
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func backBttnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func cancelBttnPressed(_ sender: Any) {
        
    }
    @IBAction func sportBttnPressed(_ sender: UIButton) {
        if let s = Sport(rawValue: sender.tag){
            selectedSport = s
            
            for view in sportTypeBgViews{
                view.backgroundColor = view.tag == s.rawValue ? UIColor(hex: "479BF7") : UIColor(hex: "202638")
            }
            
            search()
        }
    }
    
    //MARK: UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        search()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        search()
    }
}

extension TeamSelectionViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : self.teams.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell"){
                cell.selectionStyle = .none
                return cell
            }
        } else if indexPath.section == 1 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "teamCell") as? OnboardingTeamTableViewCell{
                let team = teams[indexPath.row]
                cell.team = team
                if selectedTeams.contains(team) {
                    cell.followButton.setTitle("Unfollow", for: .normal)
                } else {
                    cell.followButton.setTitle("+ Follow", for: .normal)
                }
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 91 : 52
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let team = teams[indexPath.row]
        if selectedTeams.contains(team) {
            selectedTeams.remove(at: selectedTeams.index(of: team)!)
        } else {
            selectedTeams.append(team)
        }
        tableView.reloadData()
    }
}
