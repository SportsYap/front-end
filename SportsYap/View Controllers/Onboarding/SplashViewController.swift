//
//  SplashViewController.swift
//  SportsYap
//
//  Created by Master on 2020/4/12.
//  Copyright © 2020 Alex Pelletier. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ApiManager.shared.validateAccessToken(onSuccess: {
            self.performSegue(withIdentifier: "showMain", sender: nil)
        }) { (error) in
            self.performSegue(withIdentifier: "showAuth", sender: nil)
        }
    }
}
