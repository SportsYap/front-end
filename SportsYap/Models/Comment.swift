//
//  Comment.swift
//  SportsYap
//
//  Created by Alex Pelletier on 5/25/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

class Comment: DBObject {
    
    var user: User!
    var text = ""
    
    override init(dict: [String: AnyObject]){
        super.init(dict: dict)
        
        if let t = dict["text"] as? String{
            text = t
        }
        
        if let userDict = dict["user"] as? [String: AnyObject]{
            self.user = User(dict: userDict)
        }
    }
}
