//
//  Venue.swift
//  SportsYap
//
//  Created by Alex Pelletier on 6/9/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

class Venue: DBObject {
    
    var name = ""
    var city = ""
    var state = ""
    
    override init(){
        super.init()
    }
    
    override init(dict: [String: AnyObject]){
        super.init(dict: dict)
        
        if let n = dict["name"] as? String{
            name = n
        }
        
        if let c = dict["city"] as? String{
            city = c
        }
        
        if let s = dict["state"] as? String{
            state = s
        }
    }
}
