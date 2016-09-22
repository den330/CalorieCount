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
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        if presenting{
            let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
            containerView.addSubview(toView)
            toView.center.y += containerView.bounds.size.height
            toView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: duration-0.1, animations: {
                toView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                toView.center.y -= containerView.bounds.size.height
                }, completion: {_ in
                    transitionContext.completeTransition(true)
            })
        }else{
            let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
            containerView.addSubview(fromView)
            fromView.alpha = 1.0
            UIView.animate(withDuration: duration, animations: {
                fromView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                fromView.center.y -= containerView.bounds.height
                }, completion: { _ in
                transitionContext.completeTransition(true)})
        }
    }
    
}
