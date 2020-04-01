//
//  SettingsHeaderTableViewCell.swift
//  SportsYap
//
//  Created by Alex Pelletier on 5/8/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

protocol SettingsHeaderTableViewCellDelegate {
    func didTapEditPhoto()
    func didUpdateUserData(value: String, key: String)
}

class SettingsHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    
    var delegate: SettingsHeaderTableViewCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        usernameTextField.delegate = self
        locationTextField.delegate = self
    }
    
    @IBAction func onEditPhoto(_ sender: Any) {
        delegate.didTapEditPhoto()
    }
}

extension SettingsHeaderTableViewCell: UITextFieldDelegate {
    //MARK: UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = textField.text!
        let key = textField.restorationIdentifier ?? ""
        
        delegate.didUpdateUserData(value: text, key: key)
    }
}
