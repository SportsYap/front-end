//
//  RecordViewController.swift
//  SportsYap
//
//  Created by Alex Pelletier on 3/5/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyCam

class RecordViewController: SwiftyCamViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var recordingOvalImageView: UIImageView!
    @IBOutlet var previewView: UIView!
    @IBOutlet var actionBttnCenterView: UIView!
    @IBOutlet weak var flashBttn: UIButton!
    @IBOutlet weak var flashStateImageView: UIImageView!
    
    var maxTimeTimer: Timer?
    var isRecording = false{
        didSet{
            actionBttnCenterView.backgroundColor = isRecording ? UIColor.red : UIColor.white
            recordingOvalImageView.alpha = isRecording ? 1 : 0
        }
    }
    var wasAccidentalVideo = false
    
    override func viewDidLoad() {
        videoGravity = .resizeAspectFill
        videoQuality = .resolution1280x720
        
        self.cameraDelegate = self
        isRecording = false
        
        super.viewDidLoad()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
     
        self.audioEnabled = false
    }
    
    //MARK: IBAction
    @IBAction func backBttnPressed(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func flashBttnPressed(_ sender: UIButton) {
        flashEnabled = !flashEnabled
        flashStateImageView.image = flashEnabled ? #imageLiteral(resourceName: "FlashOn") : #imageLiteral(resourceName: "FlashOff")
    }
    @IBAction func switchCameraBttnPressed(_ sender: Any) {
        switchCamera()
    }
    @IBAction func recordBttnPressedDown(_ sender: UIButton) {
        if !isRecording{
            wasAccidentalVideo = false
            startVideoRecording()
            isRecording = true
            print("Pressed")
            
            maxTimeTimer = Timer.scheduledTimer(withTimeInterval: 20, repeats: false, block: { (timer) in
                self.recordBttnReleased(self)
            })
        }
    }
    @IBAction func recordBttnReleased(_ sender: Any) {
        maxTimeTimer?.invalidate()
        if isRecording{
            if isVideoRecording{
                stopVideoRecording()
            }else{
                self.wasAccidentalVideo = true
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                    self.stopVideoRecording()
                }
            }
            print("Released")
            isRecording = false
        }else{
            wasAccidentalVideo = true
            takePhoto()
        }
    }
    @IBAction func recordBttnReleasedOutside(_ sender: Any) {
        maxTimeTimer?.invalidate()
        if isRecording{
            stopVideoRecording()
            print("Released")
            isRecording = false
        }
    }
    @IBAction func cameraRollBttnPressed(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = false
            imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //dismiss(animated:false, completion: nil)
                
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            _ = cropToBounds(image: image, width: Double(self.view.frame.width), height: Double(self.view.frame.height))
            
            User.me.didSelectFromGallery = true

            let media = UserMedia(video: nil, image: image)
            dismiss(animated:false, completion: nil)
            self.performSegue(withIdentifier: "showEdit", sender: media)
            
        }else if let video = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL{
            isRecording = false
            let maxTime: Double = User.me.verified ? 90 : 20
            cropVideo(sourceURL: video as URL, startTime: 0, endTime: maxTime) { (url) in
                DispatchQueue.main.async {
                    User.me.didSelectFromGallery = true
                    
                    let media = UserMedia(video: url, image: nil)
                    self.dismiss(animated:false, completion: nil)
                    self.performSegue(withIdentifier: "showEdit", sender: media)
                }
            }
            
        } else {
            dismiss(animated:false, completion: nil)
        }
    }

    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EditMediaViewController, let media = sender as? UserMedia{
            vc.media = media
        }
    }
    
    //MARK: UTIL
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        
        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        var contextSize: CGSize = contextImage.size
        let imageAspect = contextSize.width / contextSize.height
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        let targetAspect = cgwidth / cgheight
        var scale: CGFloat = 1
        
        if targetAspect > imageAspect{ //Taller then target
            scale = contextSize.height / cgheight
        }else{ // wider then target
            scale = contextSize.width / cgwidth
        }
        
//        contextSize = CGSize(width: contextSize.width / scale, height: contextSize.height / scale)
        cgwidth *= scale
        cgheight *= scale
        
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
//            cgwidth = contextSize.height
//            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
//            cgwidth = contextSize.width
//            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: 1, orientation: image.imageOrientation)
        
        return image
    }
    func cropVideo(sourceURL: URL, startTime: Double, endTime: Double, completion: ((_ outputUrl: URL) -> Void)? = nil){
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let asset = AVAsset(url: sourceURL)
        let length = Float(asset.duration.value) / Float(asset.duration.timescale)
        print("video length: \(length) seconds")
        
        var outputURL = documentDirectory.appendingPathComponent("output")
        do {
            try fileManager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            /*
            if sourceURL.lastPathComponent.contains(".") {
                let newSourceUrl = sourceURL.lastPathComponent.replacingOccurrences(of: ".", with: "")
                outputURL = outputURL.appendingPathComponent("\(newSourceUrl).mp4")
            } else {
                outputURL = outputURL.appendingPathComponent("\(sourceURL.lastPathComponent).mp4")
            }
            */
            outputURL = outputURL.appendingPathComponent("\(sourceURL.lastPathComponent).mp4")

    
        }catch let error {
            print(error)
        }
        
        //Remove existing file
        try? fileManager.removeItem(at: outputURL)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        
        guard Double(length) > endTime else {
            completion?(sourceURL)
            return
        }
        
        let endTime = min(endTime, Double(length))
        let timeRange = CMTimeRange(start: CMTime(seconds: startTime, preferredTimescale: 1000),
                                    end: CMTime(seconds: endTime, preferredTimescale: 1000))
        
        exportSession.timeRange = timeRange
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                print("exported at \(outputURL)")
                completion?(outputURL)
            case .failed:
                print("failed \(exportSession.error.debugDescription)")
            case .cancelled:
                print("cancelled \(exportSession.error.debugDescription)")
            default: break
            }
        }
    }
}

extension RecordViewController: SwiftyCamViewControllerDelegate{
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        print("video taken")
    }
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        guard !wasAccidentalVideo else { return }
        let maxTime: Double = User.me.verified ? 90 : 20
        cropVideo(sourceURL: url, startTime: 0, endTime: maxTime) { (url) in
            DispatchQueue.main.async {
                User.me.didSelectFromGallery = false

                let media = UserMedia(video: url, image: nil, recordedVideo: true)
                self.performSegue(withIdentifier: "showEdit", sender: media)
            }
        }
    }
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        User.me.didSelectFromGallery = false

        let media = UserMedia(video: nil, image: photo)
        self.performSegue(withIdentifier: "showEdit", sender: media)
    }
    
}
