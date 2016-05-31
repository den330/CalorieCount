//
//  DetailAnimationController.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/5/30.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import Foundation
import UIKit

class DetailAnimationController: NSObject, UIViewControllerAnimatedTransitioning{
    
    let duration = 0.3
    var presenting = true
    var count = 0
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView()!
        if presenting{
            let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
            containerView.addSubview(toView)
            toView.transform = CGAffineTransformMakeScale(0.4, 0.4)
            UIView.animateKeyframesWithDuration(transitionDuration(transitionContext), delay: 0, options: .CalculationModeCubic, animations: {
                UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.334, animations: {
                    toView.transform = CGAffineTransformMakeScale(1.3, 1.3)
                })
                UIView.addKeyframeWithRelativeStartTime(0.334, relativeDuration: 0.333, animations: {
                    toView.transform = CGAffineTransformMakeScale(0.7, 0.7)
                })
                UIView.addKeyframeWithRelativeStartTime(0.666, relativeDuration: 0.333, animations: {
                    toView.transform = CGAffineTransformMakeScale(1.0, 1.0)
                })
                }, completion: {
                    finished in transitionContext.completeTransition(finished)
            })
        }else{
            if count == 3{
                count = 0
            }
            count += 1
            let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
            containerView.addSubview(fromView)
            fromView.alpha = 1.0
            UIView.animateWithDuration(duration, animations: {
                fromView.transform = CGAffineTransformMakeScale(0.5, 0.5)
                if self.count == 1{
                    fromView.center.x += containerView.bounds.width
                }else if self.count == 2{
                    fromView.center.x -= containerView.bounds.width
                }else{
                    fromView.alpha = 0.0
                }}, completion: { _ in
                transitionContext.completeTransition(true)})
        }
    }
    
}
