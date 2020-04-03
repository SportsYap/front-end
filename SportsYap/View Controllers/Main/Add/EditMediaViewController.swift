//
//  EditMediaViewController.swift
//  SportsYap
//
//  Created by Alex Pelletier on 4/23/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit
import UIView_draggable
import AVKit
import ColorSlider
import AVFoundation

class EditMediaViewController: UIViewController {

    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet var imageBackgroundView: UIImageView!
    @IBOutlet var videoContainerView: UIView!
    
    @IBOutlet weak var textBttn: UIButton!
    @IBOutlet var commentTextField: UITextField!
    @IBOutlet var commentContainerView: UIView!
    @IBOutlet weak var commentSuperView: UIView!
    @IBOutlet weak var resizeButton: UIButton!
    
    @IBOutlet weak var commentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var fontButton: UIButton!

    var fonts: [UIFont] = []
    
    var fontIndex = 0
    var selectedFontColor: UIColor = UIColor.white
    
    var media: UserMedia!
    var player: AVPlayer?
    
    var isOriginal = true
    
    var playerController: AVPlayerViewController!
    var resizedVideoUrl: URL?
    
    var indexHeight = 0
    
    var loadingIndicator: UIActivityIndicatorView!
    var colorSlider: ColorSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appendCustomFonts()
        
        imageContainerView.backgroundColor = .black
        
        resizeButton.layer.cornerRadius = resizeButton.layer.frame.height / 2
        resizeButton.layer.masksToBounds = false
        
        fontButton.layer.cornerRadius = fontButton.layer.frame.height / 2
        fontButton.layer.masksToBounds = false
        fontButton.layer.borderColor = UIColor.white.cgColor
        fontButton.layer.borderWidth = 1
        fontButton.titleLabel?.adjustsFontSizeToFitWidth = true
   
