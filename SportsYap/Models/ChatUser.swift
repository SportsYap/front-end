//
//  ChatUser.swift
//  Chedrr
//
//  Created by Master on 2020/6/6.
//  Copyright © 2020 Chedrr inc dev. All rights reserved.
//

import Foundation
import MessageKit

struct ChatUser: SenderType, Equatable {
    var senderId: String
    var displayName: String
    var avatar: String

    init(user: User) {
        senderId = "\(user.id)"
        displayName = user.name
        avatar = user.profileImage?.absoluteString ?? ""
    }
}
