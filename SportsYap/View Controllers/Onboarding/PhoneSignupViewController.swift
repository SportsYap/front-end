//
//  PhoneSignupViewController.swift
//  SportsYap
//
//  Created by Alex Pelletier on 10/26/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit
import FirebaseAuth

class PhoneSignupViewController: UIViewController {

    @IBOutlet weak var phoneTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    //MARK: IBAction
    @IBAction func backBttnPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func sendBttnPressed(_ sender: Any) {
        guard let bttn = sender as? UIButton else { return }
        let phone = (phoneTextField.text!).replacingOccurrences(of: "+1", with: "")
        
        if phone != ""{
            bttn.isEnabled = false
            PhoneAuthProvider.provider().verifyPhoneNumber("+1 \(phone)", uiDelegate: nil) { (verificationID, error) in
                bttn.isEnabled = true
                if let error = error {
                    self.alert(message: error.localizedDescription)
                    return
                }
                print("Code: \(verificationID ?? "")")
                if let id = verificationID{
                    User.me = User()
                    User.me.phone = phone
                    self.performSegue(withIdentifier: "showVerification", sender: id)
                }
            }
        }else{
            alert(message: "Please fill out all of the fields")
        }
    }
    @IBAction func phoneNumberBttnPressed(_ sender: Any) {
        phoneTextField.becomeFirstResponder()
    }
    
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PhoneVerificationViewController, let id = sender as? String{
            vc.verificationId = id
        }
    }
}
