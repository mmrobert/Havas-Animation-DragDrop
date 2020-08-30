//
//  View+Rotation.swift
//  Havas
//
//  Created by boqian cheng on 2018-05-30.
//  Copyright © 2018 boqiancheng. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func startRotating(duration: Double = 1) {
        let kAnimationKey = "rotation"
        // use layer to animate, not UIView.animate() + transform
        if self.layer.animation(forKey: kAnimationKey) == nil {
            let animate = CABasicAnimation(keyPath: "transform.rotation")
            animate.duration = duration
            animate.repeatCount = Float.infinity
            animate.fromValue = 0.0
            animate.toValue = Float(Double.pi * 2.0)
            self.layer.add(animate, forKey: kAnimationKey)
        }
    }
}
