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

enum AppStoreRatingFromType: String {
    case Second = "第二次開啟"
    case Fifth = "第五次開啟"
}
class AppStoreRating {
    static let share = AppStoreRating()
    
    func listener() {
        if UserSetting.isRatinged {
            return
        }
        var sec = 0
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] (timer) in
            sec += 1
            //使用者超過一分鐘一次後打開20秒
            if UserSetting.userMore1MinCount == 1 && sec == 20 {
                // 沒有評論過 而且 沒有拒絕過
                if !UserSetting.isRatinged && !UserSetting.isRejectRating {
                    popAlert(.Second)
                }
            }
            if sec >= 60 {
                timer.invalidate()
                UserSetting.userMore1MinCount += 1
                //使用者超過一分鐘五次且拒絕過
                if (UserSetting.userMore1MinCount == 5) && UserSetting.isRejectRating{
                    popAlert(.Fifth)
                }
            }
        }
    }
    
    private func popAlert(_ formType: AppStoreRatingFromType) {
        if UserSetting.isRatinged {
            return
        }
        
        if let appStoreRatingAlertView = Bundle.main.loadNibNamed("AppStoreRatingAlertView", owner: nil, options: nil)?.first as? UIView {
            appStoreRatingAlertView.translatesAutoresizingMaskIntoConstraints = false
            

            (appStoreRatingAlertView as! AppStoreRatingAlertView).commitIcon.image = UIImage(named: "commitIcon")?.withRenderingMode(.alwaysTemplate)
            
            (appStoreRatingAlertView as! AppStoreRatingAlertView).commitIcon.tintColor = .primary()
            
            let popoverVC = SSPopoverViewController()
            popoverVC.tapToDismiss = false
            popoverVC.containerView.addSubview(appStoreRatingAlertView)
            
            appStoreRatingAlertView.topAnchor.constraint(equalTo: popoverVC.containerView.topAnchor).isActive = true
            appStoreRatingAlertView.leadingAnchor.constraint(equalTo: popoverVC.containerView.leadingAnchor).isActive = true
            appStoreRatingAlertView.trailingAnchor.constraint(equalTo: popoverVC.containerView.trailingAnchor).isActive = true
            appStoreRatingAlertView.bottomAnchor.constraint(equalTo: popoverVC.containerView.bottomAnchor).isActive = true
            
            popoverVC.addAction(SSPopoverAction(title: "下次再說", style: .cancel, handler: { _ in
                popoverVC.dismiss(animated: true)
                Analytics.logEvent("評分_\(formType.rawValue)_拒絕", parameters:nil)
                UserSetting.isRejectRating = true
            }))
            
            popoverVC.addAction(SSPopoverAction(title: "給予鼓勵", style: .default, handler: { _ in
                popoverVC.dismiss(animated: true)
                SKStoreReviewController.requestReview()
                UserSetting.isRatinged = true
                Analytics.logEvent("評分_\(formType.rawValue)_接受", parameters:nil)
            }))
            
            UIApplication.shared.keyWindow?.rootViewController?.present(popoverVC, animated: true, completion: nil)
        }
    }
}
