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
    @IBOutlet weak var imageBackgroundView: UIImageView!
    @IBOutlet weak var videoContainerView: UIView!
    
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var commentContainerView: UIView!
    @IBOutlet weak var commentSuperView: UIView!
    @IBOutlet weak var resizeButton: UIButton!
    
    @IBOutlet weak var commentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var fontButton: UIButton!

    var media: UserMedia!

    private var fonts: [UIFont] = []
    
    private var fontIndex = 0
    private var selectedFontColor: UIColor = UIColor.white
    
    private var player: AVPlayer?
    
    private var isOriginal = true
    
    private var playerController: AVPlayerViewController!
    private var resizedVideoUrl: URL?
    
    private var indexHeight = 0
    
    private var loadingIndicator: UIActivityIndicatorView!
    private var colorSlider: ColorSlider!
    
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
        
        commentTextView.delegate = self
        
        if media.photo != nil {
            addColorSlider()
            
            imageBackgroundView.image = media.photo
            
            commentContainerView.enableDragging()
            commentContainerView.draggingStartedBlock = {
                (view) in
                self.commentTextField.resignFirstResponder()
            }
         } else if let url = media.videoUrl {
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
            playerController.videoGravity = AVLayerVideoGravity(rawValue: AVLayerVideoGravity.resizeAspectFill.rawValue)
            self.addChild(playerController)
            playerController.view.frame = videoContainerView.bounds
            videoContainerView.addSubview(playerController.view)
            
            player?.play()
            
//            let transition = CATransition()
//            transition.duration = 1
//            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
//            transition.type = CATransitionType.fade
//            playerController.view.layer.add(transition, forKey: nil)
            
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
        textButton.alpha = 1
        textButton.isEnabled = true
        
        setTextFieldFromMedia()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
    }
}

extension EditMediaViewController {
    @IBAction func onChangeFont(_ sender: Any) {
        if fontIndex < fonts.count - 1 {
            fontIndex += 1
        } else {
            fontIndex = 0
        }
        
        commentTextView.font = fonts[fontIndex].withSize(media.commentMode.fontSize())
        fontButton.setTitle(fonts[fontIndex].familyName, for: .normal)
        fontButton.setTitleColor(selectedFontColor, for: .normal)
    }
    
    @IBAction func onResize(_ sender: Any) {
        if media.videoUrl != nil {
            // video
            if isOriginal {
                guard let resizedVideoUrl = self.resizedVideoUrl else { return }
                playVideo(url: resizedVideoUrl)
            } else {
                playVideo(url: media.videoUrl!)
            }
        } else {
            // image
            if isOriginal {
                var scaleX: CGFloat
                var scaleY: CGFloat
                
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

   //MARK: IBAction
   @IBAction func onTapText(_ sender: Any) {
       media.commentMode = media.commentMode.next()
       setTextFieldFromMedia()
   }
    
   @IBAction func onBack(_ sender: Any) {
       player?.pause()
       navigationController?.popViewController(animated: true)
   }
    
    @IBAction func onNext(_ sender: Any) {
        var comment = commentTextView.text ?? ""
        if comment == "Your Text" {
            comment = ""
        }
        media.comment = comment
        media.commentColor = commentTextView.textColor
       
       if let _ = media.photo {
           let point = self.view.convert(commentContainerView.frame.origin, to: self.view)
        
           media.commentPos = CGPoint(x: point.x, y: point.y)
           media.photo = imageContainerView.takeScreenshot()
           
           if let image = MediaMerger.merge(photo: media, imageHeight: 200, font: commentTextView.font) {
               let processedMedia = UserMedia(video: nil, image: image)
                processedMedia.comment = media.comment
               if !isOriginal {
                   processedMedia.contentHeight = self.imageBackgroundView.frame.height
               }
               performSegue(withIdentifier: "tagGame", sender: processedMedia)
           }
       } else if let url = media.videoUrl {
           if !isOriginal {
               if let resizedUrl = resizedVideoUrl {
                   if comment.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
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
                            processedMedia.comment = self.media.comment
                               processedMedia.contentHeight = self.getHeightOfContent(url: newUrl)
                               self.performSegue(withIdentifier: "tagGame", sender: processedMedia)
                           }
                       }
      
                   } else {
                       let processedMedia = UserMedia(video: resizedUrl, image: nil)
                       processedMedia.comment = media.comment
                       processedMedia.contentHeight = self.getHeightOfContent(url: resizedUrl)
                       performSegue(withIdentifier: "tagGame", sender: processedMedia)
                    }
               } else {
                   if comment.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                       loadingIndicator.startAnimating()

                       addTextToVideo(url: url) { (newUrl) in
                           let processedMedia = UserMedia(video: newUrl, image: nil)
                        processedMedia.comment = self.media.comment
                           DispatchQueue.main.async {
                               self.loadingIndicator.stopAnimating()
                               self.performSegue(withIdentifier: "tagGame", sender: processedMedia)
                           }
                       }
                       
                   } else {
                       let processedMedia = UserMedia(video: url, image: nil)
                       processedMedia.comment = media.comment
                       performSegue(withIdentifier: "tagGame", sender: processedMedia)
                   }
               }
           } else {
               if comment.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                   loadingIndicator.startAnimating()
                   
                   addTextToVideo(url: url) { (newUrl) in
                       let processedMedia = UserMedia(video: newUrl, image: nil)
                    processedMedia.comment = self.media.comment
                       DispatchQueue.main.async {
                           self.loadingIndicator.stopAnimating()
                           self.performSegue(withIdentifier: "tagGame", sender: processedMedia)
                       }
                   }
               } else {
                   let processedMedia = UserMedia(video: url, image: nil)
                   processedMedia.comment = media.comment
                   performSegue(withIdentifier: "tagGame", sender: processedMedia)
               }
           }
       }
   }
}
 
extension EditMediaViewController {
    
    private func setTextFieldFromMedia() {
        if let f = commentTextField.font {
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
    
    private func addColorSlider() {
        colorSlider = ColorSlider(orientation: .vertical, previewSide: .left)
        colorSlider.frame = CGRect(x: 24, y: textButton.frame.origin.y, width: 12, height: 150)
        view.addSubview(colorSlider)
        
        colorSlider.addTarget(self, action: #selector(changedColor(_:)), for: .valueChanged)
    }
    
    private func playVideo(url: URL) {
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
    
    @objc private func changedColor(_ slider: ColorSlider) {
        //commentTextField.textColor = slider.color
        commentTextView.textColor = slider.color
        selectedFontColor = slider.color
    }
    
    @objc private func playerItemDidReachEnd(notification: Notification) {
        if let playerItem: AVPlayerItem = player?.currentItem {
            playerItem.seek(to: CMTime.zero, completionHandler: nil)
            player?.play()
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
            mediaProcessor.processElements(item: item) { (result, error) in
                
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
            return abs(videoTrack.naturalSize.height)
        } else {
            return abs(videoTrack.naturalSize.width)
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "" || textView.text == "Your Text" {
            textView.text = nil
            textView.textColor = selectedFontColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = ""
            textView.textColor = UIColor.lightGray
        }
    }
    
    func sizeOfString (string: String, constrainedToWidth width: Double, font: UIFont) -> CGSize {
        return (string as NSString).boundingRect(with: CGSize(width: width, height: Double.greatestFiniteMagnitude),
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
