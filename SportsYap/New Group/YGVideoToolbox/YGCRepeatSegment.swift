//
//  YGCRepeatSegment.swift
//  ZQLVideoCompressor
//
//  Created by Qilong Zang on 23/01/2018.
//  Copyright © 2018 Qilong Zang. All rights reserved.
//

import UIKit
import AVFoundation

public func repeatVideo(videoAsset:AVURLAsset, insertAtSeconds:Double, repeatTimeRange:YGCTimeRange, repeatCount:Int) throws -> AVMutableComposition {
  
  assert(insertAtSeconds >= 0, "insert seconds can't less than 0")
  
  guard let videoTrack = videoAsset.tracks(withMediaType: AVMediaType.video).first else{
    throw YGCVideoError.videoTrackNotFind
  }
  
  guard let audioTrack = videoAsset.tracks(withMediaType: AVMediaType.audio).first else {
    throw YGCVideoError.audioTrackNotFind
  }
  
  guard repeatTimeRange.validateTime(videoTime: videoAsset.duration) else {
    throw YGCVideoError.timeSetNotCorrect
  }
  
  let mixCompositin = AVMutableComposition(urlAssetInitializationOptions: nil)
  guard let compositionVideoTrack = mixCompositin.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
    throw YGCVideoError.compositionTrackInitFailed
  }
  guard let compostiionAudioTrack = mixCompositin.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
    throw YGCVideoError.compositionTrackInitFailed
  }
  
  let videoTimeScale = videoAsset.duration.timescale
    var insert:CMTime = CMTimeMakeWithSeconds(insertAtSeconds, preferredTimescale: videoTimeScale);
  let repeatRange:CMTimeRange
  let repeatDuration:CMTime
  switch repeatTimeRange {
  case .naturalRange:
    repeatRange = CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration)
  //  beginTime = kCMTimeZero
  case .secondsRange(let begin, let end):
    // beginTime = CMTimeMake(Int64(Double(videoTimeScale) * begin), videoTimeScale)
    repeatRange = CMTimeRangeMake(start: CMTimeMakeWithSeconds(begin, preferredTimescale: videoTimeScale), duration: CMTimeMakeWithSeconds(end, preferredTimescale: videoTimeScale))
  case .cmtimeRange(let begin, let end):
    // beginTime = begin
    repeatRange = CMTimeRangeMake(start: begin, duration: end)
  }
  
  repeatDuration = CMTimeSubtract(repeatRange.duration, repeatRange.start)
  
  // insertAt bigger than kcmtimezero,we should add left side time range first
    if CMTimeCompare(insert, CMTime.zero) == 1 {
    // add repeatRange Left side
        try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: insert), of: videoTrack, at: CMTime.zero)
        try compostiionAudioTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: insert), of: audioTrack, at: CMTime.zero)
    
    // add repeat range
    for _ in 0..<repeatCount {
      try compositionVideoTrack.insertTimeRange(repeatRange, of: videoTrack, at: insert)
      try compostiionAudioTrack.insertTimeRange(repeatRange, of: audioTrack, at: insert)
      insert = CMTimeAdd(insert, repeatDuration)
    }
    
    // add repeatRange right side
    if CMTimeCompare(repeatRange.end, videoAsset.duration) == -1 {
        try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(start: repeatRange.end, duration: videoAsset.duration), of: videoTrack, at: insert)
        try compostiionAudioTrack.insertTimeRange(CMTimeRangeMake(start: repeatRange.end, duration: videoAsset.duration), of: audioTrack, at: insert)
    }
  }else {
    // insertAt equal kcmtimezero,we should add repeat range directly
    for _ in 0..<repeatCount {
      try compositionVideoTrack.insertTimeRange(repeatRange, of: videoTrack, at: insert)
      insert = CMTimeAdd(insert, repeatDuration)
    }
    
    if CMTimeCompare(repeatRange.end, videoAsset.duration) == -1 {
        try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(start: repeatRange.end, duration: videoAsset.duration), of: videoTrack, at: insert)
        try compostiionAudioTrack.insertTimeRange(CMTimeRangeMake(start: repeatRange.end, duration: videoAsset.duration), of: audioTrack, at: insert)
    }
    
  }
  
  compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
  return mixCompositin
}

