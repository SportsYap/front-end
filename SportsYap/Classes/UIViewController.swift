//
//  UIViewController.swift
//  Ivy
//
//  Copyright © 2016 Alex Pelletier. All rights reserved.
//

import UIKit
import CoreTelephony
import CallKit

extension UIViewController {
    
    func imageResizeUIKit(image: UIImage, size: CGSize) -> UIImage? {
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, image.scale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    func alert(message: String, title: String = "Oh No!"){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func isOnPhoneCall() -> Bool {
        for call in CXCallObserver().calls {
            if call.hasEnded == false {
                return true
            }
        }
        return false
    }
    
    func showAbuseAlert(postId: Int? = nil){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let  deleteButton = UIAlertAction(title: "Report for Abuse", style: .destructive, handler: { (action) -> Void in
            guard let postId = postId else { return }
            ApiManager.shared.report(post: postId, onSuccess: { deleted in
                if deleted {
                    NotificationCenter.default.post(name: NSNotification.Name(Post.deletePostNotification), object: postId)
                }
            }, onError: voidErr)
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(deleteButton)
        alertController.addAction(cancelButton)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Iimage has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}
