//
//  ChallengeViewController.swift
//  SportsYap
//
//  Created by Alex Pelletier on 5/28/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

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
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func addShotBttnPressed(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            TagGameViewController.preselectedGame = self.game
            ParentScrollingViewController.shared.scrollToCamera()
        }
        self.dismiss(animated: true, completion: nil)
    }

}
