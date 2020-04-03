//
//  InstaZoom.swift
//  InstaZoom
//
//  Created by Paul-Emmanuel on 04/01/17.
//  Copyright © 2017 rstudio. All rights reserved.
//
import UIKit

// MARK: - UIView extension to easily replicate Instagram zooming feature
public extension UIView {
    /// Key for associated object
    private struct AssociatedKeys {
        static var ImagePinchKey: Int8 = 0
        static var ImagePinchGestureKey: Int8 = 1
        static var ImagePanGestureKey: Int8 = 2
        static var ImageScaleKey: Int8 = 3
    }
    
    /// The image should zoom on Pinch
    public var isPinchable: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.ImagePinchKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.ImagePinchKey, newValue, .OBJC_ASSOCIATION_RETAIN)
            
            if pinchGesture == nil {
                inititialize()
            }
            
            if newValue {
                isUserInteractionEnabled = true
                pinchGesture.map { addGestureRecognizer($0) }
                panGesture.map { addGestureRecognizer($0) }
            } else {
                pinchGesture.map { removeGestureRecognizer($0) }
                panGesture.map { removeGestureRecognizer($0) }
            }
        }
    }
    
    /// Associated image's pinch gesture
    private var pinchGesture: UIPinchGestureRecognizer? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.ImagePinchGestureKey) as? UIPinchGestureRecognizer
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.ImagePinchGestureKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    /// Associated image's pan gesture
    private var panGesture: UIPanGestureRecognizer? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.ImagePanGestureKey) as? UIPanGestureRecognizer
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.ImagePanGestureKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    /// Associated image's scale -- there might be no need
    private var scale: CGFloat {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.ImageScaleKey) as? CGFloat) ?? 1.0
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.ImageScaleKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    
    /// Initialize pinch & pan gestures
    private func inititialize() {
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(viewPinched(_:)))
        pinchGesture?.delegate = self
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(viewPanned(_:)))
        panGesture?.delegate = self
    }
    
    /// Perform the pinch to zoom if needed.
    ///
    /// - Parameter sender: UIPinvhGestureRecognizer
    @objc private func viewPinched(_ pinch: UIPinchGestureRecognizer) {
        if pinch.scale >= 1.0 {
            scale = pinch.scale
            transform(withTranslation: .zero)
        }
        
        if pinch.state != .ended { return }
        
        reset()
    }
    
    /// Perform the panning if needed
    ///
    /// - Parameter sender: UIPanGestureRecognizer
    @objc private func viewPanned(_ pan: UIPanGestureRecognizer) {
        if scale > 1.0 {
            transform(withTranslation: pan.translation(in: self))
        }
        
        if pan.state != .ended { return }
        
        reset()
    }
    
    /// Set the image back to it's initial state.
    private func reset() {
        scale = 1.0
        UIView.animate(withDuration: 0.3) {
            self.transform = .identity
        }
    }
    
    /// Will transform the image with the appropriate
    /// scale or translation.
    ///
    /// Parameter translation: CGPoint
    private func transform(withTranslation translation: CGPoint) {
        var transform = CATransform3DIdentity
        transform = CATransform3DScale(transform, scale, scale, 1.01)
        transform = CATransform3DTranslate(transform, translation.x, translation.y, 0)
        layer.transform = transform
    }
}

extension UIView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
