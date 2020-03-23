//
//  SettingsViewController.swift
//  SportsYap
//
//  Created by Alex Pelletier on 5/8/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, SettingsGameTableViewCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    //MARK: IBAction
    @IBAction func backBttnPressed(_ sender: Any) {
        
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: SettingsGameTableViewCellDelegate
    func unfollowBttnPressed(for team: Team){
        ApiManager.shared.unfollow(team: team.id, onSuccess: {
        }) { (err) in }
    }
    func followBttnPressed(for team: Team){
        ApiManager.shared.follow(team: team.id, onSuccess: {
        }) { (err) in }
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let width = Double(self.view.frame.width)
        let coppedImage = cropToBounds(image: image.fixOrientation(), width: width, height: width)
        ApiManager.shared.uploadProfilePhoto(photo: coppedImage, onSuccess: {
            URLCache.shared.removeAllCachedResponses()
            ImageFileManager.shared.clearAll()
            ApiManager.shared.me(onSuccess: { (user) in
                self.tableView.reloadData()
            }, onError: voidErr)
        }, onError: voidErr)
        dismiss(animated:true, completion: nil)
    }

    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        
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
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate, SettingsHeaderTableViewCellDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? User.me.teams.count : 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as? SettingsHeaderTableViewCell{
                cell.nameTextField.text = "\(User.me.firstName) \(User.me.lastName)"
                cell.usernameTextField.text = User.me.name
                cell.emailTextField.text = User.me.email
                cell.locationTextField.text = User.me.location
                cell.delegate = self
                cell.profileImageView.sd_setImage(with: User.me.profileImage, placeholderImage: #imageLiteral(resourceName: "default-profile"))
                return cell
            }
        }else if indexPath.section == 1{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "teamCell") as? SettingsGameTableViewCell{
                let team = User.me.teams[indexPath.row]
                cell.teamNameLbl.text = team.name
                cell.hometownLbl.text = "\(team.homeTown) | \(team.sport.abv)"
                cell.primaryColorView.backgroundColor = team.primaryColor
                cell.secondaryColorView.backgroundColor = team.secondaryColor
                cell.delegate = self
                cell.team = team
                return cell
            }
        }else if indexPath.section == 2{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "logoutCell"){
                return cell
            }
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 411 : 50
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 2{
            ApiManager.shared.logout()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self.navigationController?.popViewController(animated: false)
            }
            TabBarViewController.sharedInstance.selectedIndex = 0
        }
    }
    
    //MARK: SettingsHeaderTableViewCellDelegate
    func editProfilePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    func userDataUpdated(value: String, key: String){
        if key == "username"{
            User.me.name = value
        }else if key == "name"{
            let parts = value.split(maxSplits: 2, omittingEmptySubsequences: true) { (char) -> Bool in
                return char == " "
            }
            if parts.count == 1{
                User.me.firstName = String(parts[0])
                User.me.lastName = ""
            }else if parts.count == 2{
                User.me.firstName = String(parts[0])
                User.me.lastName = String(parts[1])
            }
        }else if key == "email"{
            User.me.email = value
        }else if key == "hometown"{
            User.me.location = value
        }
        ApiManager.shared.updateSelf(onSuccess: { }, onError: voidErr)
    }
}
