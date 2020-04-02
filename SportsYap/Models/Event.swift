//
//  Event.swift
//  SportsYap
//
//  Created by Master on 2020/3/21.
//  Copyright © 2020 Alex Pelletier. All rights reserved.
//

import UIKit

class Event: DBObject {
    
    var thumbnail: URL?

    var name: String = ""

    var minCost: Double = 0
    var maxCost: Double = 0
    var currency: String = ""

    var date: Date?

    var location: String = ""
    
    var url: URL?
    
    override init(dict: [String: AnyObject]) {
        super.init(dict: dict)
        
        if let ts = dict["image"] as? String, let u = URL(string: ts) {
            thumbnail = u
        }

        name = dict["name"] as? String ?? ""
        
        minCost = dict["minPrice"] as? Double ?? 0
        maxCost = dict["maxPrice"] as? Double ?? 0
        currency = dict["currency"] as? String ?? ""

        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let from = dict["date"] as? String {
            if let date = formatter.date(from: from) {
                self.date = date
            }
        }
        
        location = dict["venues"] as? String ?? ""
        
        if let ts = dict["url"] as? String, let u = URL(string: ts){
            url = u
        }
    }
}
