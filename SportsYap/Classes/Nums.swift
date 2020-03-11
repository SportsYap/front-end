
//
//  Int.swift
//  GoFire
//
//  Created by Alex Pelletier on 8/6/16.
//  Copyright © 2016 Alex Pelletier. All rights reserved.
//

import UIKit

extension Int {
    var degreesToRadians: Double { return Double(self) * Double.pi / 180 }
    var radiansToDegrees: Double { return Double(self) * 180 / Double.pi }
}

protocol DoubleConvertible {
    init(_ double: Double)
    var double: Double { get }
}
extension Double : DoubleConvertible { var double: Double { return self         } }
extension Float  : DoubleConvertible { var double: Double { return Double(self) } }
extension CGFloat: DoubleConvertible { var double: Double { return Double(self) } }

extension DoubleConvertible {
    var degreesToRadians: DoubleConvertible {
        return Self(double * Double.pi / 180)
    }
    var radiansToDegrees: DoubleConvertible {
        return Self(double * 180 / Double.pi)
    }
}

//Times
extension Double{
    
    func toStringTime() -> String{
        let sec = Int(self) % 60
        return "\(Int(self/60)):" + (sec < 10 ? "0" : "") + "\(sec)"
    }
}

