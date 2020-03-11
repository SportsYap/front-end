//
//  AccountDetailsViewController.swift
//  SportsYap
//
//  Created by Alex Pelletier on 10/30/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

class SetupAccountViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var fullnameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    //MARK: IBActions
    @IBAction func continueBttnPressed(_ sender: Any) {
        let username = usernameTextField.text!
        let loc = locationTextField.text!
        let name = fullnameTextField.text!
        
        if username != "" && loc != "" && name != ""{
            User.me.name = username
            User.me.location = loc
            
            let parts = name.split(maxSplits: 2, omittingEmptySubsequences: true) { (char) -> Bool in
                return char == " "
            }
            if parts.count == 1{
                User.me.firstName = String(parts[0])
                User.me.lastName = ""
            }else if parts.count == 2{
                User.me.firstName = String(parts[0])
                User.me.lastName = String(parts[1])
            }
            
            ApiManager.shared.updateSelf(onSuccess: {
                self.performSegue(withIdentifier: "selectTeams", sender: nil)
            }, onError: voidErr)
        }else{
            self.alert(message: "Please fill out all of the fields")
        }
    }
    
}
