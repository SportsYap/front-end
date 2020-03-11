//
//  SettingsHeaderTableViewCell.swift
//  SportsYap
//
//  Created by Alex Pelletier on 5/8/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

protocol SettingsHeaderTableViewCellDelegate {
    func editProfilePhoto()
    func userDataUpdated(value: String, key: String)
}

class SettingsHeaderTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var locationTextField: UITextField!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    
    var delegate: SettingsHeaderTableViewCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        usernameTextField.delegate = self
        locationTextField.delegate = self
    }
    
    @IBAction func editPhotoBttnPressed(_ sender: Any) {
        delegate.editProfilePhoto()
    }
    
    //MARK: UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = textField.text!
        let key = textField.restorationIdentifier ?? ""
        delegate.userDataUpdated(value: text, key: key)
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
}
