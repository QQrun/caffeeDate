//
//  SSPopoverPresentationManager.swift
//
//  Created by Tom on 2020/1/10.
//

import UIKit

class ProfilePopoverPresentationManager: NSObject {

}

extension ProfilePopoverPresentationManager: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = ProfilePopoverPresentationController(presentedViewController: presented, presenting: presenting)
        return presentationController
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ProfilePopoverAnimationController(presenting: true)
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ProfilePopoverAnimationController(presenting: false)
    }
}
