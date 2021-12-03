//
//  RootTabBarController.swift
//  StockSelect
//
//  Created by Tom on 2019/4/29.
//  Copyright © 2019 mitake. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class RootTabBarController: UITabBarController {
    
    var statusBarHidden : Bool = false
    
    
    var containerViews : [UIView] = []
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    lazy var rootTabBarTransition: RootTabBarTransition = {
        return RootTabBarTransition(viewControllers: viewControllers)
    }()
    
    
    override func viewDidLoad() {
        UserSetting.isNightMode = false
        if UserSetting.isNightMode {
            overrideUserInterfaceStyle = .dark
        }else{
            overrideUserInterfaceStyle = .light
        }
        super.viewDidLoad()
        configTapBarColor()
        delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //TODO 有一個問題是太慢了，它會等畫面出現才做調整
        //將tapBar背景的黑色去掉
        if tabBar.subviews.count > 0{
            tabBar.subviews[0].alpha = 0
        }
//        //將內容拉長至tapBar下方
//        view.subviews[0].subviews[0].frame = CGRect(x: 0, y: 0, width:view.frame.width, height: view.frame.height)
    }
    
    fileprivate func configTapBarColor() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 49)
        gradientLayer.colors = [UIColor(red: 69/255, green: 67/255, blue: 67/255, alpha: 0).cgColor,UIColor(red: 30/255, green: 14/255, blue: 1/255, alpha: 1).cgColor]
        tabBar.layer.insertSublayer(gradientLayer, at: 0)
        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = UIColor(red: 219/255, green: 211/255, blue: 198/255, alpha: 1)
        
        view.bringSubviewToFront(tabBar)
    }
    
    
}

extension RootTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return rootTabBarTransition
    }
}
