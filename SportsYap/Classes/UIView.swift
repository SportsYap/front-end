//
//  UIView.swift
//  
//
//  Copyright © 2016 Alex Pelletier. All rights reserved.
//

import UIKit

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var shadowColor: UIColor {
        get {
            return UIColor(cgColor: layer.shadowColor!)
        }
        set {
            layer.shadowColor = newValue.cgColor
        }
    }
    
    @IBInspectable var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }

    
    @IBInspectable var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable var clipToBounds: Bool {
        get {
            return clipsToBounds
        }
        set {
            clipsToBounds = newValue
            layer.masksToBounds = newValue
        }
    }
    
    @IBInspectable var rotation: Double {
        get {
            let radians = atan2f(Float(transform.b), Float(transform.a));
            let degrees = Double(radians) * (180 / Double.pi);
            return (degrees)
        }
        set {
            self.transform = CGAffineTransform(rotationAngle: CGFloat(newValue * Double.pi / 180))
        }
    }
    
    func takeScreenshot(size: CGSize? = nil) -> UIImage {
        // Begin context
        
        // was self.bounds.size before
        
        //UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        if let size = size {
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
            
            // Draw view in that context
            let newBounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            
            //drawHierarchy(in: self.bounds, afterScreenUpdates: true)
            drawHierarchy(in: newBounds, afterScreenUpdates: true)
            
            // And finally, get image
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if (image != nil) {
                return image!
            }
                        
        } else {
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
            
            // Draw view in that context
            drawHierarchy(in: self.bounds, afterScreenUpdates: true)
            
            // And finally, get image
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if (image != nil) {
                return image!
            }
        }
        
        return UIImage()
    }
    
    func renderImage(videoSize: CGSize) -> UIImage {
        /*
        let renderer = UIGraphicsImageRenderer(size: videoSize)
        let image = renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        return image
        */
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        // Draw view in that context
        let inFrame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if (image != nil)
        {
            return image!
        }
        return UIImage()
        
    }
}