        var placeHolder = NSMutableAttributedString()
        let Name  = "Your Text"
        placeHolder = NSMutableAttributedString(string:Name, attributes: [NSAttributedString.Key.font:UIFont(name: "Helvetica", size: 15.0)!])
        placeHolder.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white.withAlphaComponent(0.5), range:NSRange(location:0,length:Name.length))
        commentTextField.attributedPlaceholder = placeHolder
        
        // DELETE
        //commentTextField.backgroundColor = .orange
        //commentSuperView.backgroundColor = .clear
        //commentContainerView.backgroundColor = .clear
        //view.backgroundColor = .clear
                
        commentTextView.delegate = self
        
        if media.photo != nil{
            addColorSlider()
            
            imageBackgroundView.image = media.photo
            
            print("image size is: \(media.photo!.size)")
            
            commentContainerView.enableDragging()
            commentContainerView.draggingStartedBlock = {
                (view) in
                self.commentTextField.resignFirstResponder()
            }
            //setTextFieldFromMedia()
            
        }else if let url = media.videoUrl{
            //commentContainerView.alpha = 0
            //textBttn.alpha = 0
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            } catch {
                print("Setting category to AVAudioSessionCategoryPlayback failed.")
            }
            
            addColorSlider()
            
            player = AVPlayer(url: url)
            playerController = AVPlayerViewController()
            playerController.player = player
            playerController.showsPlaybackControls = false
            //playerController.videoGravity = AVLayerVideoGravity(rawValue: AVLayerVideoGravity.resizeAspect.rawValue)
            playerController.videoGravity = AVLayerVideoGravity(rawValue: AVLayerVideoGravity.resizeAspectFill.rawValue)
            self.addChild(playerController)
            playerController.view.frame = videoContainerView.bounds
            videoContainerView.addSubview(playerController.view)
            
            player?.play()
            
            let transition = CATransition()
            transition.duration = 1
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            transition.type = CATransitionType.fade
            playerController.view.layer.add(transition, forKey: nil)
            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(playerItemDidReachEnd(notification:)),
                                                   name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: player?.currentItem)
            
            commentContainerView.enableDragging()
            commentContainerView.draggingStartedBlock = {
                (view) in
                self.commentTextField.resignFirstResponder()
            }

            let videoAsset = AVURLAsset(url: url)
            
            let videoTracks = videoAsset.tracks(withMediaType: AVMediaType.video)
            guard !videoTracks.isEmpty else { return }
            let videoTrack = videoTracks[0]
            
            print("Comment View: \(commentSuperView.frame.size)")
            commentSuperView.frame.size = videoTrack.naturalSize
            print("Comment View: \(commentSuperView.frame.size)")

            let targetSize: CGSize
            
            var result: (AVMutableComposition, AVMutableVideoComposition)
            
            if !media.recordedVideo && videoTrack.naturalSize.width > videoTrack.naturalSize.height {
                // landscape video
                targetSize = view.bounds.size
                
                result = try! resizeVideo(videoAsset: videoAsset, targetSize: targetSize, isKeepAspectRatio: true, isCutBlackEdge: false)
                
            } else {
                let calculatedWidth = view.bounds.height * 0.490625
                targetSize = CGSize(width: calculatedWidth, height: view.bounds.height)

                result = try! resizeVideo(videoAsset: videoAsset, targetSize: targetSize, isKeepAspectRatio: true, isCutBlackEdge: false)
            }
            
            print("natural size is: \(videoTrack.naturalSize)")
            print("target size is: \(targetSize)")

            let filePath = NSTemporaryDirectory() + "resizedVideo.mp4"
            print(filePath)
            print("the file path")
            exportVideo(recordedVideo: media.recordedVideo, outputPath: filePath, asset: result.0, videoComposition: result.1, fileType: AVFileType.mp4) { (success) in
                DispatchQueue.main.async {
                    if success {
                        self.resizedVideoUrl = NSURL.fileURL(withPath: filePath)
                    } else {
                        print("error")
                    }
                }
            }
        }
        
        // add indicator
        loadingIndicator = UIActivityIndicatorView(style: .whiteLarge)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.center = view.center
        view.addSubview(loadingIndicator)
                
        commentContainerView.alpha = 1
        colorSlider.alpha = 1
        fontButton.alpha = 1
        textBttn.alpha = 1
        textBttn.isEnabled = true
        
        setTextFieldFromMedia()
        
        /*
        if User.me.didSelectFromGallery {
            commentContainerView.alpha = 0
            colorSlider.alpha = 0
            fontButton.alpha = 0
            textBttn.alpha = 0
            textBttn.isEnabled = false
        } else {
            commentContainerView.alpha = 1
            colorSlider.alpha = 1
            fontButton.alpha = 1
            textBttn.alpha = 1
            textBttn.isEnabled = true
            
            setTextFieldFromMedia()
        }
        */
        
    }
    
    @IBAction func fontPressed(_ sender: Any) {
        if fontIndex < fonts.count - 1 {
            fontIndex += 1
        } else {
            fontIndex = 0
        }
        
        commentTextView.font = fonts[fontIndex].withSize(media.commentMode.fontSize())
        fontButton.setTitle(fonts[fontIndex].familyName, for: .normal)
        fontButton.setTitleColor(selectedFontColor, for: .normal)
    }
    
    @IBAction func resizePressed(_ sender: Any) {
        if media.videoUrl != nil {
            // video
            if isOriginal {
                guard let resizedVideoUrl = self.resizedVideoUrl else { return }
                self.playVideo(url: resizedVideoUrl)
                
                //playerController.view.layer
                UIView.animate(withDuration: 1.5, animations: {
                    //self.playerController.view.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                })
 
            } else {
                playVideo(url: media.videoUrl!)
                
                UIView.animate(withDuration: 1.5, animations: {
                    //self.playerController.view.transform = CGAffineTransform(scaleX: 1, y: 1)
                })
            }
            
        } else {
            // image
            if isOriginal {
                
                var scaleX: CGFloat
                var scaleY: CGFloat
                
                // 667 / 2316 = 0.2879965 * 1.5 = 0.43199
                
                if media.photo!.size.width > media.photo!.size.height {
                    // landscape
                    scaleX = view.bounds.width / media.photo!.size.width
                    scaleY = view.bounds.width / media.photo!.size.width
                    
                } else {
                    scaleX = view.bounds.height / media.photo!.size.height
                    scaleY = view.bounds.height / media.photo!.size.height
                }
                
                scaleX = view.bounds.height / media.photo!.size.height
                scaleY = view.bounds.height / media.photo!.size.height
 
                UIView.animate(withDuration: 1.5, animations: {
                    self.imageBackgroundView.transform = CGAffineTransform(scaleX: scaleX * 1.5, y: scaleY * 1.5) //0.6
                })
                
            } else {
                
                UIView.animate(withDuration: 1.5, animations: {
                    self.imageBackgroundView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                })
            }
        }
        
        isOriginal = !isOriginal
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
    }
    
    func setTextFieldFromMedia(){
        if let f = commentTextField.font{
            let center = commentContainerView.center
            commentTextField.font = f.withSize(media.commentMode.fontSize())
            
            //commentTextView.font = commentTextField.font
            commentTextView.font = fonts[fontIndex].withSize(media.commentMode.fontSize())
            fontButton.setTitle(fonts[fontIndex].familyName, for: .normal)
            fontButton.sizeToFit()
            
            if commentTextView.text == "Your Text" || commentTextView.text == "" {
                commentTextView.text = "Your Text"
                commentTextView.textColor = UIColor.lightGray
            } else {
                commentTextView.textColor = selectedFontColor
            }
            
            self.commentContainerView.alpha = 0
            DispatchQueue.main.asyncAfter(deadline: .now()+0.03) { // A little hacky
                self.commentContainerView.alpha = 1
                //self.commentContainerView.center = center
            }
        }
    }
    
    func addColorSlider() {
        colorSlider = ColorSlider(orientation: .vertical, previewSide: .left)
        colorSlider.frame = CGRect(x: 24, y: textBttn.frame.origin.y, width: 12, height: 150)
        view.addSubview(colorSlider)
        
        colorSlider.addTarget(self, action: #selector(changedColor(_:)), for: .valueChanged)
    }
    
    func playVideo(url: URL) {
        player = AVPlayer(url: url)
        playerController.player = player
        player?.play()
        
        print(self.playerController.videoBounds)
        print("the bounds2")
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: player?.currentItem)
    }
    
    @objc func changedColor(_ slider: ColorSlider) {
        //commentTextField.textColor = slider.color
        commentTextView.textColor = slider.color
        selectedFontColor = slider.color
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        if let playerItem: AVPlayerItem = player?.currentItem {
            playerItem.seek(to: CMTime.zero, completionHandler: nil)
            player?.play()
        }
    }
    
    //MARK: IBAction
    @IBAction func textBttnPressed(_ sender: Any) {
        media.commentMode = media.commentMode.next()
        setTextFieldFromMedia()
    }
    @IBAction func backBttnPressed(_ sender: Any) {
        player?.pause()
        self.navigationController?.popViewController(animated: false)
    }
    @IBAction func nextBttnPressed(_ sender: Any) {
        //media.comment = commentTextField.text ?? ""
        //media.commentColor = commentTextField.textColor
        media.comment = commentTextView.text ?? ""
        media.commentColor = commentTextView.textColor
        
        if let pre = media.photo{
            let point = self.view.convert(commentContainerView.frame.origin, to: self.view)
            //media.commentPos = CGPoint(x: point.x + 10, y: point.y + 15)
            media.commentPos = CGPoint(x: point.x, y: point.y)
 
            media.photo = imageContainerView.takeScreenshot()
            
            if let image = MediaMerger.merge(photo: media, imageHeight: 200, font: commentTextView.font) {
                let processedMedia = UserMedia(video: nil, image: image)
                
                if !isOriginal {
                    processedMedia.contentHeight = self.imageBackgroundView.frame.height
                }
                
                self.performSegue(withIdentifier: "tagGame", sender: processedMedia)
            }
            
        } else if let url = media.videoUrl {
 
            if !isOriginal {
                
                if let resizedUrl = resizedVideoUrl {
                    
                    if commentTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                        
                        self.loadingIndicator.startAnimating()
                        
                        addTextToVideo(url: resizedUrl, resized: true) { (newUrl) in
                            
                            guard let newUrl = newUrl else {
                                self.alert(message: "Error adding text to video.")
                                self.loadingIndicator.stopAnimating()
                                return
                            }
                            
                            DispatchQueue.main.async {
                                self.loadingIndicator.stopAnimating()
                                
                                let processedMedia = UserMedia(video: newUrl, image: nil)
                                processedMedia.contentHeight = self.getHeightOfContent(url: newUrl)
                                self.performSegue(withIdentifier: "tagGame", sender: processedMedia)
                                
                                // FOR TESTING
                                //self.playVideo(url: newUrl)
                            }
                        }
       
                    } else {
                        let processedMedia = UserMedia(video: resizedUrl, image: nil)
                        processedMedia.contentHeight = self.getHeightOfContent(url: resizedUrl)
                        self.performSegue(withIdentifier: "tagGame", sender: processedMedia)
                        
                        // FOR TESTING
                        //self.playVideo(url: resizedUrl)
                    }
                    
                } else {
                    
                    if commentTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                        
                        self.loadingIndicator.startAnimating()

                        addTextToVideo(url: url) { (newUrl) in
                            let processedMedia = UserMedia(video: newUrl, image: nil)
                            DispatchQueue.main.async {
                                self.loadingIndicator.stopAnimating()
                                self.performSegue(withIdentifier: "tagGame", sender: processedMedia)
                                
                                // FOR TESTING
                                //self.playVideo(url: newUrl!)
                            }
                        }
                        
                    } else {
                        let processedMedia = UserMedia(video: url, image: nil)
                        self.performSegue(withIdentifier: "tagGame", sender: processedMedia)
                    }
                }
                
            } else {
                
                if commentTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                    
                    self.loadingIndicator.startAnimating()
                    
                    addTextToVideo(url: url) { (newUrl) in
                        let processedMedia = UserMedia(video: newUrl, image: nil)
                        DispatchQueue.main.async {
                            self.loadingIndicator.stopAnimating()
                            self.performSegue(withIdentifier: "tagGame", sender: processedMedia)
                            
                            // FOR TESTING
                            //self.playVideo(url: newUrl!)
                        }
                    }
                    
                } else {
                    let processedMedia = UserMedia(video: url, image: nil)
                    self.performSegue(withIdentifier: "tagGame", sender: processedMedia)
                }
            }
        }
    }
    
    private func addTextToVideo(url: URL, resized: Bool = false, completion:@escaping ((URL?) -> Void)) {
        //commentSuperView.backgroundColor = UIColor.orange.withAlphaComponent(0.3)
        //let track = AVURLAsset(url: media.videoUrl!).tracks(withMediaType: AVMediaType.video).first
        //let size = track!.naturalSize.applying(track!.preferredTransform)
        
        //let trackResized = AVURLAsset(url: resizedVideoUrl!).tracks(withMediaType: AVMediaType.video).first
        //let resizedSize = trackResized!.naturalSize.applying(track!.preferredTransform)
        let track = AVURLAsset(url: media.videoUrl!).tracks(withMediaType: AVMediaType.video).first
        
        let size: CGSize
        
        if resized {
            let trackResized = AVURLAsset(url: resizedVideoUrl!).tracks(withMediaType: AVMediaType.video).first
            size = trackResized!.naturalSize.applying(track!.preferredTransform)
        } else {
            size = track!.naturalSize.applying(track!.preferredTransform)
        }

        let overlayImage = commentSuperView.takeScreenshot(size: CGSize(width: abs(size.width), height: size.height))

        if let item = MediaItem(url: url) {
            let firstElement = MediaElement(image: overlayImage)

            if resized {
                //firstElement.frame = CGRect(x: 0, y: 0, width: overlayImage.size.width, height: overlayImage.size.height) // ORIGINAL
                
                //firstElement.frame = CGRect(x: -20, y: 8, width: size.width - widthDiff, height: size.height - heightDiff)
                //firstElement.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                
            } else {
                //firstElement.frame = CGRect(x: 0, y: 0, width: (overlayImage.size.width * 1.8) + 5, height: overlayImage.size.height * 1.8)  // ORIGINAL
                
                //firstElement.frame = CGRect(x: 0, y: 0, width: (overlayImage.size.width * 0.8) + 5, height: overlayImage.size.height * 0.8)
                
                //firstElement.frame = CGRect(x: 0, y: 0, width: overlayImage.size.width * 0.7, height: UIScreen.main.bounds.size.height)
                
                //firstElement.frame = CGRect(x: 0, y: 0, width: overlayImage.size.width, height: overlayImage.size.height)
            }
            
            
            if (size.width > size.height) {
                // landscape
                let widthDiff = abs(size.width) - view.frame.size.width
                firstElement.frame = CGRect(x: 0 + (widthDiff / 2), y: 0, width: overlayImage.size.width - widthDiff, height: overlayImage.size.height)
                
            } else {
                firstElement.frame = CGRect(x: 0 + 16, y: 0, width: overlayImage.size.width - 32, height: overlayImage.size.height)
            }
  
            print("overlay image size: \(overlayImage.size)")
            print("video size: \(size)")
            print("view frame: \(view.frame)")
            print("view bounds: \(view.bounds)")
            print("comment text view frame: \(commentTextView.frame)")
            print("comment text field frame: \(commentTextField.frame)")
            print("comment superview frame: \(commentSuperView.frame)")
            print("comment container view frame: \(commentContainerView.frame)")

            item.add(element: firstElement)
 
            let mediaProcessor = MediaProcessor()
            mediaProcessor.processElements(item: item) { [weak self] (result, error) in
                
                do {
                    let resourceValues = try result.processedUrl!.resourceValues(forKeys: [.fileSizeKey])
                    let fileSize = resourceValues.fileSize!
                    
                    print("File size: \(fileSize)")
                    
                } catch { print(error) }
                
                completion(result.processedUrl)
            }
            
            
            
            
        }
        
    }
        
    private func getHeightOfContent(url: URL) -> CGFloat {
        let videoAsset = AVURLAsset(url: url)
        
        let videoTracks = videoAsset.tracks(withMediaType: AVMediaType.video)
        guard !videoTracks.isEmpty else { return 0 }
        let videoTrack = videoTracks[0]
        
        let orientation = orientationFromTransform(transform: videoTrack.preferredTransform)
        
        if orientation.isPortrait {
            return fabs(videoTrack.naturalSize.height)
        } else {
            return fabs(videoTrack.naturalSize.width)
        }
    }
    
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TagGameViewController, let m = sender as? UserMedia{
            vc.media = m
        }
    }
    
    private func appendCustomFonts() {
        fonts.removeAll()
        
        if let font = UIFont(name: "AmericanTypewriter", size: 24) {
            fonts.append(font)
        }
        
        if let font = UIFont(name: "Baskerville", size: 24) {
            fonts.append(font)
        }
        
        if let font = UIFont(name: "BodoniSvtyTwoOSITCTT-BookIt", size: 24) {
            fonts.append(font)
        }
        
        if let font = UIFont(name: "BradleyHandITCTT-Bold", size: 24) {
            fonts.append(font)
        }
        
        if let font = UIFont(name: "Chalkduster", size: 24) {
            fonts.append(font)
        }
        
        if let font = UIFont(name: "Cochin", size: 24) {
            fonts.append(font)
        }
        
        if let font = UIFont(name: "DINCondensed-Bold", size: 24) {
            fonts.append(font)
        }
        
        if let font = UIFont(name: "Didot", size: 24) {
            fonts.append(font)
        }
        
        if let font = UIFont(name: "Futura-Medium", size: 24) {
            fonts.append(font)
        }
        
        if let font = UIFont(name: "GillSans", size: 24) {
            fonts.append(font)
        }
        
        if let font = UIFont(name: "GurmukhiMN", size: 24) {
            fonts.append(font)
        }
        
        if let font = UIFont(name: "Helvetica", size: 24) {
            fonts.append(font)
        }
        
        if let font = UIFont(name: "IowanOldStyle-Roman", size: 24) {
            fonts.append(font)
        }
        
        if let font = UIFont(name: "KohinoorBangla-Regular", size: 24) {
            fonts.append(font)
        }
        
        if let font = UIFont(name: "Menlo-Regular", size: 24) {
            fonts.append(font)
        }
        
        if let font = UIFont(name: "Optima-Regular", size: 24) {
            fonts.append(font)
        }
        
        if let font = UIFont(name: "Papyrus", size: 24) {
            fonts.append(font)
        }
        
        if let font = UIFont(name: "SnellRoundHand", size: 24) {
            fonts.append(font)
        }
        
        if let font = UIFont(name: "Superclarendon-BoldItalic", size: 24) {
            fonts.append(font)
        }
        
        if let font = UIFont(name: "TamilSangamMN", size: 24) {
            fonts.append(font)
        }
        
        if let font = UIFont(name: "TimesNewRomanPSMT", size: 24) {
            fonts.append(font)
        }
        
        if let font = UIFont(name: "Verdana", size: 24) {
            fonts.append(font)
        }
        
        if let font = UIFont(name: "Zapfino", size: 24) {
            fonts.append(font)
        }
    }
  
}


