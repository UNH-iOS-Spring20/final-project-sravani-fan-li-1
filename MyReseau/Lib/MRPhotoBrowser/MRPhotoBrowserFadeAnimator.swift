//
//  MRPhotoBrowserFadeAnimator.swift
//  MRPhotoBrowserFadeAnimator
//
//  Created by biz on 2020/4/25.
//  Copyright © 2020 biz. All rights reserved.
//

import UIKit

open class MRPhotoBrowserFadeAnimator: NSObject, MRPhotoBrowserAnimatedTransitioning {
    
    open var showDuration: TimeInterval = 0.25
    
    open var dismissDuration: TimeInterval = 0.25
    
    public var isNavigationAnimation: Bool = false
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return isForShow ? showDuration : dismissDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let browser = photoBrowser else {
            transitionContext.completeTransition(false)
            return
        }
        if isForShow {
            browser.maskView.alpha = 0
            browser.browserView.alpha = 0
            if let toView = transitionContext.view(forKey: .to) {
                transitionContext.containerView.addSubview(toView)
            }
        } else {
            if isNavigationAnimation,
                let fromView = transitionContext.view(forKey: .from),
                let toView = transitionContext.view(forKey: .to) {
                transitionContext.containerView.insertSubview(toView, belowSubview: fromView)
            }
        }
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            browser.maskView.alpha = self.isForShow ? 1.0 : 0
            browser.browserView.alpha = self.isForShow ? 1.0 : 0
        }) { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
