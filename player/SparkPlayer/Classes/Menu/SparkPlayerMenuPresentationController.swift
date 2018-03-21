//
//  SparkPlayerMenuPresentationController.swift
//  SparkPlayer
//
//  Created by alexeym on 05/03/2018.
//

import UIKit

class SparkPlayerMenuPresentationController: UIPresentationController {
    var _fadeView: UIView?
    var fadeView: UIView {
        if let fadeView = self._fadeView {
            return fadeView
        }

        let view = UIView(frame: CGRect(x: 0, y: 0, width: containerView!.bounds.width, height: containerView!.bounds.height))
        view.backgroundColor = UIColor.SparkPlayer.fade
        _fadeView = view

        return view
    }

    func getMenuHeight(_ controller: UIViewController) -> CGFloat {
        if let menuController = presentedViewController as? SparkPlayerMenuViewController {
            return menuController.menuHeight()
        } else {
            return self.containerView?.frame.height ?? 0
        }
    }

    override func presentationTransitionWillBegin() {
        guard
            let view = self.containerView,
            let coordinator = presentingViewController.transitionCoordinator else
        {
            return
        }

        view.backgroundColor = UIColor.clear

        let fadeView = self.fadeView
        fadeView.alpha = 0
        view.addSubview(fadeView)

        view.addSubview(presentedViewController.view)
        presentedViewController.view.frame.size = view.frame.size
        presentedViewController.view.frame.origin.y = getMenuHeight(presentedViewController)

        coordinator.animate(alongsideTransition: { (context) in
            fadeView.alpha = 1
            self.presentedViewController.view.frame.origin.y = 0
        }, completion: nil)
    }

    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentingViewController.transitionCoordinator else {
            return
        }
        
        coordinator.animate(alongsideTransition: { (context) in
            self.fadeView.alpha = 0
            self.presentedViewController.view.frame.origin.y = self.getMenuHeight(self.presentedViewController)
        }, completion: nil)
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        return CGRect(x: 0, y: 0, width: containerView!.bounds.width, height: containerView!.bounds.height)
}
}
