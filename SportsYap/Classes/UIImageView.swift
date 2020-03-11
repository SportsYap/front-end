
//
//  UIImageView.swift
//  Ivy
//
//  Copyright © 2016 Alex Pelletier. All rights reserved.
//

import UIKit
import Alamofire

extension UIImage {
    
    class func imageWithColor(_ color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
}

extension UIImageView {
    public func imageFromUrl(url: URL) {
        self.imageFromUrl(url: url) { (_) in }
    }
    
    public func imageFromUrl(url: URL, callback: @escaping (_ success: Bool) -> Void){
        self.image = nil
        let key = url.path.replacingOccurrences(of: "/", with: "_")
        if let img = ImageFileManager.shared.getImage(key: key){
            self.image = img
            callback(true)
        }else{
            Alamofire.request(url).responseData { (data) in
                if let imgData = data.data, let image = UIImage(data: imgData){
                    self.image = image
                    callback(true)
                    ImageFileManager.shared.saveImage(image: image, key: key)
                }else{
                    callback(false)
                }
            }
        }
    }
    
    static func preloadImageFromUrl(url: URL){
        UIImageView().imageFromUrl(url: url) { (_) in }
    }
}
