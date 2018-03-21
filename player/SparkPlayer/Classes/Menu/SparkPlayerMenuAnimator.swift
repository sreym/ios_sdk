//
//  SparkPlayerMenuAnimator.swift
//  SparkPlayer
//
//  Created by alexeym on 05/03/2018.
//

import UIKit

enum MenuTransitionDirection {
    case Present
    case Dismiss
}

class SparkPlayerMenuAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let direction: MenuTransitionDirection

    init(type: MenuTransitionDirection) {
        direction = type

        super.init()
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func isPresenting() -> Bool {
        return direction == .Present
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: [.curveEaseOut], animations: {
            // animations are implemented in SparkPlayerMenuPresentationController
        }) { (completed) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }

}
