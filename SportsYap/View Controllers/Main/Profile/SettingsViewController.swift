//
//  SettingsViewController.swift
//  SportsYap
//
//  Created by Alex Pelletier on 5/8/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var successView: UIView!

    private var profileImage: UIImage?
    private var username: String?
    private var firstname: String?
    private var lastname: String?
    private var email: String?
    private var location: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

extension SettingsViewController {
    //MARK: IBAction
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSave(_ sender: Any) {
        User.me.name = username ?? User.me.name
        User.me.firstName = firstname ?? User.me.firstName
        User.me.lastName = lastname ?? User.me.lastName
        User.me.email = email ?? User.me.email
        User.me.location = location ?? User.me.location

        ApiManager.shared.updateSelf(onSuccess: {
            if let image = self.profileImage {
                ApiManager.shared.uploadProfilePhoto(photo: image, onSuccess: {
                    self.profileImage = nil
                    
                    URLCache.shared.removeAllCachedResponses()
                    ImageFileManager.shared.clearAll()
                    
                    ApiManager.shared.me(onSuccess: { (user) in
                        self.username = nil
                        self.firstname = nil
                        self.lastname = nil
                        self.email = nil
                        self.location = nil

                        self.tableView.reloadData()
                    }, onError: voidErr)
                }, onError: voidErr)
            } else {
                self.showSuccessView()
            }
        }, onError: voidErr)
    }
    
    @IBAction func onFollowNewTeams(_ sender: Any) {
        performSegue(withIdentifier: "followNewTeams", sender: nil)
    }
}

extension SettingsViewController: SettingsGameTableViewCellDelegate {
    //MARK: SettingsGameTableViewCellDelegate
    func didUnfollowTeam(for team: Team) {
        ApiManager.shared.unfollow(team: team.id, onSuccess: {
            team.followed = false
            if let index = User.me.teams.index(of: team) {
                User.me.teams.remove(at: index)
            }
        }) { (err) in }
    }
    
    func didFollowTeam(for team: Team) {
        ApiManager.shared.follow(team: team.id, onSuccess: {
            team.followed = true
            if !User.me.teams.contains(team) {
                User.me.teams.append(team)
            }
        }) { (err) in }
    }
}

extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let width = Double(self.view.frame.width)
        let coppedImage = cropToBounds(image: image.fixOrientation(), width: width, height: width)
        
        profileImage = coppedImage

        dismiss(animated:true, completion: nil)
    }
}

extension SettingsViewController {
    private func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
    
    private func showSuccessView() {
        successView.isHidden = false
        UIView.animate(withDuration: 0.2, animations: {
            self.successView.alpha = 1
        }) { (_) in
            UIView.animate(withDuration: 0.2, delay: 3, options: [], animations: {
                self.successView.alpha = 0
            }) { (_) in
                self.successView.isHidden = true
            }
        }
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? User.me.teams.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as? SettingsHeaderTableViewCell{
                cell.nameTextField.text = "\(User.me.firstName) \(User.me.lastName)"
                cell.usernameTextField.text = User.me.name
                cell.emailTextField.text = User.me.email
                cell.locationTextField.text = User.me.location
                cell.delegate = self
                cell.profileImageView.sd_setImage(with: User.me.profileImage, placeholderImage: #imageLiteral(resourceName: "default-profile"))
                return cell
            }
        } else if indexPath.section == 1 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "teamCell") as? SettingsGameTableViewCell{
                let team = User.me.teams[indexPath.row]
                cell.teamNameLabel.text = team.name
                cell.hometownLabel.text = "\(team.homeTown) | \(team.sport.abv)"
                cell.primaryColorView.backgroundColor = team.primaryColor
                cell.secondaryColorView.backgroundColor = team.secondaryColor
                cell.delegate = self
                cell.team = team
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 432 : 66
    }
}

extension SettingsViewController: SettingsHeaderTableViewCellDelegate {
    //MARK: SettingsHeaderTableViewCellDelegate
    func didTapEditPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func didUpdateUserData(value: String, key: String) {
        if key == "username" {
            username = value
        } else if key == "name" {
            let parts = value.split(maxSplits: 2, omittingEmptySubsequences: true) { (char) -> Bool in
                return char == " "
            }
            if parts.count == 1 {
                firstname = String(parts[0])
                lastname = ""
            } else if parts.count == 2 {
                firstname = String(parts[0])
                lastname = String(parts[1])
            }
        } else if key == "email" {
            email = value
        } else if key == "hometown" {
            location = value
        }
    }
}
