//
//  RootCoordinator.swift
//  StockSelect
//
//  Created by Tom on 2019/4/29.
//  Copyright © 2019 mitake. All rights reserved.
//

import UIKit
import Firebase
import MessageUI

class RootCoordinator: Coordinator {
    
    unowned let rootTabBarController: RootTabBarController
    
    
    var mapTab : UINavigationController!
    
    var notifyTab : UINavigationController!
    
    var mailTab : UINavigationController!
    
    var settingTab : UINavigationController!
    
    // LogIn Page
    lazy var logInViewController: LogInPageViewController = {
        let logInViewController = LogInPageViewController.initFromStoryboard()
        logInViewController.modalPresentationStyle = .fullScreen
        return logInViewController
    }()
    
    var shopEditViewController : ShopEditViewController!
    
    var mapViewController : MapViewController!
    
    var mailListViewController: MailListViewController!
    
    var notifyCenterViewController: NotifyCenterViewController!
    
    var settingViewController: SettingViewController!
    
    
    init(rootTabBarController: RootTabBarController) {
        self.rootTabBarController = rootTabBarController
    }
    
    override func start() {
        
        CoordinatorAndControllerInstanceHelper.rootCoordinator = self
        
        UserSetting.currentChatRoomID = ""
        
        if Auth.auth().currentUser == nil {
            print("No user is signed in.")
            self.showFirstLogInView()
        }else if !UserSetting.alreadyUpdatePersonDetail{
            print("user not yet update PersonDetail to firebase")
            self.showFirstLogInView()
        }else{
            print("User is signed in ,id:" + UserSetting.UID)
            self.setDefaultTabView()
            FirebaseHelper.updateSignInTime()
            FirebaseHelper.updateToken()
        }
        
    }
    
    func setDefaultTabView() {
        
        
        mapTab =  {
            mapViewController = MapViewController.initFromStoryboard()
            mapViewController.viewDelegate = self
            let mapTab = UINavigationController.init(rootViewController: mapViewController)
            mapTab.setNavigationBarHidden(true, animated: false)
            mapTab.title = ""
            return mapTab
        }()
        
        notifyTab  = {
            notifyCenterViewController = NotifyCenterViewController.initFromStoryboard()
            notifyCenterViewController.viewDelegate = self
            let notifyTab = UINavigationController.init(rootViewController: notifyCenterViewController)
            notifyTab.setNavigationBarHidden(true, animated: false)
            notifyTab.title = ""
            return notifyTab
        }()
        
        
        mailTab = {
            mailListViewController = MailListViewController.initFromStoryboard()
            mailListViewController.viewDelegate = self
            let mailTab = UINavigationController.init(rootViewController: mailListViewController)
            mailTab.setNavigationBarHidden(true, animated: false)
            mailTab.title = ""
            return mailTab
        }()
        
        
        settingTab = {
            settingViewController = SettingViewController.initFromStoryboard()
            settingViewController.viewDelegate = self
            let settingTab = UINavigationController.init(rootViewController: settingViewController)
            settingTab.setNavigationBarHidden(true, animated: false)
            settingTab.title = ""
            return settingTab
        }()
        
        
        rootTabBarController.setViewControllers([mapTab, mailTab,notifyTab,settingTab], animated: false)
        //??
        //        if rootTabBarController.presentedViewController != nil {
        //            rootTabBarController.dismiss(animated: false)
        //        }
    }
    
    public func showFirstLogInView(){
        logInViewController.mapViewController = mapViewController
        rootTabBarController.present(logInViewController,animated: true, completion: nil)
    }
    
    func hiddenTabBar(){
        rootTabBarController.tabBar.isHidden = true
    }
    func showTabBar(){
        rootTabBarController.tabBar.isHidden = false
    }
}


extension RootCoordinator: MapViewControllerViewDelegate {
    
    
    func gotoItemViewController_mapView(item:Item,personDetail:PersonDetailInfo) {
        let itemViewController = ItemViewController(item : item,personInfo: personDetail)
        itemViewController.modalPresentationStyle = .overCurrentContext
        mapTab.pushViewController(itemViewController, animated: true)
    }
    
