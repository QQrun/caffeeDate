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
import Alamofire

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
            
            
            
            //照片
            (profilePopView as! ProfilePopView).loadingView.contentMode = .scaleAspectFit
            if UserSetting.userGender == 0{
                (profilePopView as! ProfilePopView).loadingView.image = UIImage(named: "girlIcon")?.withRenderingMode(.alwaysTemplate)
            }else{
                (profilePopView as! ProfilePopView).loadingView.image = UIImage(named: "boyIcon")?.withRenderingMode(.alwaysTemplate)
            }
            
            (profilePopView as! ProfilePopView).loadingView.tintColor = .primary()
            
            
            (profilePopView as! ProfilePopView).photoView.clipsToBounds = true
            (profilePopView as! ProfilePopView).photoView.layer.cornerRadius = 17
            if UserSetting.userPhotosUrl != nil{
                (profilePopView as! ProfilePopView).photoView.contentMode = .scaleAspectFill
                (profilePopView as! ProfilePopView).photoView.alpha = 0
                AF.request(UserSetting.userPhotosUrl[0]).response { (response) in
                    guard let data = response.data, let image = UIImage(data: data)
                    else { return }
                    (profilePopView as! ProfilePopView).photoView.image = image
                    UIView.animate(withDuration: 0.4, animations:{
                        (profilePopView as! ProfilePopView).photoView.alpha = 1
                        (profilePopView as! ProfilePopView).loadingView.alpha = 0
                    })
                }
            }
            
            
            
            //名稱與年齡
            let birthdayFormatter = DateFormatter()
            birthdayFormatter.dateFormat = "yyyy/MM/dd"
            let currentTime = Date()
            let birthDayDate = birthdayFormatter.date(from: UserSetting.userBirthDay)
            let age = currentTime.years(sinceDate: birthDayDate!) ?? 0
            (profilePopView as! ProfilePopView).nameWithAge.text = "\(UserSetting.userName)" + " " + "\(age)"
            
            //自介
            (profilePopView as! ProfilePopView).introduction.text =
            "\(UserSetting.userSelfIntroduction)"
            
            
            (profilePopView as! ProfilePopView).editProfileBtn.layer.cornerRadius = 2.5
            (profilePopView as! ProfilePopView).editShopBtn.layer.cornerRadius = 2.5
            (profilePopView as! ProfilePopView).reportBtn.layer.cornerRadius = 2.5
            (profilePopView as! ProfilePopView).logoutBtn.layer.cornerRadius = 2.5
            
        }
    
    
    }
}
