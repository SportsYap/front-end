//
//  SignupViewController.swift
//  SportsYap
//
//  Created by Alex Pelletier on 2/6/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var locationTextField: UITextField!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 10, *) {
            usernameTextField.textContentType = UITextContentType(rawValue: "")
            passwordTextField.textContentType = UITextContentType(rawValue: "")
        }
    }

    //MARK: IBActions
    @IBAction func continueBttnPressed(_ sender: Any) {
        ApiManager.shared.signup(name: nameTextField.text!, email: usernameTextField.text!, password: passwordTextField.text!, {
            ApiManager.shared.me(onSuccess: { (user) in
                
                User.me.location = self.locationTextField.text!
                ApiManager.shared.updateSelf(onSuccess: { }, onError: voidErr)
                
                self.performSegue(withIdentifier: "selectTeams", sender: nil)
            }, onError: { (err) in
                self.alert(message: "Internal Server Error Loading Self")
            })
        }) { (err) in
            self.alert(message: "Internal Server Error Signing Up")
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
    
    @IBAction func cancelBttnPressed(_ sender: Any) {
    }
    
    //MARK: UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == usernameTextField{
            scrollView.setContentOffset(CGPoint(x: 0, y: 80), animated: true)
        }else if textField == passwordTextField{
            scrollView.setContentOffset(CGPoint(x: 0, y: 120), animated: true)
        }else if textField == locationTextField{
            scrollView.setContentOffset(CGPoint(x: 0, y: 10), animated: true)
        }else if textField == nameTextField{
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
}
