//
//  FullscreenRotationAnimator.swift
//  SparkPlayer
//
//  Created by alexeym on 21/02/2018.
//

import UIKit

class FullscreenRotationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let originFrame: CGRect
    private let delegate: SparkPlayerTransitionDelegate

    init(originFrame: CGRect, delegate: SparkPlayerTransitionDelegate) {
        self.originFrame = originFrame
        self.delegate = delegate

        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        /*guard let fromVC = transitionContext.viewController(forKey: .from) else {
            return
        }*/

        guard let toVC = transitionContext.viewController(forKey: .to) as? SparkPlayerController else {
            return
        }

        let fromRect = originFrame
        let toRect = transitionContext.finalFrame(for: toVC)

        let container = transitionContext.containerView

        container.addSubview(toVC.view)

        toVC.view.frame.size = fromRect.size
        let origin = container.convert(fromRect.origin, from: container.window!.screen.coordinateSpace)
        toVC.view.frame.origin = origin

        let duration = transitionDuration(using: transitionContext)

        toVC.view.layoutIfNeeded()

        UIView.animateKeyframes(
            withDuration: duration,
            delay: 0,
            options: .calculationModeLinear,
            animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                    toVC.view.frame.size = toRect.size
                    toVC.view.center = container.center
                    toVC.view.layoutIfNeeded()

                }
            },
            completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                self.delegate.didFullscreenAppear()
        })
    }
}

class FullscreenRotationDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let originFrame: CGRect
    private let delegate: SparkPlayerTransitionDelegate

    init(originFrame: CGRect, delegate: SparkPlayerTransitionDelegate) {
        self.originFrame = originFrame
        self.delegate = delegate

        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) as? SparkPlayerController else {
            return
        }

        let fromRect = transitionContext.initialFrame(for: fromVC)
        let toRect = originFrame

        let container = transitionContext.containerView

        container.addSubview(fromVC.view)
        fromVC.view.frame.size = fromRect.size
        fromVC.view.center = container.center

        fromVC.view.layoutIfNeeded()

        let duration = transitionDuration(using: transitionContext)

        UIView.animateKeyframes(
            withDuration: duration,
            delay: 0,
            options: .calculationModeLinear,
            animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                    fromVC.view.frame.size = toRect.size
                    fromVC.view.frame.origin = container.convert(toRect.origin, from: container.window!.screen.coordinateSpace)
                    fromVC.view.layoutIfNeeded()
                }
            },
            completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                self.delegate.didFullscreenDismissed()
        })
    }
}

