//
//  Double.swift
//  SportsYap
//
//  Created by Master on 2020/3/21.
//  Copyright © 2020 Alex Pelletier. All rights reserved.
//

import Foundation

extension Double {
    public func formattedString() -> String {
        var string = String(format: "%.2f", self)
        string = string.trimmingCharacters(in: CharacterSet(charactersIn: "0"))
        if string.prefix(1) == "." {
            string = "0" + string
        }
        return string.trimmingCharacters(in: CharacterSet(charactersIn: "."))
    }
}
