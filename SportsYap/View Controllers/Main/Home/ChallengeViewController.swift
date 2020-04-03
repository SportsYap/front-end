//
//  ChallengeViewController.swift
//  SportsYap
//
//  Created by Alex Pelletier on 5/28/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit
import SideMenu

class ChallengeViewController: UIViewController {
    
    @IBOutlet var challengeDescLbl: UILabel!
    
    var challenge: Challenge!
    var game: Game!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        challengeDescLbl.text = challenge.text
    }
    
    //MARK: IBAction
    @IBAction func notNowBttnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addShotBttnPressed(_ sender: Any) {
        dismiss(animated: true) {
            TagGameViewController.preselectedGame = self.game
            self.present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
        }
    }
}
