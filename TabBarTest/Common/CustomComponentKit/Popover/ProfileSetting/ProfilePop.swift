//
//  AppStoreRating.swift
//  StockSelect
//
//  Created by 金融產規部-梁雅軒 on 2020/12/17.
//  Copyright © 2020 mitake. All rights reserved.
//

import Foundation
import StoreKit
import Firebase

class ProfilePop {
    static let share = ProfilePop()
        
    private func popAlert(_ formType: AppStoreRatingFromType) {
        if UserSetting.isRatinged {
            return
        }
        
        if let appStoreRatingAlertView = Bundle.main.loadNibNamed("ProfilePopView", owner: nil, options: nil)?.first as? UIView {
            appStoreRatingAlertView.translatesAutoresizingMaskIntoConstraints = false
            
            let popoverVC = ProfilePopoverViewController()
            popoverVC.tapToDismiss = false
            popoverVC.containerView.addSubview(appStoreRatingAlertView)
            
            appStoreRatingAlertView.topAnchor.constraint(equalTo: popoverVC.containerView.topAnchor).isActive = true
            appStoreRatingAlertView.leadingAnchor.constraint(equalTo: popoverVC.containerView.leadingAnchor).isActive = true
            appStoreRatingAlertView.trailingAnchor.constraint(equalTo: popoverVC.containerView.trailingAnchor).isActive = true
            appStoreRatingAlertView.bottomAnchor.constraint(equalTo: popoverVC.containerView.bottomAnchor).isActive = true
            
            popoverVC.addAction(ProfilePopoverAction(title: "下次再說", style: .cancel, handler: { _ in
                popoverVC.dismiss(animated: true)
                Analytics.logEvent("評分_\(formType.rawValue)_拒絕", parameters:nil)
                UserSetting.isRejectRating = true
            }))
            
            popoverVC.addAction(ProfilePopoverAction(title: "給予鼓勵", style: .default, handler: { _ in
                popoverVC.dismiss(animated: true)
                SKStoreReviewController.requestReview()
                UserSetting.isRatinged = true
                Analytics.logEvent("評分_\(formType.rawValue)_接受", parameters:nil)
            }))
            
            UIApplication.shared.keyWindow?.rootViewController?.present(popoverVC, animated: true, completion: nil)
        }
    }
}
