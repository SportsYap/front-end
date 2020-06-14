//
//  Message.swift
//  SportsYap
//
//  Created by Master on 2020/6/13.
//  Copyright © 2020 Alex Pelletier. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Message {
    var id: String
    var content: String
    var created: Timestamp
    var senderID: String
    var senderName: String
    var avatar: String
    
    var dictionary: [String: Any] {
        return ["id": id,
                "content": content,
                "created": created,
                "senderID": senderID,
                "senderName": senderName,
                "avatar": avatar]
    }

    var sentDate: Date {
        return created.dateValue()
    }
}

extension Message {
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
        let content = dictionary["content"] as? String,
        let created = dictionary["created"] as? Timestamp,
        let senderID = dictionary["senderID"] as? String,
        let senderName = dictionary["senderName"] as? String,
        let avatar = dictionary["avatar"] as? String
            else { return nil }
        
        self.init(id: id, content: content, created: created, senderID: senderID, senderName: senderName, avatar: avatar)
    }
}
