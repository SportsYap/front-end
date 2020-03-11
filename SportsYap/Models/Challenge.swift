//
//  Challenge.swift
//  SportsYap
//
//  Created by Alex Pelletier on 5/27/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

class Challenge: DBObject {

    var text = ""
    
    override init(dict: [String : AnyObject]) {
        super.init(dict: dict)
        
        if let t = dict["text"] as? String{
            text = t
        }
    }
}