extension EditMediaViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.frame.width >= view.frame.width {
            //commentTextView.frame.size.height = heightOfTextView * 2
        } else {
            //commentTextView.frame.size.height = heightOfTextView
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = .white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Your Text"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func sizeOfString (string: String, constrainedToWidth width: Double, font: UIFont) -> CGSize {
        return (string as NSString).boundingRect(with: CGSize(width: width, height: DBL_MAX),
                                                 options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                         attributes: [NSAttributedString.Key.font: font],
                                                         context: nil).size
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        
        var textWidth = textView.frame.width
        textWidth -= 2.0 * textView.textContainer.lineFragmentPadding;
        
        let boundingRect = sizeOfString(string: newText, constrainedToWidth: Double(textWidth), font: textView.font!)
        let numberOfLines = boundingRect.height / textView.font!.lineHeight;
        
        print("number of lines: \(numberOfLines)")

        return numberOfLines <= 3.3
    }
    
}


/*
 let newWidth = videoTrack.naturalSize.width / 1.7
 let newHeight = videoTrack.naturalSize.height / 1.7
 
 let targetSize: CGSize
 
 if newWidth < newHeight {
 targetSize = CGSize(width: newHeight, height: newHeight)
 } else {
 targetSize = CGSize(width: newWidth, height: newWidth)
 }
 
 let result = try! resizeVideo(videoAsset: videoAsset, targetSize: targetSize, isKeepAspectRatio: true, isCutBlackEdge: false)
 */


