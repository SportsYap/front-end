//
//  AutoresizeView.swift
//  SportsYap
//
//  Created by Master on 2020/4/2.
//  Copyright © 2020 Alex Pelletier. All rights reserved.
//

import UIKit

class AutoresizeView: UIView {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        for sublayer in layer.sublayers ?? [] {
            sublayer.frame = bounds
        }
    }
}
