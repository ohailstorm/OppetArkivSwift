//
//  CollectionViewCell.swift
//  OppetArkivSwift
//
//  Created by Oscar Hallström on 2016-09-23.
//  Copyright © 2016 Oscar Hallström. All rights reserved.
//

import UIKit

class EpisodeCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet var textLabel: UILabel!
    
    @IBOutlet var imageView: UIImageView!
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({ [unowned self] in
        guard let nextFocusedView = context.nextFocusedView else { return }
        if nextFocusedView == self {
            self.textLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.imageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.becomeFocusedUsingAnimationCoordinator(coordinator)
            self.textLabel.addParallaxMotionEffects()
            self.imageView.addParallaxMotionEffects()
        }
        else {
            self.textLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.resignFocusUsingAnimationCoordinator(coordinator)
            self.textLabel.motionEffects = []
            self.imageView.motionEffects = []
            }
            }, completion: nil)
    }
    
    func becomeFocusedUsingAnimationCoordinator(_ coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({ () -> Void in
            
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOffset = CGSize(width: 10, height: 10)
            self.layer.shadowOpacity = 0.8
            self.layer.shadowRadius = 20
        }) { () -> Void in
        }
    }
    
    func resignFocusUsingAnimationCoordinator(_ coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({ () -> Void in
            
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOffset = CGSize(width: 10, height: 10)
            self.layer.shadowOpacity = 0
            self.layer.shadowRadius = 0
        }) { () -> Void in
        }
    }

}

extension UIView {
    func addParallaxMotionEffects(_ tiltValue : CGFloat = 0.25, panValue: CGFloat = 5) {
        var xTilt = UIInterpolatingMotionEffect()
        var yTilt = UIInterpolatingMotionEffect()
        var xPan = UIInterpolatingMotionEffect()
        var yPan = UIInterpolatingMotionEffect()
        let motionGroup = UIMotionEffectGroup()
        xTilt = UIInterpolatingMotionEffect(keyPath:
            "layer.transform.rotation.y", type: .tiltAlongHorizontalAxis)
        xTilt.minimumRelativeValue = -tiltValue
        xTilt.maximumRelativeValue = tiltValue
        yTilt = UIInterpolatingMotionEffect(keyPath:
            "layer.transform.rotation.x", type: .tiltAlongVerticalAxis)
        yTilt.minimumRelativeValue = -tiltValue
        yTilt.maximumRelativeValue = tiltValue
        xPan = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        xPan.minimumRelativeValue = -panValue
        xPan.maximumRelativeValue = panValue
        yPan = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        yPan.minimumRelativeValue = -panValue
        yPan.maximumRelativeValue = panValue
        motionGroup.motionEffects = [xTilt, yTilt, xPan, yPan]
        self.addMotionEffect( motionGroup )
    }
    
}

extension UIImageView {
    func roundCornersForAspectFit(_ radius: CGFloat)
    {
        if let image = self.image {
            
            //calculate drawingRect
            let boundsScale = self.bounds.size.width / self.bounds.size.height
            let imageScale = image.size.width / image.size.height
            
            var drawingRect : CGRect = self.bounds
            
            if boundsScale > imageScale {
                drawingRect.size.width =  drawingRect.size.height * imageScale
                drawingRect.origin.x = (self.bounds.size.width - drawingRect.size.width) / 2
            }else{
                drawingRect.size.height = drawingRect.size.width / imageScale
                drawingRect.origin.y = (self.bounds.size.height - drawingRect.size.height) / 2
            }
            let path = UIBezierPath(roundedRect: drawingRect, cornerRadius: radius)
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }
}
