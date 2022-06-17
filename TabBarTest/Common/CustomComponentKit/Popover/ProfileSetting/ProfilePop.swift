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
import MessageUI

class ProfilePop {
    
    static let share = ProfilePop()
    
    static var actionSheetKit_LogOut = ActionSheetKit()
    
    static let popoverVC = ProfilePopoverViewController()
    
    static let viewDelegate : SettingViewDelegate? = CoordinatorAndControllerInstanceHelper.rootCoordinator
    
    
    func popAlert() {
        
        
        if let profilePopView = Bundle.main.loadNibNamed("ProfilePopView", owner: nil, options: nil)?.first as? UIView {
            
            
            profilePopView.translatesAutoresizingMaskIntoConstraints = false
            
            
            ProfilePop.popoverVC.tapToDismiss = true
            ProfilePop.popoverVC.containerView.addSubview(profilePopView)

            profilePopView.topAnchor.constraint(equalTo: ProfilePop.popoverVC.containerView.topAnchor).isActive = true
            profilePopView.leadingAnchor.constraint(equalTo: ProfilePop.popoverVC.containerView.leadingAnchor).isActive = true
            profilePopView.trailingAnchor.constraint(equalTo: ProfilePop.popoverVC.containerView.trailingAnchor).isActive = true
            profilePopView.bottomAnchor.constraint(equalTo: ProfilePop.popoverVC.containerView.bottomAnchor).isActive = true
        
            
            UIApplication.shared.keyWindow?.rootViewController?.present(ProfilePop.popoverVC, animated: true, completion: nil)
            
            
            //照片
            (profilePopView as! ProfilePopView).loadingView.contentMode = .scaleAspectFit
            if UserSetting.userGender == 0{
                (profilePopView as! ProfilePopView).loadingView.image = UIImage(named: "girlIcon")?.withRenderingMode(.alwaysTemplate)
            }else{
                (profilePopView as! ProfilePopView).loadingView.image = UIImage(named: "boyIcon")?.withRenderingMode(.alwaysTemplate)
            }
            
            (profilePopView as! ProfilePopView).loadingView.tintColor = .lightGray
            
            
            (profilePopView as! ProfilePopView).photoView.clipsToBounds = true
            (profilePopView as! ProfilePopView).photoView.layer.cornerRadius = 17
            if UserSetting.userPhotosUrl != nil{
                (profilePopView as! ProfilePopView).photoView.contentMode = .scaleAspectFill
                (profilePopView as! ProfilePopView).photoView.alpha = 0
                
                if(UserSetting.userPhotosUrl.count > 0){
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
            }
            
            
            
            //名稱與年齡
            let birthdayFormatter = DateFormatter()
            birthdayFormatter.dateFormat = "yyyy/MM/dd"
            let currentTime = Date()
            let birthDayDate = birthdayFormatter.date(from: UserSetting.userBirthDay)
            let age = currentTime.years(sinceDate: birthDayDate!) ?? 0
            (profilePopView as! ProfilePopView).nameWithAge.text = "\(UserSetting.userName)" + "  " + "\(age)"
            
            //自介
            (profilePopView as! ProfilePopView).introduction.text =
            "\(UserSetting.userSelfIntroduction)"
            
            
            (profilePopView as! ProfilePopView).goProfilePageBtn.addTarget(self, action: #selector(goProfilePageBtnAct), for: .touchUpInside)
            (profilePopView as! ProfilePopView).goProfilePageBtn.setTitle("", for: .normal)
            
            (profilePopView as! ProfilePopView).editProfileBtn.layer.cornerRadius = 2.5
            (profilePopView as! ProfilePopView).editProfileBtn.addTarget(self, action: #selector(editProfileBtnAct), for: .touchUpInside)
            
            //攤販按鈕
            (profilePopView as! ProfilePopView).editShopBtn.layer.cornerRadius = 2.5
            (profilePopView as! ProfilePopView).editShopBtn.addTarget(self, action: #selector(editShopBtnAct), for: .touchUpInside)
   
#if VERYINCORRECT
            (profilePopView as! ProfilePopView).editShopBtn.isHidden = true
#endif
            
            //回報按鈕
            (profilePopView as! ProfilePopView).reportBtn.layer.cornerRadius = 2.5
            (profilePopView as! ProfilePopView).reportBtn.addTarget(self, action: #selector(reportBtnAct), for: .touchUpInside)
            
            //登出按鈕
            ProfilePop.actionSheetKit_LogOut.creatActionSheet(containerView: (UIApplication.shared.keyWindow?.rootViewController?.view)!, actionSheetText: ["取消","確定登出"])
            ProfilePop.actionSheetKit_LogOut.getActionSheetBtn(i: 1)!.addTarget(self, action: #selector(actionSheetConfirmLogOutBtnAct), for: .touchUpInside)
            
            
            (profilePopView as! ProfilePopView).logoutBtn.layer.cornerRadius = 2.5
            (profilePopView as! ProfilePopView).logoutBtn.addTarget(self, action: #selector(logOutBtnAct), for: .touchUpInside)
            
        }
    
    
    }
    
    
    @objc fileprivate func editProfileBtnAct(){
        ProfilePop.popoverVC.dismiss(animated: true, completion: nil)
        ProfilePop.viewDelegate?.gotoProfileEditView()
    }
    
    @objc fileprivate func editShopBtnAct(){
        ProfilePop.popoverVC.dismiss(animated: true, completion: nil)
        ProfilePop.viewDelegate?.gotoShopEditView()
    }
    
    @objc fileprivate func reportBtnAct() {
        ProfilePop.popoverVC.dismiss(animated: true, completion: nil)
        ProfilePop.viewDelegate?.showMailViewController()
    }
    
    
    
    @objc fileprivate func actionSheetConfirmLogOutBtnAct(){
        
        
        Analytics.logEvent("我_登出_確定登出", parameters:nil)
        let dic = CoordinatorAndControllerInstanceHelper.rootCoordinator.dic
        for data in dic {
            UserDefaults.standard.set(data.value, forKey: data.key)
        }
        
        CoordinatorAndControllerInstanceHelper.rootCoordinator.rootTabBarController.children.forEach({vc in
            vc.dismiss(animated: false, completion: nil)
        })
        
        let window = UIApplication.shared.keyWindow
        window?.rootViewController = RootTabBarController.initFromStoryboard()
        window?.makeKeyAndVisible()
        AppCoordinator(window: window).start()
        
        
    }
    
    @objc fileprivate func logOutBtnAct(){
        Analytics.logEvent("我_登出", parameters:nil)
        ProfilePop.actionSheetKit_LogOut.allBtnSlideIn()
        ProfilePop.popoverVC.dismiss(animated: true, completion: nil)
    }
    
    
    @objc fileprivate func goProfilePageBtnAct(){
        Analytics.logEvent("我_我的頁面", parameters:nil)
        let profileViewController = ProfileViewController(UID: UserSetting.UID)
        profileViewController.modalPresentationStyle = .overCurrentContext
        ProfilePop.popoverVC.dismiss(animated: true, completion: nil)
        if let viewController = CoordinatorAndControllerInstanceHelper.rootCoordinator.rootTabBarController.selectedViewController{
            viewController.present(profileViewController, animated: true,completion: nil)
        }
        
    }
    
}
