//
//  PhoneVerificationViewController.swift
//  SportsYap
//
//  Created by Alex Pelletier on 10/26/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit
import FirebaseAuth

class PhoneVerificationViewController: UIViewController {
    
    @IBOutlet weak var codeTextField: UITextField!
    
    var verificationId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    //MARK: IBAction
    @IBAction func confirmBttnPressed(_ sender: Any) {
        guard let bttn = sender as? UIButton else { return }
        bttn.isEnabled = false
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: codeTextField.text!)
        Auth.auth().signInAndRetrieveData(with: credential) { authData, error in
            if let error = error {
                bttn.isEnabled = true
                self.alert(message: error.localizedDescription)
                return
            }
            print("Signed In")
            authData?.user.getIDToken(completion: { (code, err) in
                guard err == nil else {
                    bttn.isEnabled = true
                    self.alert(message: err.debugDescription)
                    return
                }
                if let code = code{
                    ApiManager.shared.phoneLogin(phone: User.me.phone, name: "-", token: code, { (created) in
                        if created{
                            ApiManager.shared.me(onSuccess: { (user) in
                                self.performSegue(withIdentifier: "showSetup", sender: nil)
                            }, onError: { err in
                                bttn.isEnabled = true
                                self.alert(message: "Internal Server Error")
                            })
                        }else{
                            ApiManager.shared.me(onSuccess: { (user) in
                                if user.name != "-"{
                                    self.navigationController?.dismiss(animated: true, completion: nil)
                                }else{
                                    self.performSegue(withIdentifier: "showSetup", sender: nil)
                                }
                            }, onError: { err in
                                bttn.isEnabled = true
                                self.alert(message: "Internal Server Error")
                            })
                        }
                    }, onError: { (err) in
                        bttn.isEnabled = true
                        self.alert(message: "Internal Server Error")
                    })
                }else{
                    bttn.isEnabled = true
                    self.alert(message: "Please resent the code and try again.")
                }
            })
        }
    }
    @IBAction func resendCodeBttnPressed(_ sender: Any) {
        guard let bttn = sender as? UIButton else { return }
        bttn.isEnabled = false
        
        let phone = (User.me.phone).replacingOccurrences(of: "+1", with: "")
        PhoneAuthProvider.provider().verifyPhoneNumber("+1 \(phone)", uiDelegate: nil) { (verificationID, error) in
            bttn.isEnabled = true
            if let error = error {
                self.alert(message: error.localizedDescription)
                return
            }
            if let id = verificationID{
                self.verificationId = id
                self.alert(message: "New Verification Code Sent!", title: "Success")
            }
        }
    }
    @IBAction func backBttnPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func codeBttnPressed(_ sender: Any) {
        codeTextField.becomeFirstResponder()
    }
    
}
