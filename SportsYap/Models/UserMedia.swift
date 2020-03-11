//
//  UserMedia.swift
//  SportsYap
//
//  Created by Alex Pelletier on 4/23/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit

enum MediaCommentMode: Int{
    case small = 0
    case medium
    case large
    
    func fontSize() -> CGFloat{
        switch self {
        case .small: return 20
        case .medium: return 33
        case .large: return 50
        }
    }
    
    func next() -> MediaCommentMode{
        let v = self.rawValue == 2 ? 0 : self.rawValue + 1
        return MediaCommentMode(rawValue: v)!
    }
}

class UserMedia: NSObject {
    
    var videoUrl: URL?
    var thumbnailUrl: URL?
    
    var photoUrl: URL?
    var photo: UIImage?
    
    var comment = ""
    var commentPos = CGPoint()
    var commentMode = MediaCommentMode.medium
    var commentColor: UIColor?
    
    var recordedVideo = false
    var contentHeight: CGFloat = 0
    
    override init(){
        
    }
    
    init(video: URL?, image: UIImage?, recordedVideo: Bool = false){
        videoUrl = video
        photo = image
        self.recordedVideo = recordedVideo
    }
}