/*
 THIS STUFF IS FOR ADDING TEXT TO VIDEO
 do {
 let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
 let fileSize = resourceValues.fileSize!
 
 let resourceValues2 = try resizedVideoUrl!.resourceValues(forKeys: [.fileSizeKey])
 let fileSize2 = resourceValues2.fileSize!
 
 print("File size: \(fileSize)")
 print("File size 2: \(fileSize2)")
 
 } catch { print(error) }
 */


/*
 let videoAsset = AVURLAsset(url: newUrl)
 
 let videoTracks = videoAsset.tracks(withMediaType: AVMediaType.video)
 guard !videoTracks.isEmpty else {
 self.alert(message: "No video found.")
 self.loadingIndicator.stopAnimating()
 return
 }
 let videoTrack = videoTracks[0]
 
 let targetSize: CGSize
 
 var result: (AVMutableComposition, AVMutableVideoComposition)
 
 if !self.media.recordedVideo && videoTrack.naturalSize.width > videoTrack.naturalSize.height {
 // landscape video
 targetSize = boundsSize
 
 result = try! resizeVideo(videoAsset: videoAsset, targetSize: targetSize, isKeepAspectRatio: true, isCutBlackEdge: false)
 
 } else {
 let calculatedWidth = boundsHeight * 0.490625
 targetSize = CGSize(width: calculatedWidth, height: boundsHeight)
 
 result = try! resizeVideo(videoAsset: videoAsset, targetSize: targetSize, isKeepAspectRatio: true, isCutBlackEdge: false)
 }
 
 
 let filePath = NSTemporaryDirectory() + "resizedVideo.mp4"
 exportVideo(recordedVideo: self.media.recordedVideo, outputPath: filePath, asset: result.0, videoComposition: result.1, fileType: AVFileType.mp4) { (success) in
 DispatchQueue.main.async {
 
 self.loadingIndicator.stopAnimating()
 
 if success {
 let resizedTextUrl = URL(fileURLWithPath: filePath)
 let processedMedia = UserMedia(video: resizedTextUrl, image: nil)
 processedMedia.contentHeight = self.getHeightOfContent(url: resizedTextUrl)
 self.performSegue(withIdentifier: "tagGame", sender: processedMedia)
 
 } else {
 self.alert(message: "Error exporting video.")
 }
 }
 }
 */
