//
//  Merge.swift
//
//
//  Created by John Connolly on 2016-03-20.
//
//
import Foundation
import AVKit
import AVFoundation

final class Merge {
    
    fileprivate let configuration: MergeConfiguration
    
    init(config: MergeConfiguration) {
        self.configuration = config
    }
    
    fileprivate var fileUrl: URL {
        let fullPath = configuration.directory + "/export\(NSUUID().uuidString).mp4"
        NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/export\(NSUUID().uuidString).mp4"
        return URL(fileURLWithPath: fullPath)
    }
    
    /**
     Overlays and exports a video with a desired UIImage on top.
     - Parameter video: AVAsset
     - Paremeter overlayImage: UIImage
     - Paremeter completion: Completion Handler
     - Parameter progressHandler: Returns the progress every 500 milliseconds.
     */
    func overlayVideo(video: AVAsset,
                      origin: CGPoint,
                      overlayImage: UIImage,
                      completion: @escaping (_ URL: URL?) -> Void,
                      progressHandler: @escaping (_ progress: Float) -> Void) {
        let videoTracks = video.tracks(withMediaType: AVMediaType.video)
        guard !videoTracks.isEmpty else { return }
        let videoTrack = videoTracks[0]
        
        let audioTracks = video.tracks(withMediaType: AVMediaType.audio)
        let audioTrack = audioTracks.isEmpty ? nil : audioTracks[0]
        let compositionTry = try? Composition(duration: video.duration, videoAsset: videoTrack, audioAsset: audioTrack)
        
        guard let composition = compositionTry else { return }
        
        let videoTransform = Transform(videoTrack.preferredTransform)
        let layerInstruction = LayerInstruction(track: composition.videoTrack, transform: videoTrack.preferredTransform, duration: video.duration)
        let instruction = Instruction(length: video.duration, layerInstructions: [layerInstruction.instruction])
        let size = Size(isPortrait: videoTransform.isPortrait, size: videoTrack.naturalSize)
        
        print("IMPORTANT")
        print(size.size.width)
        print(size.size.height)
        
        print(overlayImage.size)
        print("IMPORTANT")

        
        let layer = Layer(origin: origin, overlay: overlayImage, size: size.naturalSize, placement: configuration.placement)
        let videoComposition = VideoComposition(size: size.naturalSize, instruction: instruction,
                                                frameRate: configuration.frameRate,
                                                layer: layer
        )
        
        Exporter(asset: composition.asset, outputUrl: fileUrl, composition: videoComposition.composition, quality: configuration.quality).map { exporter in
            exporter.render { url in
                completion(url)
            }
            exporter.progress = { progress in
                progressHandler(progress)
            }
            } ?? completion(nil)
    }
}

/**
 Determines overlay placement.
 - stretchFit:  Stretches the ovelay to cover the entire video frame. This is ideal for
 situations for adding drawing to a video.
 - custom: Custom coordinates for the ovelay.
 */

enum Placement {
    
    case stretchFit
    case custom(x: CGFloat, y: CGFloat, size: CGSize)
    
    func rect(videoSize: CGSize) -> CGRect {
        switch self {
        case .stretchFit: return CGRect(origin: .zero, size: videoSize)
        case .custom(let x, let y, let size): return CGRect(x: x, y: y, width: size.width, height: size.height)
        }
    }
}

/**
 Determines export Quality
 - low
 - medium
 - high
 */

enum Quality: String {
    
    case low
    case medium
    case high
    
    var value: String {
        switch self {
        case .low: return AVAssetExportPresetLowQuality
        case .medium: return AVAssetExportPresetMediumQuality
        case .high: return AVAssetExportPresetHighestQuality
        }
    }
}

fileprivate final class LayerInstruction {
    
    let instruction: AVMutableVideoCompositionLayerInstruction
    
    init(track: AVMutableCompositionTrack, transform: CGAffineTransform, duration: CMTime) {
        instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        instruction.setTransform(transform, at: CMTime.zero)
        instruction.setOpacity(0.0, at: duration)
    }
    
}

fileprivate final class Composition {
    
    let asset = AVMutableComposition()
    let videoTrack: AVMutableCompositionTrack
    var audioTrack: AVMutableCompositionTrack?
    
    init(duration: CMTime, videoAsset: AVAssetTrack, audioAsset: AVAssetTrack? = nil) throws {
        videoTrack = asset.addMutableTrack(withMediaType: AVMediaType.video,
                                           preferredTrackID: Int32(kCMPersistentTrackID_Invalid))!
        try videoTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: duration),
                                       of: videoAsset,
                                       at: CMTime.zero)
        
        if let audioAsset = audioAsset {
            audioTrack = asset.addMutableTrack(withMediaType: AVMediaType.audio,
                                               preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            try audioTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: duration),
                                            of: audioAsset,
                                            at: CMTime.zero)
        }
    }
    
}

fileprivate final class Instruction {
    
    let videoComposition = AVMutableVideoCompositionInstruction()
    
    init(length: CMTime, layerInstructions: [AVVideoCompositionLayerInstruction]) {
        videoComposition.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: length)
        videoComposition.layerInstructions = layerInstructions
    }
}

