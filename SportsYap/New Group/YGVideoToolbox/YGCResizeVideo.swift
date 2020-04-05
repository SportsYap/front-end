//
//  YGCResizeVideo.swift
//  ZQLVideoCompressor
//
//  Created by zang qilong on 2018/1/20.
//  Copyright © 2018年 Qilong Zang. All rights reserved.
//

import UIKit
import AVFoundation

public func resizeVideo(videoAsset:AVURLAsset,
                        targetSize:CGSize,
                        isKeepAspectRatio:Bool,
                        isCutBlackEdge:Bool) throws -> (AVMutableComposition, AVMutableVideoComposition)
{
    guard let videoTrack = videoAsset.tracks(withMediaType: AVMediaType.video).first else{
        throw YGCVideoError.videoTrackNotFind
    }
    
    var audioTrack: AVAssetTrack?
    var compostiionAudioTrack: AVMutableCompositionTrack?
    
    if let audioTrackFile = videoAsset.tracks(withMediaType: AVMediaType.audio).first {
        audioTrack = audioTrackFile
    }
    
    let resizeComposition = AVMutableComposition(urlAssetInitializationOptions: nil)
    
    guard let compositionVideoTrack = resizeComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
        throw YGCVideoError.compositionTrackInitFailed
    }
    
    if audioTrack != nil {
        if let audioComposition = resizeComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid) {
            compostiionAudioTrack = audioComposition
        }
    }
    
    try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration), of: videoTrack, at: CMTime.zero)
    
    if let audioTrack = audioTrack {
        try compostiionAudioTrack!.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration), of: audioTrack , at: CMTime.zero)
    }
    
    let originTransform = videoTrack.preferredTransform
    let info = orientationFromTransform(transform: originTransform)
    let videoNaturaSize:CGSize
    if (info.isPortrait && info.orientation != .up) {
        videoNaturaSize = CGSize(width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.width)
    }else {
        videoNaturaSize = videoTrack.naturalSize
    }
    
    if videoNaturaSize.width < targetSize.width && videoNaturaSize.height < targetSize.height {
        //throw YGCVideoError.targetSizeNotCorrect
    }
    
    let fitRect:CGRect
    if isKeepAspectRatio {
        fitRect = AVMakeRect(aspectRatio: videoNaturaSize, insideRect: CGRect(origin: CGPoint.zero, size: targetSize))
    }else {
        fitRect = CGRect(origin: CGPoint.zero, size: targetSize)
    }
    
    let mainInstruction = AVMutableVideoCompositionInstruction()
    mainInstruction.timeRange = CMTimeRange(start: CMTime.zero, end: videoAsset.duration)
    

    //let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
    let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
    
    let finalTransform:CGAffineTransform
    if info.isPortrait {
        if isCutBlackEdge {
            finalTransform = originTransform.concatenating(CGAffineTransform(scaleX: fitRect.width/videoNaturaSize.width, y: fitRect.height/videoNaturaSize.height))
        }else {
            finalTransform = originTransform.concatenating(CGAffineTransform(scaleX: fitRect.width/videoNaturaSize.width, y: fitRect.height/videoNaturaSize.height)).concatenating(CGAffineTransform(translationX: fitRect.minX, y: fitRect.minY))
        }
        
    }else {
        if isCutBlackEdge {
            finalTransform = originTransform.concatenating(CGAffineTransform(scaleX: fitRect.width/videoNaturaSize.width, y: fitRect.height/videoNaturaSize.height))
        }else {
            finalTransform = originTransform.concatenating(CGAffineTransform(scaleX: fitRect.width/videoNaturaSize.width, y: fitRect.height/videoNaturaSize.height)).concatenating(CGAffineTransform(translationX: fitRect.minX, y: fitRect.minY))
        }
        
    }
    layerInstruction.setTransform(finalTransform, at: CMTime.zero)
    mainInstruction.layerInstructions = [layerInstruction]
    
    let videoComposition = AVMutableVideoComposition()
    videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
    
    if isCutBlackEdge && isKeepAspectRatio {
        videoComposition.renderSize = fitRect.size
    }else {
        videoComposition.renderSize = targetSize
    }
    
    videoComposition.instructions = [mainInstruction]
    
    return (resizeComposition, videoComposition)
}