    func gotoProfileViewController_mapView(personDetail:PersonDetailInfo){
        Analytics.logEvent("地圖_前往個人檔案", parameters:nil)
        let profileViewController = ProfileViewController(personDetail: personDetail)
        profileViewController.modalPresentationStyle = .overCurrentContext
        mapTab.pushViewController(profileViewController, animated: true)
    }
    
    func gotoWantSellViewController_mapView(defaultItem:Item?){
        let wantSellViewController = WantSellViewController(defaultItem: defaultItem)
        wantSellViewController.modalPresentationStyle = .overCurrentContext
        wantSellViewController.mapViewController = mapViewController
        wantSellViewController.iWantType = .Sell
        mapTab.pushViewController(wantSellViewController, animated: true)
    }
    
    func gotoWantBuyViewController_mapView(defaultItem:Item?){
        let wantBuyViewController = WantSellViewController(defaultItem: defaultItem)
        wantBuyViewController.modalPresentationStyle = .overCurrentContext
        wantBuyViewController.mapViewController = mapViewController
        wantBuyViewController.iWantType = .Buy
        mapTab.pushViewController(wantBuyViewController, animated: true)
    }
    
    func gotoHoldSharedSeatController_mapView(){
        let holdShareSeatViewController = HoldShareSeatViewController()
        holdShareSeatViewController.viewDelegate = self
        holdShareSeatViewController.modalPresentationStyle = .overCurrentContext
        mapTab.pushViewController(holdShareSeatViewController, animated: true)
    }
    
    
    func gotoScoreCoffeeController_mapView(annotation:CoffeeAnnotation){
        let scoreCoffeeViewController = ScoreCoffeeViewController(annotation:annotation)
        scoreCoffeeViewController.modalPresentationStyle = .overCurrentContext
        mapTab.pushViewController(scoreCoffeeViewController, animated: true)
    }
    
    func showListLocationViewController(sharedSeatAnnotations:[SharedSeatAnnotation]){
        let listLocationViewController = ListLocationViewController(sharedSeatAnnotations:sharedSeatAnnotations)
        listLocationViewController.modalPresentationStyle = .popover
        rootTabBarController.present(listLocationViewController, animated: true, completion: nil)
    }
    
    func gotoRegistrationList(sharedSeatAnnotation:SharedSeatAnnotation){
        let registrationListViewController = RegistrationListViewController(sharedSeatAnnotation:sharedSeatAnnotation)
        registrationListViewController.viewDelegate = self
        registrationListViewController.modalPresentationStyle = .popover
        mapTab.pushViewController(registrationListViewController, animated: true)
        
    }
}


extension RootCoordinator: ShopEditViewControllerViewDelegate {
    
    func gotoItemViewController_shopEditView(item : Item,personDetail:PersonDetailInfo) {
        Analytics.logEvent("編輯商店_點擊商品_查看", parameters:nil)
        let itemViewController = ItemViewController(item : item , personInfo: personDetail)
        itemViewController.modalPresentationStyle = .overCurrentContext
        mapTab.pushViewController(itemViewController, animated: true)
    }
    
    func gotoProfileViewController_shopEditView(personDetail:PersonDetailInfo){
        Analytics.logEvent("編輯商店_前往個人檔案", parameters:nil)
        let profileViewController = ProfileViewController(personDetail: personDetail)
        profileViewController.modalPresentationStyle = .overCurrentContext
        mapTab.pushViewController(profileViewController, animated: true)
        
        
    }
    
    func gotoWantSellViewController_shopEditView(defaultItem:Item?){
        let wantSellViewController = WantSellViewController(defaultItem: defaultItem)
        wantSellViewController.modalPresentationStyle = .overCurrentContext
        wantSellViewController.shopEditViewController = shopEditViewController
        wantSellViewController.iWantType = .Sell
        mapTab.pushViewController(wantSellViewController, animated: true)
    }
    
    func gotoWantBuyViewController_shopEditView(defaultItem:Item?){
        let wantBuyViewController = WantSellViewController(defaultItem: defaultItem)
        wantBuyViewController.modalPresentationStyle = .overCurrentContext
        wantBuyViewController.shopEditViewController = shopEditViewController
        wantBuyViewController.iWantType = .Buy
        mapTab.pushViewController(wantBuyViewController, animated: true)
    }
}

