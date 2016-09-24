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
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({ [unowned self] in
        guard let nextFocusedView = context.nextFocusedView else { return }
        if nextFocusedView == self {
            self.textLabel.transform = CGAffineTransformMakeScale(1.1, 1.1)
            self.imageView.transform = CGAffineTransformMakeScale(1.2, 1.2)
            self.becomeFocusedUsingAnimationCoordinator(coordinator)
            self.textLabel.addParallaxMotionEffects()
            self.imageView.addParallaxMotionEffects()
        }
        else {
            self.textLabel.transform = CGAffineTransformMakeScale(1, 1)
            self.imageView.transform = CGAffineTransformMakeScale(1, 1)
            self.resignFocusUsingAnimationCoordinator(coordinator)
            self.textLabel.motionEffects = []
            self.imageView.motionEffects = []
            }
            }, completion: nil)
    }
    
    func becomeFocusedUsingAnimationCoordinator(coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({ () -> Void in
            
            self.layer.shadowColor = UIColor.blackColor().CGColor
            self.layer.shadowOffset = CGSizeMake(10, 10)
            self.layer.shadowOpacity = 0.8
            self.layer.shadowRadius = 20
        }) { () -> Void in
        }
    }
    
    func resignFocusUsingAnimationCoordinator(coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({ () -> Void in
            
            self.layer.shadowColor = UIColor.blackColor().CGColor
            self.layer.shadowOffset = CGSizeMake(10, 10)
            self.layer.shadowOpacity = 0
            self.layer.shadowRadius = 0
        }) { () -> Void in
        }
    }

}

extension UIView {
    func addParallaxMotionEffects(tiltValue : CGFloat = 0.25, panValue: CGFloat = 5) {
        var xTilt = UIInterpolatingMotionEffect()
        var yTilt = UIInterpolatingMotionEffect()
        var xPan = UIInterpolatingMotionEffect()
        var yPan = UIInterpolatingMotionEffect()
        let motionGroup = UIMotionEffectGroup()
        xTilt = UIInterpolatingMotionEffect(keyPath:
            "layer.transform.rotation.y", type: .TiltAlongHorizontalAxis)
        xTilt.minimumRelativeValue = -tiltValue
        xTilt.maximumRelativeValue = tiltValue
        yTilt = UIInterpolatingMotionEffect(keyPath:
            "layer.transform.rotation.x", type: .TiltAlongVerticalAxis)
        yTilt.minimumRelativeValue = -tiltValue
        yTilt.maximumRelativeValue = tiltValue
        xPan = UIInterpolatingMotionEffect(keyPath: "center.x", type: .TiltAlongHorizontalAxis)
        xPan.minimumRelativeValue = -panValue
        xPan.maximumRelativeValue = panValue
        yPan = UIInterpolatingMotionEffect(keyPath: "center.y", type: .TiltAlongVerticalAxis)
        yPan.minimumRelativeValue = -panValue
        yPan.maximumRelativeValue = panValue
        motionGroup.motionEffects = [xTilt, yTilt, xPan, yPan]
        self.addMotionEffect( motionGroup )
    }
    
}

extension UIImageView {
    func roundCornersForAspectFit(radius: CGFloat)
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
            mask.path = path.CGPath
            self.layer.mask = mask
        }
    }
}