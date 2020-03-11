//
//  MediaMerger.swift
//  SportsYap
//
//  Created by Alex Pelletier on 4/23/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class MediaMerger: NSObject {

    static func merge(photo media: UserMedia, imageHeight: CGFloat? = nil, font: UIFont? = nil) -> UIImage?{
        guard let image = media.photo else { return nil }
        let textColor = media.commentColor ?? UIColor.white
        
        var textFont: UIFont
        
        if let font = font {
            textFont = font
        } else {
            textFont = UIFont.systemFont(ofSize: media.commentMode.fontSize())
        }
        
        //let textFont = UIFont.systemFont(ofSize: media.commentMode.fontSize())
        
        let scale: CGFloat = UIScreen.main.scale
        let screenSize = UIScreen.main.bounds.size
        UIGraphicsBeginImageContextWithOptions(screenSize, false, scale)
        
        image.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: screenSize))
        
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center

        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            NSAttributedString.Key.paragraphStyle: paragraphStyle] as [NSAttributedString.Key : Any]
        
        var frameHeight: CGFloat
        
        if let imageHeight = imageHeight {
            frameHeight = imageHeight
        } else {
            frameHeight = media.commentMode.fontSize() * 2
        }
        
        let rect = CGRect(origin: CGPoint(x: media.commentPos.x + 16, y: media.commentPos.y), size: CGSize(width: image.size.width - 48, height:  frameHeight))
        
        
        media.comment.draw(in: rect, withAttributes: textFontAttributes)
        
//        let context = UIGraphicsGetCurrentContext()
//        context?.setFillColor(UIColor.black.cgColor)
//        context!.addRect(rect)
//        context?.drawPath(using: .fill)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    static func merge(video media: UserMedia) -> URL?{
        return media.videoUrl
    }
    
    static func thumbnail(for media: UserMedia) -> UIImage{
        if let url = media.videoUrl{
            let asset = AVAsset(url: url)
            let seconds = CMTimeGetSeconds(asset.duration)
            let progress = seconds > 5 ? 0.2 : 0.5
            if let image = previewImageForLocalVideo(asset: asset, at: progress){
                return image
            }
        }
        
        return UIImage()
    }
    
    private class func previewImageForLocalVideo(asset: AVAsset, at progress: Double = 0.5) -> UIImage?{
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        var time = asset.duration
        //If possible - take not the first frame (it could be completely black or white on camara's videos)
        time.value = Int64(Double(Int64(time.value)) * progress)
        
        if time.value == 0{
            time.value = min(asset.duration.value, Int64(Int32(time.timescale)))
        }
        
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        }catch let error as NSError{
            print("Image generation failed with error \(error)")
            return nil
        }
    }
    
}
