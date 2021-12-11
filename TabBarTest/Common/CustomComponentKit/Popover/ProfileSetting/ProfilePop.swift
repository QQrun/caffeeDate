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
        
    func popAlert() {
        
        if let profilePopView = Bundle.main.loadNibNamed("ProfilePopView", owner: nil, options: nil)?.first as? UIView {
            profilePopView.translatesAutoresizingMaskIntoConstraints = false
            
            let popoverVC = ProfilePopoverViewController()
            popoverVC.tapToDismiss = true
            popoverVC.containerView.addSubview(profilePopView)
            
            profilePopView.topAnchor.constraint(equalTo: popoverVC.containerView.topAnchor).isActive = true
            profilePopView.leadingAnchor.constraint(equalTo: popoverVC.containerView.leadingAnchor).isActive = true
            profilePopView.trailingAnchor.constraint(equalTo: popoverVC.containerView.trailingAnchor).isActive = true
            profilePopView.bottomAnchor.constraint(equalTo: popoverVC.containerView.bottomAnchor).isActive = true
        
            UIApplication.shared.keyWindow?.rootViewController?.present(popoverVC, animated: true, completion: nil)
        }
    
    
    }
}
