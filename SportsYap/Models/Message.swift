//
//  Message.swift
//  SportsYap
//
//  Created by Master on 2020/6/13.
//  Copyright © 2020 Alex Pelletier. All rights reserved.
//

import Foundation
import FirebaseFirestore
import MessageKit
import AVFoundation

struct Message {
    var id: String
    var created: Timestamp
    var senderID: String
    var senderName: String
    var avatar: String
    
    var dictionary: [String: Any] {
        switch kind {
        case .text(let content):
            return ["id": id,
                    "content": content,
                    "created": created,
                    "senderID": senderID,
                    "senderName": senderName,
                    "avatar": avatar]
        default:
            break
        }
        
        return [:]
    }

    var sentDate: Date {
        return created.dateValue()
    }
    
    var kind: MessageKind
    
    var localImage: UIImage?
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
        
        self.init(id: id, created: created, senderID: senderID, senderName: senderName, avatar: avatar, kind: .text(content))
    }

    
    private init(kind: MessageKind, user: ChatUser, messageId: String, date: Date) {
        self.kind = kind
        self.senderID = user.senderId
        self.senderName = user.displayName
        self.avatar = user.avatar
        self.id = messageId
        self.created = Timestamp(date: date)
    }
    
    init(custom: Any?, user: ChatUser, messageId: String, date: Date) {
        self.init(kind: .custom(custom), user: user, messageId: messageId, date: date)
    }

    init(text: String, user: ChatUser, messageId: String, date: Date) {
        self.init(kind: .text(text), user: user, messageId: messageId, date: date)
    }

    init(attributedText: NSAttributedString, user: ChatUser, messageId: String, date: Date) {
        self.init(kind: .attributedText(attributedText), user: user, messageId: messageId, date: date)
    }

    init(image: UIImage, user: ChatUser, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(image: image)
        self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date)
    }

    init(thumbnail: UIImage, user: ChatUser, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(image: thumbnail)
        self.init(kind: .video(mediaItem), user: user, messageId: messageId, date: date)
    }

    init(emoji: String, user: ChatUser, messageId: String, date: Date) {
        self.init(kind: .emoji(emoji), user: user, messageId: messageId, date: date)
    }
}

extension Message: MessageType {
    var sender: SenderType {
        return Sender(id: senderID, displayName: senderName)
    }
    
    var messageId: String {
        return id
    }
}


private struct ImageMediaItem: MediaItem {

    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize

    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
}
