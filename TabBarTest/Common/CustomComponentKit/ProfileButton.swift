//
//  goProfileButton.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/09/30.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import UIKit


class ProfileButton : UIButton {
    
    var personInfo : PersonDetailInfo!
    convenience init(personInfo:PersonDetailInfo) {
        self.init()
        self.personInfo = personInfo
        self.isEnabled = true
        self.addTarget(self, action: #selector(self.goProfileBtnAct), for: .touchUpInside)
    }
    
    var UID : String?
    convenience init(UID:String) {
        self.init()
        self.UID = UID
        self.isEnabled = true
        self.addTarget(self, action: #selector(self.goProfileBtnAct_ByUID), for: .touchUpInside)
    }
    
    @objc func goProfileBtnAct(){
        
        let profileViewController = ProfileViewController(personDetail: personInfo)
        profileViewController.modalPresentationStyle = .overCurrentContext
        
        if let viewController = CoordinatorAndControllerInstanceHelper.rootCoordinator.rootTabBarController.selectedViewController{
            (viewController as! UINavigationController).pushViewController(profileViewController, animated: true)
        }
    }
    
    @objc func goProfileBtnAct_ByUID(){
        
        let profileViewController = ProfileViewController(UID: UID!)
        profileViewController.modalPresentationStyle = .overCurrentContext
        
        if let viewController = CoordinatorAndControllerInstanceHelper.rootCoordinator.rootTabBarController.selectedViewController{
            (viewController as! UINavigationController).pushViewController(profileViewController, animated: true)
        }
    }
}