fileprivate final class VideoComposition {
    
    let composition = AVMutableVideoComposition()
    
    init(size: CGSize, instruction: Instruction, frameRate: Int32, layer: Layer) {
        composition.renderSize = size
        composition.instructions = [instruction.videoComposition]
        composition.frameDuration = CMTimeMake(value: 1, timescale: frameRate)
        composition.animationTool = AVVideoCompositionCoreAnimationTool(
            postProcessingAsVideoLayer: layer.videoAndParent.video,
            in: layer.videoAndParent.parent
        )
    }
}

fileprivate final class Layer {
    
    fileprivate let overlay: UIImage
    fileprivate let size: CGSize
    fileprivate let placement: Placement
    
    fileprivate let origin: CGPoint
    
    init(origin: CGPoint, overlay: UIImage, size: CGSize, placement: Placement) {
        self.overlay = overlay
        self.size = size
        self.placement = placement
        self.origin = origin
    }
    
    fileprivate var frame: CGRect {
        return CGRect(origin: .zero, size: size)
    }
    
    fileprivate var overlayFrame: CGRect {
        return placement.rect(videoSize: CGSize(width: 720, height: 1280))
        //return placement.rect(videoSize: overlay.size)
        
        (166.0, 901.5, 278.0, 120.0)
        
        print("the bounds are \(UIScreen.main.bounds)")
        //origin.x + 30 + (overlay.size.width / 2)
        let newX = origin.x + ((UIScreen.main.bounds.width * UIScreen.main.scale) - size.width) + (overlay.size.width / 2)
        let newY = origin.y + ((UIScreen.main.bounds.height * UIScreen.main.scale) - size.height) - (overlay.size.height)
        //let newY = 1280 - (origin.y + overlay.size.height + (overlay.size.height / 2))
        //let newY = (1280 - UIScreen.main.bounds.height) - (origin.y + overlay.size.height)
        return CGRect(x: newX, y: newY, width: overlay.size.width, height: overlay.size.height)
    }
    
    lazy var videoAndParent: VideoAndParent = {
        let overlayLayer = CALayer()
        overlayLayer.contents = self.overlay.cgImage
        overlayLayer.frame = self.overlayFrame
        //overlayLayer.masksToBounds = true
        overlayLayer.backgroundColor = UIColor.orange.withAlphaComponent(0.2).cgColor
        overlayLayer.frame.size = CGSize(width: 100, height: 100)
        
        overlayLayer.frame.origin = CGPoint(x: 100, y: 100)
        //overlayLayer.frame.origin = CGPoint(x: origin.x + 720, y: origin.y + 560)
        
        let videoLayer = CALayer()
        videoLayer.frame = self.frame
        
        let parentLayer = CALayer()
        parentLayer.frame = self.frame
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(overlayLayer)
        
        print(parentLayer.frame)
        print(overlayLayer.frame)
        print(videoLayer.frame)
        print("////////////")
        
        return VideoAndParent(video: videoLayer, parent: parentLayer)
    }()
    
    final class VideoAndParent {
        let video: CALayer
        let parent: CALayer
        
        init(video: CALayer, parent: CALayer) {
            self.video = video
            self.parent = parent
        }
    }
}

///  A wrapper of AVAssetExportSession.
fileprivate final class Exporter {
    
    fileprivate let session: AVAssetExportSession
    
    var progress: ((_ progress: Float) -> Void)?
    
    init?(asset: AVMutableComposition, outputUrl: URL, composition: AVVideoComposition, quality: Quality) {
        guard let session = AVAssetExportSession(asset: asset, presetName: quality.value) else { return nil }
        self.session = session
        self.session.outputURL = outputUrl
        self.session.outputFileType = AVFileType.mp4
        self.session.videoComposition = composition
    }
    
    func render(complete: @escaping (_ url: URL?) -> Void) {
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos: .utility).async(group: group) {
            self.session.exportAsynchronously {
                group.leave()
                DispatchQueue.main.async {
                    complete(self.session.outputURL)
                }
            }
            self.progress(session: self.session, group: group)
        }
    }
    
    /**
     Polls the AVAssetExportSession status every 500 milliseconds.
     - Parameter session: AVAssetExportSession
     - Parameter group: DispatchGroup
     */
    private func progress(session: AVAssetExportSession, group: DispatchGroup) {
        while session.status == .waiting || session.status == .exporting {
            progress?(session.progress)
            _ = group.wait(timeout: DispatchTime.now() + .milliseconds(500))
        }
        
    }
    
}
/// Provides an easy way to detemine if the video was taken in landscape or portrait.
struct Transform {
    
    fileprivate let transform: CGAffineTransform
    
    init(_ transform: CGAffineTransform) {
        self.transform = transform
    }
    
    var isPortrait: Bool {
        guard transform.a == 0 && transform.d == 0 else { return false }
        switch (transform.b, transform.c) {
        case(1.0, -1.0): return true
        case(-1.0, 1.0): return true
        default: return false
        }
    }
}

private struct Size {
    fileprivate let isPortrait: Bool
    fileprivate let size: CGSize
    
    var naturalSize: CGSize {
        return isPortrait ? CGSize(width: size.height, height: size.width) : size
    }
}

/// Configuration struct.  Open for extension.
struct MergeConfiguration {
    let frameRate: Int32
    let directory: String
    let quality: Quality
    let placement: Placement
    
}

extension MergeConfiguration {
    
    static var standard: MergeConfiguration {
        return MergeConfiguration(frameRate: 30, directory: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0], quality: Quality.medium, placement: Placement.stretchFit)
    }
}


