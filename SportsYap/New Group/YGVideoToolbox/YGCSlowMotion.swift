//
//  YGCSlowMotion.swift
//  ZQLVideoCompressor
//
//  Created by zang qilong on 2018/1/20.
//  Copyright © 2018年 Qilong Zang. All rights reserved.
//

import UIKit
import AVFoundation

public func slowMotion(videoAsset:AVURLAsset,
                       slowTimeRange:YGCTimeRange,
                       slowMotionRate:Int) throws -> AVMutableComposition
{
  guard let videoTrack = videoAsset.tracks(withMediaType: AVMediaType.video).first else{
    throw YGCVideoError.videoTrackNotFind
  }
  
  guard let audioTrack = videoAsset.tracks(withMediaType: AVMediaType.audio).first else {
    throw YGCVideoError.audioTrackNotFind
  }
  
  guard slowTimeRange.validateTime(videoTime: videoAsset.duration) else {
    throw YGCVideoError.timeSetNotCorrect
  }
  
  let slowMotionCompositin = AVMutableComposition(urlAssetInitializationOptions: nil)
  guard let compositionVideoTrack = slowMotionCompositin.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
    throw YGCVideoError.compositionTrackInitFailed
  }
  guard let compostiionAudioTrack = slowMotionCompositin.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
    throw YGCVideoError.compositionTrackInitFailed
  }
  
    try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration), of: videoTrack, at: CMTime.zero)
    try compostiionAudioTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration), of: audioTrack , at: CMTime.zero)
  
  let videoTimeScale = videoAsset.duration.timescale
  let beginTime:CMTime
  let slowMotionRange:CMTimeRange
  switch slowTimeRange {
  case .naturalRange:
    slowMotionRange = CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration)
    beginTime = CMTime.zero
  case .secondsRange(let begin, let end):
    beginTime = CMTimeMakeWithSeconds(begin, preferredTimescale: videoTimeScale)
    slowMotionRange = CMTimeRangeMake(start: beginTime, duration: CMTimeMakeWithSeconds(end, preferredTimescale: videoTimeScale))
  case .cmtimeRange(let begin, let end):
    beginTime = begin
    slowMotionRange = CMTimeRangeMake(start: begin, duration: end)
  }
  
  let subTractRange = CMTimeSubtract(slowMotionRange.duration, slowMotionRange.start)
  let seconds = CMTimeGetSeconds(subTractRange)
    compositionVideoTrack.scaleTimeRange(slowMotionRange, toDuration: CMTimeMake(value: CMTimeValue(seconds) * CMTimeValue(slowMotionRate) * CMTimeValue(subTractRange.timescale), timescale: subTractRange.timescale))
    compostiionAudioTrack.scaleTimeRange(slowMotionRange, toDuration: CMTimeMake(value: CMTimeValue(seconds) * CMTimeValue(slowMotionRate) * CMTimeValue(subTractRange.timescale), timescale: subTractRange.timescale))
  compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
  
  return slowMotionCompositin
}
