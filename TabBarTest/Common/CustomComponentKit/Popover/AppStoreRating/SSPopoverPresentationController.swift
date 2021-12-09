//
//  SSPopoverPresentationController.swift
//
//  Created by Tom on 2020/1/10.
//

import UIKit

class SSPopoverPresentationController: UIPresentationController {
    var dimmingView: UIView!
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        setupDimmingView()
    }
    
    // 顯示轉場即將開始
    override func presentationTransitionWillBegin() {
        containerView?.insertSubview(dimmingView, at: 0)
        dimmingView.frame = containerView!.bounds
        
        guard let coordinator = presentingViewController.transitionCoordinator else {
            dimmingView.alpha = 1.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        })
    }
    
    // 消失轉場即將開始
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
        })
    }
    
    // 大小位置
    override var frameOfPresentedViewInContainerView: CGRect {
        let size = presentedViewController.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        presentedViewController.view.translatesAutoresizingMaskIntoConstraints = true
        return CGRect(origin: CGPoint(x: (UIScreen.main.bounds.size.width - size.width)*0.5, y: (UIScreen.main.bounds.size.height - size.height)*0.5), size: size)
    }
}

private extension SSPopoverPresentationController {
    func setupDimmingView() {
        dimmingView = UIView()
        dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        dimmingView.alpha = 0.0
        
        if let popoverVC = presentedViewController as? SSPopoverViewController {
            if popoverVC.tapToDismiss {
                let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
                dimmingView.addGestureRecognizer(recognizer)
            }
        }
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        if let popoverVC = presentedViewController as? SSPopoverViewController {
            if popoverVC.backDropAction != nil {
                popoverVC.backDropAction?()
            }
            else {
                presentedViewController.dismiss(animated: true)
            }
        }
    }
}
