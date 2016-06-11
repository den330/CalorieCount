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
            toView.center.y += containerView.bounds.size.height
            toView.transform = CGAffineTransformMakeScale(0.5, 0.5)
            UIView.animateWithDuration(duration-0.1, animations: {
                toView.transform = CGAffineTransformMakeScale(1.0, 1.0)
                toView.center.y -= containerView.bounds.size.height
                }, completion: {_ in
                    transitionContext.completeTransition(true)
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
                    fromView.center.y -= containerView.bounds.height
                }}, completion: { _ in
                transitionContext.completeTransition(true)})
        }
    }
    
}
