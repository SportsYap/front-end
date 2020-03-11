//
//  LiveStreamingViewController.swift
//  SportsYap
//
//  Created by Alex Pelletier on 4/25/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit
import AVFoundation

class LiveStreamingViewController: UIViewController{ //}, WZVideoSink, WZAudioSink{

    @IBOutlet var videoContainerView: UIView!
    
    @IBOutlet var streamControlBgView: UIView!
    @IBOutlet var streamControlTitleLbl: UILabel!
    @IBOutlet var streamControlBttn: UIButton!
    @IBOutlet weak var backBttn: UIButton!
    
//    var goCoder:WowzaGoCoder?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        setupWowza()
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        setupVideoView()
//        setStreamBttnUI()
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        setStreamBttnUI()
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//
//        self.goCoder?.cameraPreview?.stop()
//        self.goCoder?.endStreaming(self)
//        self.goCoder?.unregisterAudioSink(self as WZAudioSink)
//        self.goCoder?.unregisterVideoSink(self as WZVideoSink)
//        self.goCoder?.cameraView = nil
//
//        ApiManager.shared.stopStream(onSuccess: { }, onError: voidErr)
//
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        goCoder?.cameraPreview?.previewLayer?.frame = videoContainerView.bounds
//    }
//
//    func setupWowza(){
//        print("WowzaGoCoderSDK version =\n major: \(WZVersionInfo.majorVersion())\n minor: \(WZVersionInfo.minorVersion())\n revision: \(WZVersionInfo.revision())\n build: \(WZVersionInfo.buildNumber())\n string: \(WZVersionInfo.string())\n verbose string: \(WZVersionInfo.verboseString())")
//
//        print("Platform Info:\n\(WZPlatformInfo.string())")
//
//        if let err = WowzaGoCoder.registerLicenseKey("GSDK-0144-0000-04A2-EDC5-EC61") {
//            print(err.localizedDescription)
//        }
//
//        if let gc = WowzaGoCoder.sharedInstance() {
//            goCoder = gc
//        }
//    }
//
//    func setupVideoView(){
//        guard goCoder != nil else { return }
//
//        // Request camera and microphone permissions
//        WowzaGoCoder.requestPermission(for: .camera, response: { (permission) in
//            print("Camera permission is: \(permission == .authorized ? "authorized" : "denied")")
//        })
//
//        WowzaGoCoder.requestPermission(for: .microphone, response: { (permission) in
//            print("Microphone permission is: \(permission == .authorized ? "authorized" : "denied")")
//        })
//
//        self.goCoder?.register(self as WZAudioSink)
//        self.goCoder?.register(self as WZVideoSink)
//
//        // Specify the view in which to display the camera preview
//        self.goCoder?.cameraPreview?.previewGravity = .resizeAspectFill
//        self.goCoder?.cameraView = videoContainerView
//
//        // Start the camera preview
//        self.goCoder?.cameraPreview?.start()
//    }
//
//    func setStreamBttnUI(){
//        if self.goCoder?.status.state != .idle && self.goCoder?.status.state != .running {
//            streamControlBttn.isEnabled = false
//            streamControlBgView.alpha = 0.5
//        }else{
//            streamControlBttn.isEnabled = true
//            streamControlBgView.alpha = 1
//            let isStreaming = self.goCoder?.isStreaming ?? false
//            streamControlBgView.backgroundColor = isStreaming ? UIColor.red : UIColor.white
//            streamControlTitleLbl.text = isStreaming ? "Stop Live Video" : "Start Live Video"
//            streamControlTitleLbl.textColor = isStreaming ? UIColor.white : UIColor.black
//            backBttn.alpha = isStreaming ? 0 : 1
//            ParentScrollingViewController.shared.enabled(is: !isStreaming)
//            if let parent = self.parent as? CameraContainerViewViewController{
//                parent.scrollView.isUserInteractionEnabled = !isStreaming
//            }
//        }
//    }
//    func startStreamWith(info: [String: AnyObject]){
//        self.goCoder?.config.streamName = (info["stream_name"] as? String) ?? ""
//        self.goCoder?.config.hostAddress = (info["primary_server"] as? String) ?? ""
//        self.goCoder?.config.portNumber = UInt((info["host_port"] as? Int) ?? 0)
//        self.goCoder?.config.password = (info["password"] as? String) ?? ""
//        self.goCoder?.config.username = (info["username"] as? String) ?? ""
//        self.goCoder?.config.applicationName = (info["application"] as? String) ?? ""
//
//        if let configError = self.goCoder?.config.validateForBroadcast() {
//            print(configError.localizedDescription)
//        }else {
//            self.goCoder?.isAudioMuted = true
//            self.goCoder?.startStreaming(self)
//        }
//
//        self.streamControlBttn.isEnabled = true
//        self.setStreamBttnUI()
//    }
//    func startStream(tries: Int = 0){
//        guard tries < 10 else {
//            streamControlBttn.isEnabled = true
//            streamControlBgView.alpha = 1
//            alert(message: "Internal Live Streaming Error")
//            return
//        }
//
//        streamControlBttn.isEnabled = false
//        streamControlBgView.alpha = 0.5
//        backBttn.alpha = 0
//        ParentScrollingViewController.shared.enabled(is: false)
//        streamControlTitleLbl.text = "Starting Live Stream"
//
//        ApiManager.shared.streamInfo(onSuccess: { (info, status) in
//            if status == "started"{
//                DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
//                    self.startStreamWith(info: info)
//                })
//            }else if status == "starting"{
//                DispatchQueue.main.asyncAfter(deadline: .now()+5, execute: {
//                    self.startStream(tries: tries + 1)
//                })
//            }else{
//                self.setStreamBttnUI()
//                self.streamControlBttn.isEnabled = true
//                self.streamControlBgView.alpha = 1
//                self.alert(message: "Internal Live Streaming Error")
//            }
//        }) { (err) in
//            self.streamControlBttn.isEnabled = true
//        }
//    }
//
//
//    //MARK: IBAction
//    @IBAction func backBttnPressed(_ sender: Any) {
//        ParentScrollingViewController.shared.scrollToTabs()
//    }
//    @IBAction func startLiveStreamingBttnPressed(_ sender: Any) {
//        guard self.goCoder?.status.state != .running else {
//            self.goCoder?.endStreaming(self)
//            ApiManager.shared.stopStream(onSuccess: { }, onError: voidErr)
//            return
//        }
//
//        guard !isOnPhoneCall() else {
//            alert(message: "You can not live stream while on the phone.")
//            return
//        }
//
//        ApiManager.shared.startStream(onSuccess: { }, onError: voidErr)
//
//        startStream()
//    }
//    @IBAction func switchCameraBttnPressed(_ sender: Any) {
//        guard goCoder != nil else { return }
//
//        if let otherCamera = goCoder?.cameraPreview?.otherCamera() {
//            if !otherCamera.supportsWidth(goCoder!.config.videoWidth) {
//                goCoder?.config.load(otherCamera.supportedPresetConfigs.last!.toPreset())
//            }
//
//            goCoder?.cameraPreview?.switchCamera()
//        }
//    }
    

}
//
//extension LiveStreamingViewController: WZStatusCallback{
//    func onWZStatus(_ status: WZStatus!) {
//        setStreamBttnUI()
//    }
//
//    func onWZError(_ status: WZStatus!) {
////        self.streamControlBttn.isEnabled = true
////        self.streamControlBgView.alpha = 1
////        self.alert(message: "Internal Live Streaming Error")
//        startStream(tries: 5)
//    }
//
//    func videoFrameWasCaptured(_ imageBuffer: CVImageBuffer, framePresentationTime: CMTime, frameDuration: CMTime) {
//
//    }
//
//
//}
