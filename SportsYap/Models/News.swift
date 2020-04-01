//
//  News.swift
//  SportsYap
//
//  Created by Alex Pelletier on 5/22/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

class News: DBObject {
    var title = ""
    var url: URL!
    var author = ""
    var thumbnail: URL?
    
    override init(dict: [String : AnyObject]) {
        super.init()
        
        if let t = dict["title"] as? String{
            title = t
        }
        
        if let us = dict["url"] as? String, let u = URL(string: us){
            url = u
        }
        
        if let a = dict["author"] as? String {
            author = a.components(separatedBy: ",").first ?? ""
        }
        
        if let ts = dict["thumbail_url"] as? String, let u = URL(string: ts){
            thumbnail = u
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss'.000'XXXXX"
        
        if let c = dict["published"] as? String{
            if let cAt = formatter.date(from: c){
                createdAt = cAt
            }
        }
    }
}
