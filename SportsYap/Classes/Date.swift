//
//  Date.swift
//  SportsYap
//
//  Created by Alex Pelletier on 5/25/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

extension Date {
    func timeAgoSince() -> String {
        let dif = Int(abs(self.timeIntervalSinceNow))
        let timescale: [[Any]] = [
            [1, "second"],
            [60, "minute"],
            [3600, "hour"],
            [86400, "day"],
            [2592000, "month"],
            [31536000, "year"],
            [Int.max, "year"],
        ]
        
        var lastKey = 1
        var lastVal = "second"
        for step in timescale{
            if let key = step[0] as? Int, let value = step[1] as? String{
                if dif < key{
                    let amount = Int(Double(dif)/Double(lastKey))
                    return "\(amount) \(lastVal)" + ((amount > 1) ? "s" : "") + " ago"
                }
                lastKey = key
                lastVal = value
            }
        }
        
        return "now"
    }
}
