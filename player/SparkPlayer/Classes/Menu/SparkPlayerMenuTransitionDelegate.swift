//
//  SparkPlayerMenuTransitionDelegate.swift
//  SparkPlayer
//
//  Created by alexeym on 05/03/2018.
//

import UIKit

class SparkPlayerMenuTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SparkPlayerMenuAnimator(type: .Present)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SparkPlayerMenuAnimator(type: .Present)
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return SparkPlayerMenuPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