extension RootCoordinator: HoldShareSeatViewControllerViewDelegate {
    
    func gotoChooseLocationView(holdShareSeatViewController:HoldShareSeatViewController) {
        
        
        
        let chooseLocationViewController = ChooseLocationViewController(holdShareSeatViewController:holdShareSeatViewController)
        
        mapTab.pushViewController(chooseLocationViewController, animated: true)
        
    }
    
    
}


extension RootCoordinator: SettingViewDelegate{
    
    var compileDate:Date
    {
        let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as? String ?? "Info.plist"
        if let infoPath = Bundle.main.path(forResource: bundleName, ofType: nil),
           let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
           let infoDate = infoAttr[FileAttributeKey.creationDate] as? Date
        
        { return infoDate }
        return Date()
    }
    
    func showMailViewController() {
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? ""
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        let displayVersion = appVersion + "_" + build
        let subject = "意見回饋(\(appName))"
        let recipient = "facetraderservice@gmail.com"
        let modelName = UIDevice.current.modelName
        let osVersion = UIDevice.current.systemVersion
        let messageBody = "\n\n\n\n\n\n\n\n\n\n----------------\n\(appName)\n程式版本：\(displayVersion)\n機型：\(modelName)\niOS版本：\(osVersion)\n用戶代碼：\(UserSetting.UID)"
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = mapViewController as! MFMailComposeViewControllerDelegate
            // 收件人
            mail.setToRecipients([recipient])
            // 標題
            mail.setSubject(subject)
            // 信件內容
            mail.setMessageBody(messageBody, isHTML: false)
            mapViewController.present(mail, animated: true)
        }else {
            let mail = "mailto:\(recipient)?subject=\(subject)&body=\(messageBody)"
            if
                let email = mail.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
                let emailURL = URL(string:email) {
                UIApplication.shared.open(emailURL)
            }
        }
        
    }
    
    
    func gotoShopEditView() {
        shopEditViewController = ShopEditViewController()
        shopEditViewController.modalPresentationStyle = .overCurrentContext
        shopEditViewController.mapViewController = mapViewController
        shopEditViewController.viewDelegate = self
        mapTab.pushViewController(shopEditViewController, animated: true)
    }
    
    func gotoProfileEditView() {
        let profileEditViewController = ProfileEditViewController()
        profileEditViewController.modalPresentationStyle = .overCurrentContext
        profileEditViewController.mapViewController = mapViewController
        mapTab.pushViewController(profileEditViewController, animated: true)
    }
    
    
}

extension RootCoordinator: MailListViewControllerDelegate{
    
    func gotoChatRoom(chatroomID: String, personDetailInfos: [PersonDetailInfo]?,animated:Bool) {
        
        Analytics.logEvent("訊息_前往一對一聊天室", parameters:nil)
        
        let oneToOneChatViewController = MessageRoomViewController(chatroomID: chatroomID, targetPersonInfos: personDetailInfos)
        mailTab.pushViewController(oneToOneChatViewController, animated: animated)
        
        rootTabBarController.selectedViewController = CoordinatorAndControllerInstanceHelper.rootCoordinator.mailTab
    }
    
}

extension RootCoordinator: NotifyCenterViewControllerDelegate{
    func gotoItemViewController_NotifyCenterView(item: Item,itemOwnerID:String) {
        let itemViewController = ItemViewController(item : item , itemOwnerID: itemOwnerID)
        itemViewController.modalPresentationStyle = .overCurrentContext
        notifyTab.pushViewController(itemViewController, animated: true)
    }
    
    
}


extension RootCoordinator: RegistrationListViewDelegant{
    
    func gotoDrawCardPage(sharedSeatAnnotation: SharedSeatAnnotation) {
        let drawCardViewController = DrawCardViewController(sharedSeatAnnotation:sharedSeatAnnotation)
        drawCardViewController.modalPresentationStyle = .popover
//        mapTab.pushViewController(drawCardViewController, animated: true)
        rootTabBarController.present(drawCardViewController, animated: true,completion: nil)

    }
    
}
