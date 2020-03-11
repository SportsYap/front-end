//
//  StringExtension.swift
//  SlideMenuControllerSwift
//
//  Copyright (c) 2015 Yuji Hato. All rights reserved.
//

import Foundation

extension String {
    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
    
    //MARK: Capitalization
    func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    //MARK: Sub Strings
    func substring(_ from: Int) -> String {
        return self.substring(from: self.characters.index(self.startIndex, offsetBy: from))
    }
    
    var length: Int {
        return self.characters.count
    }
    
    func substr(_ start:Int, length:Int=0) -> String? {
        guard start > -1 else {
            return nil
        }
        
        let count = self.characters.count - 1
        
        guard start <= count else {
            return nil
        }
        
        let startOffset = max(0, start)
        let endOffset = length > 0 ? min(count, startOffset + length - 1) : count
        
        return String(self[self.index(self.startIndex, offsetBy: startOffset)...self.index(self.startIndex, offsetBy: endOffset)])
    }


}
