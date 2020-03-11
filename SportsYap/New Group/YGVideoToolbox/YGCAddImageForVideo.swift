//
//  YGCAddImageForVideo.swift
//  YGCVideoToolboxDemo
//
//  Created by Qilong Zang on 24/02/2018.
//  Copyright © 2018 Qilong Zang. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

/*
 Notice:
 Add Image use the AVVideoCompositionCoreAnimationTool, so you can't use AVPlayer play the composition with a videoCompositon, you have to export then play it.
 */

public func addImageForVideo(videoAsset:AVURLAsset,
                             image:UIImage,
                             bounds: CGRect,
                             imageRect:CGRect) throws -> (AVMutableComposition, AVMutableVideoComposition) {
    guard let videoTrack = videoAsset.tracks(withMediaType: AVMediaType.video).first else{
        throw YGCVideoError.videoTrackNotFind
    }
    
    guard let audioTrack = videoAsset.tracks(withMediaType: AVMediaType.audio).first else {
        throw YGCVideoError.audioTrackNotFind
    }
    
    let imageCompositin = AVMutableComposition(urlAssetInitializationOptions: nil)
    guard let compositionVideoTrack = imageCompositin.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
        throw YGCVideoError.compositionTrackInitFailed
    }
    guard let compostiionAudioTrack = imageCompositin.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
        throw YGCVideoError.compositionTrackInitFailed
    }
    
    try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration), of: videoTrack, at: CMTime.zero)
    try compostiionAudioTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration), of: audioTrack , at: CMTime.zero)
    
    let videoComposition = AVMutableVideoComposition()
    //let mainInstruction = AVMutableVideoCompositionInstruction()
    //mainInstruction.timeRange = CMTimeRange(start: CMTime.zero, end: videoAsset.duration)
    //let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
    //layerInstruction.setTransform(videoTrack.preferredTransform, at: CMTime.zero)
    //mainInstruction.layerInstructions = [layerInstruction]
    
    
    
    let originTransform = videoTrack.preferredTransform
    let info = orientationFromTransform(transform: originTransform)
    let videoNaturaSize:CGSize
    if (info.isPortrait && info.orientation != .up) {
        videoNaturaSize = CGSize(width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.width)
    }else {
        videoNaturaSize = videoTrack.naturalSize
    }
    
    if videoNaturaSize.width < bounds.width && videoNaturaSize.height < bounds.height {
        throw YGCVideoError.targetSizeNotCorrect
    }
    
    let fitRect = AVMakeRect(aspectRatio: videoNaturaSize, insideRect: CGRect(origin: CGPoint.zero, size: bounds.size))
    //let fitRect = bounds
    let mainInstruction = AVMutableVideoCompositionInstruction()
    mainInstruction.timeRange = CMTimeRange(start: CMTime.zero, end: videoAsset.duration)
    
    //let layerInstruction = videoCompositionInstructionForTrack(track: compositionVideoTrack, videoTrack: videoTrack, targetSize: bounds.size)
    
    let asset = AVAsset(url: videoAsset.url)
    let layerInstruction = videoCompositionInstructionForTrack2(track: compositionVideoTrack, asset: asset)

    mainInstruction.layerInstructions = [layerInstruction]
    
    let imageLayer = CALayer()
    imageLayer.contents = image.cgImage!
    imageLayer.frame = CGRect(x: imageRect.origin.x, y: bounds.size.height - imageRect.maxY, width: imageRect.width, height: imageRect.height)
    
    let overlayLayer = CALayer()
    overlayLayer.frame = CGRect(origin: CGPoint.zero, size: bounds.size)
    overlayLayer.addSublayer(imageLayer)
    
    let parentLayer = CALayer()
    let videoLayer = CALayer()
    parentLayer.frame = CGRect(origin: CGPoint.zero, size: bounds.size)
    videoLayer.frame = CGRect(origin: CGPoint.zero, size: bounds.size)
    parentLayer.addSublayer(videoLayer)
    parentLayer.addSublayer(overlayLayer)
    
    print("////////////////")
    print(videoNaturaSize)
    print(imageLayer.frame)
    print(overlayLayer.frame)
    print(videoLayer.frame)
    print(parentLayer.frame)
    print(fitRect)
    print("///////////////")
    
    let newSize = CGSize(width: floor(fitRect.size.width / 16) * 16, height: fitRect.size.height)
    print(newSize)
    print("////")
    
    videoComposition.renderSize = videoTrack.naturalSize //newSize//fitRect.size //videoTrack.naturalSize
    videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
    videoComposition.instructions = [mainInstruction]
    videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
    
    return (imageCompositin, videoComposition)
}
