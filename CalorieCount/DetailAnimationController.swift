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
    
    let duration = 0.5
    var presenting = true
    var originFrame = CGRect.zero
    var count = 0
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView()!
        if presenting{
            let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
            containerView.addSubview(toView)
            toView.alpha = 0.0
            UIView.animateWithDuration(duration, animations: {
                toView.alpha = 1.0
                }, completion: {_ in
                    transitionContext.completeTransition(true)})
        }else{
            count += 1
            let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
            containerView.addSubview(fromView)
            fromView.alpha = 1.0
            UIView.animateWithDuration(duration, animations: {
                if self.count % 2 == 0{
                    fromView.center.x += containerView.bounds.width
                }else{
                    fromView.center.x -= containerView.bounds.width
                }}, completion: { _ in
                transitionContext.completeTransition(true)})
        }
    }
    
}
