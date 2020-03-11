//
//  AuthViewController.swift
//  SportsYap
//
//  Created by Alex Pelletier on 2/6/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import SVWebViewController
import FirebaseAuth

class AuthViewController: UIViewController {

    @IBOutlet weak var checkboxImageView: UIImageView!
    
    var termsAccepted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    //MARK: IBActions
    @IBAction func signupBttnPressed(_ sender: Any) {
        guard termsAccepted else{
            alert(message: "Please accept the Terms of Service")
            return
        }
        performSegue(withIdentifier: "signup", sender: nil)
    }
    @IBAction func fbLoginBttnPressed(_ sender: Any) {
        guard termsAccepted else{
            alert(message: "Please accept the Terms of Service")
            return
        }
        
        let fbManager = FBSDKLoginManager()
        fbManager.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: self) { (result, err) in
            if err == nil && result?.token != nil{
                let token = result?.token.tokenString ?? "<err>"
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, email"]).start(completionHandler: { (connection, result, error) -> Void in
                    if (error == nil){
                        if let userDict = result as? [String: AnyObject], let email = userDict["email"] as? String,
                            let name = userDict["name"] as? String{
                            
                            print("\(token)")
                            
                            ApiManager.shared.fbLogin(email: email, name: name, token: token, { (created) in
                                if created{
                                    ApiManager.shared.me(onSuccess: { (user) in
                                        self.performSegue(withIdentifier: "selectTeams", sender: nil)
                                    }, onError: { (err) in })
                                }else{
                                    ApiManager.shared.me(onSuccess: { (user) in
                                    }, onError: voidErr)
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }, onError: { (err) in
                                self.alert(message: "Internal Server Error")
                            })
                        }
                    }else{
                        self.alert(message: "Error Getting FB Permissions")
                    }
                })
                
            }else{
                self.alert(message: "Error Logging In With FB")
            }
        }
    }
    @IBAction func acceptTermsBttnPressed(_ sender: Any) {
        termsAccepted = !termsAccepted
        checkboxImageView.image = termsAccepted ? #imageLiteral(resourceName: "checked_box_checked") : #imageLiteral(resourceName: "checked_box")
    }
    @IBAction func termsOfServiceBttnPressed(_ sender: Any) {
        if let vc = SVModalWebViewController(address: "https://sportsyap.com/privacy.html"){
            self.present(vc, animated: true, completion: nil)
        }
    }
    @IBAction func phoneSignupBttnPressed(_ sender: Any) {
        guard termsAccepted else{
            alert(message: "Please accept the Terms of Service")
            return
        }
        performSegue(withIdentifier: "showPhoneAuth", sender: nil)
    }
    
}
