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
import AuthenticationServices

class AuthViewController: UIViewController {

    @IBOutlet weak var checkboxImageView: UIImageView!
    @IBOutlet weak var appleButton: UIButton!
    
    var termsAccepted = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if #available(iOS 13.0, *) {
            appleButton.isHidden = false
        } else {
            // Fallback on earlier versions
        }
    }

    @IBAction func handleLogInWithAppleID() {
        if #available(iOS 13.0, *) {
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            
            controller.delegate = self
            controller.presentationContextProvider = self
            
            controller.performRequests()
        }
    }

    //MARK: IBActions
    @IBAction func onLogin(_ sender: Any) {
        guard termsAccepted else{
            alert(message: "Please accept the Terms of Service")
            return
        }
        performSegue(withIdentifier: "login", sender: nil)
    }
    @IBAction func fbLoginBttnPressed(_ sender: Any) {
        guard termsAccepted else{
            alert(message: "Please accept the Terms of Service")
            return
        }
        
        let fbManager = LoginManager()
        fbManager.logOut()
        fbManager.logIn(permissions: ["email"], from: self) { (result, err) in
            if err == nil && result?.token != nil{
                let token = result?.token?.tokenString ?? "<err>"
                GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, email"]).start(completionHandler: { (connection, result, error) -> Void in
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
                                    self.navigationController?.dismiss(animated: true, completion: nil)
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

extension AuthViewController: ASAuthorizationControllerDelegate {
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            if let token = appleIDCredential.identityToken {
                if let tokenString = String(data: token, encoding: .utf8) {

                    let firstName = appleIDCredential.fullName?.givenName ?? ""
                    let lastName = appleIDCredential.fullName?.familyName ?? ""
                    ApiManager.shared.appleSignin(email: appleIDCredential.email ?? "-", name: firstName + " " + lastName, token: tokenString, { (created) in
                        if created{
                            ApiManager.shared.me(onSuccess: { (user) in
                                self.performSegue(withIdentifier: "selectTeams", sender: nil)
                            }, onError: { (err) in })
                        }else{
                            ApiManager.shared.me(onSuccess: { (user) in
                            }, onError: voidErr)
                            self.navigationController?.dismiss(animated: true, completion: nil)
                        }
                    }, onError: { (err) in
                        self.alert(message: "Internal Server Error")
                    })
                }
            }
            break
        default:
            break
        }
    }
}

extension AuthViewController: ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
           return self.view.window!
    }
}
