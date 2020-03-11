//
//  LoginViewController.swift
//  SportsYap
//
//  Created by Alex Pelletier on 2/6/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit
import MessageUI

class LoginViewController: UIViewController{

    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    //MARK: IBActions
    @IBAction func forgotPasswordBttnPressed(_ sender: Any) {
        guard MFMailComposeViewController.canSendMail() else {
            alert(message: "You don't have email setup on this phone.")
            return
        }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.setToRecipients(["support@sportsyap.com"])
        composeVC.setSubject("Reset Password")
        composeVC.setMessageBody("I would like to reset my password.", isHTML: false)
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    @IBAction func signinBttnPressed(_ sender: Any) {
        ApiManager.shared.login(email: usernameTextField.text!, password: passwordTextField.text!, {
            ApiManager.shared.me(onSuccess: { (user) in
            }, onError: voidErr)
            self.dismiss(animated: true, completion: nil)
        }) { (err) in
            self.alert(message: "Invalid username of password")
        }
    }
    @IBAction func passwordShowBttnPressed(_ sender: Any) {
        guard let bttn = sender as? UIButton else{ return }
        if passwordTextField.isSecureTextEntry{
            passwordTextField.isSecureTextEntry = false
            bttn.setTitle("Hide", for: .normal)
        }else{
            passwordTextField.isSecureTextEntry = true
            bttn.setTitle("Show", for: .normal)
        }
    }
    @IBAction func backBttnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

extension LoginViewController: MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
