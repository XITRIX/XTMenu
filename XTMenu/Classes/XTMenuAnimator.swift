//
//  XTMenuAnimator.swift
//  UIMenu
//
//  Created by Даниил Виноградов on 29.04.2022.
//

import UIKit

class XTMenuAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var presenting = true
    let duration = 0.0

    init(presenting: Bool) {
        self.presenting = presenting
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        self.duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if self.presenting {
            let animator = self.presentAnimator(using: transitionContext)
            animator.startAnimation()
        } else {
            let animator = self.dismissAnimator(using: transitionContext)
            animator.startAnimation()
        }
    }

    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        if self.presenting {
            return self.presentAnimator(using: transitionContext)
        } else {
            return self.dismissAnimator(using: transitionContext)
        }
    }

    private func presentAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut) {}

        animator.addCompletion { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

        return animator
    }

    private func dismissAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut) {}

        animator.addCompletion { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

        return animator
    }
}
