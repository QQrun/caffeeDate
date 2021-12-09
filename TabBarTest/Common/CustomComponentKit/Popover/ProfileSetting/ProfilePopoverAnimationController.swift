//
//  SSPopoverAnimationController.swift
//  StockSelect
//
//  Created by Tom on 2020/1/10.
//

import UIKit

class ProfilePopoverAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    private var presenting: Bool
    
    public var duration: TimeInterval = 0.3
    public var delay: TimeInterval = 0.0
    public var springWithDamping: CGFloat = 0.8
    public var springVelocity: CGFloat = 2.0
    
    init(presenting: Bool) {
        self.presenting = presenting
        
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if presenting {
            guard
                let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
                let toView = transitionContext.view( forKey: UITransitionContextViewKey.to)
                else {
                    return
            }
            
            let containerView = transitionContext.containerView
            toView.frame = transitionContext.finalFrame(for: toViewController)
            toView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            containerView.addSubview(toView)
            
            UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: springWithDamping, initialSpringVelocity: springVelocity, options: .curveEaseInOut, animations: {
                toView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }) { (finished) in
                transitionContext.completeTransition(finished)
            }
        }
        else {
            guard let fromView = transitionContext.view( forKey: UITransitionContextViewKey.from) else {
                return
            }
            
            UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut, animations: {
                fromView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                fromView.alpha = 0.0
            }) { (finished) in
                fromView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                fromView.alpha = 1.0
                transitionContext.completeTransition(finished)
            }
        }
    }
}
