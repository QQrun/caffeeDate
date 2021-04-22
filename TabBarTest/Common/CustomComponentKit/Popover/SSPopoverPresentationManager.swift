//
//  SSPopoverPresentationManager.swift
//
//  Created by Tom on 2020/1/10.
//

import UIKit

class SSPopoverPresentationManager: NSObject {

}

extension SSPopoverPresentationManager: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = SSPopoverPresentationController(presentedViewController: presented, presenting: presenting)
        return presentationController
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SSPopoverAnimationController(presenting: true)
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SSPopoverAnimationController(presenting: false)
    }
}
