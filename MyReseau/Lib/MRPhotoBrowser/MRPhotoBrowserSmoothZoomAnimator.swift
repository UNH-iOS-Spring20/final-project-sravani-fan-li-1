//
//  MRPhotoBrowserSmoothZoomAnimator.swift
//  MRPhotoBrowser
//
//  Created by biz on 2020/4/6.
//  Copyright © 2020 biz. All rights reserved.
//

import UIKit

/// 更丝滑的Zoom动画
open class MRPhotoBrowserSmoothZoomAnimator: NSObject, MRPhotoBrowserAnimatedTransitioning {
    
    open var showDuration: TimeInterval = 0.25
    
    open var dismissDuration: TimeInterval = 0.25
    
    open var isNavigationAnimation = false
    
    public typealias TransitionViewAndFrame = (transitionView: UIView, thumbnailFrame: CGRect)
    public typealias TransitionViewAndFrameProvider = (_ index: Int, _ destinationView: UIView) -> TransitionViewAndFrame?
    
    /// 获取转场缩放的视图与前置Frame
    open var transitionViewAndFrameProvider: TransitionViewAndFrameProvider = { _, _ in return nil }
    
    /// 替补的动画方案
    open lazy var substituteAnimator: MRPhotoBrowserAnimatedTransitioning = MRPhotoBrowserFadeAnimator()
    
    public init(transitionViewAndFrame: @escaping TransitionViewAndFrameProvider) {
        transitionViewAndFrameProvider = transitionViewAndFrame
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return isForShow ? showDuration : dismissDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isForShow {
            playShowAnimation(context: transitionContext)
        } else {
            playDismissAnimation(context: transitionContext)
        }
    }
    
    private func playShowAnimation(context: UIViewControllerContextTransitioning) {
        guard let browser = photoBrowser, let toView = context.view(forKey: .to) else {
            return
        }
        if isNavigationAnimation, let fromView = context.view(forKey: .from), let fromViewSnapshot = snapshot(with: fromView) {
            toView.insertSubview(fromViewSnapshot, at: 0)
        }
        context.containerView.addSubview(toView)
        
        guard let (transitionView, thumbnailFrame, destinationFrame) = transitionViewAndFrames(with: browser) else {
            // 转为执行替补动画
            substituteAnimator.isForShow = isForShow
            substituteAnimator.photoBrowser = photoBrowser
            substituteAnimator.animateTransition(using: context)
            return
        }
        browser.maskView.alpha = 0
        browser.browserView.isHidden = true
        transitionView.frame = thumbnailFrame
        context.containerView.addSubview(transitionView)
        UIView.animate(withDuration: showDuration, animations: {
            browser.maskView.alpha = 1.0
            transitionView.frame = destinationFrame
        }) { _ in
            browser.browserView.isHidden = false
            toView.insertSubview(browser.maskView, belowSubview: browser.browserView)
            transitionView.removeFromSuperview()
            context.completeTransition(!context.transitionWasCancelled)
        }
    }
    
    private func playDismissAnimation(context: UIViewControllerContextTransitioning) {
        guard let browser = photoBrowser else {
            return
        }
        guard let (transitionView, thumbnailFrame, destinationFrame) = transitionViewAndFrames(with: browser) else {
            // 转为执行替补动画
            substituteAnimator.isForShow = isForShow
            substituteAnimator.photoBrowser = photoBrowser
            substituteAnimator.animateTransition(using: context)
            return
        }
        browser.browserView.isHidden = true
        transitionView.frame = destinationFrame
        context.containerView.addSubview(transitionView)
        UIView.animate(withDuration: showDuration, animations: {
            browser.maskView.alpha = 0
            transitionView.frame = thumbnailFrame
        }) { _ in
            if let toView = context.view(forKey: .to) {
                context.containerView.addSubview(toView)
            }
            transitionView.removeFromSuperview()
            context.completeTransition(!context.transitionWasCancelled)
        }
    }
    
    private func transitionViewAndFrames(with browser: MRPhotoBrowser) -> (UIView, CGRect, CGRect)? {
        let browserView = browser.browserView
        let destinationView = browser.view!
        guard let transitionContext = transitionViewAndFrameProvider(browser.pageIndex, destinationView) else {
            return nil
        }
        guard let cell = browserView.visibleCells[browserView.pageIndex] as? MRPhotoBrowserZoomSupportedCell else {
            return nil
        }
        let showContentView = cell.showContentView
        let destinationFrame = showContentView.convert(showContentView.bounds, to: destinationView)
        return (transitionContext.transitionView, transitionContext.thumbnailFrame, destinationFrame)
    }
}
