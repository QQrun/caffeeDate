//
//  AppDelegate.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/04/07.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,GIDSignInDelegate {
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        //FireBase
        let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")!
        let options = FirebaseOptions(contentsOfFile: filePath)
        FirebaseApp.configure(options: options!)
        Messaging.messaging().delegate = self
        
        //google登入
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        //FB登入
        ApplicationDelegate.shared.application( application, didFinishLaunchingWithOptions: launchOptions )
        
        //本機預設參數
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
            
        
        var isShowedExplain = false
        var isMapShowOpenStore = false
        var isMapShowRequest = false
        var isMapShowSharedSeat2 = false
        var isMapShowSharedSeat4 = false
        #if FACETRADER
        isMapShowOpenStore = true
        isMapShowRequest = true
        #elseif VERYINCORRECT
        isMapShowSharedSeat2 = true
        isMapShowSharedSeat4 = true
        #endif
        let dic = ["alreadyUpdatePersonDetail":false,
                   "UID":"",
                   "userName":"",
                   "userBirthDay":"",
                   "userGender":1,
                   "isShowedExplain": isShowedExplain,
                   "isMapShowOpenStore": isMapShowOpenStore,
                   "isMapShowRequest":isMapShowRequest,
                   "isMapShowTeamUp":true,
                   "isMapShowCoffeeShop":false,
                   "isMapShowMakeFriend_Boy":true,
                   "isMapShowMakeFriend_Girl":true,
                   "isMapShowSharedSeat2":isMapShowSharedSeat2,
                   "isMapShowSharedSeat4":isMapShowSharedSeat4,
                   "perferIconStyleToShowInMap":"none",
                   "isWantSellSomething":false,
                   "isWantBuySomething":false,
                   "isWantTeamUp":false,
                   "isWantMakeFriend":false,
                   "sellItemsID":[],
                   "buyItemsID":[],
                   "userPhotosUrl":[] ] as [String : Any]
        
        UserDefaults.standard.register(defaults: dic)
        
//        UIApplication.shared.registerForRemoteNotifications()
        UNUserNotificationCenter.current().delegate = self
        
        

        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url)
    }
    
    //google登入
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error)
            return
        }
        guard let authentication = user.authentication else { return }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,accessToken: authentication.accessToken)
        
        (CoordinatorAndControllerInstanceHelper.logInPageViewController.firstLogInPage as! FirstLogInViewController).addLoadingView()
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print(error)
                (CoordinatorAndControllerInstanceHelper.logInPageViewController.firstLogInPage as! FirstLogInViewController).showToast(message: "登入失敗", font: .systemFont(ofSize: 14.0))
                (CoordinatorAndControllerInstanceHelper.logInPageViewController.firstLogInPage as! FirstLogInViewController).removeLoadingView()
                return
            }
            
            UserSetting.UID = Auth.auth().currentUser!.uid
            //如果已經有地點權限了，就跳過直接去填個人資訊，不然就去要求權限頁面
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                CoordinatorAndControllerInstanceHelper.logInPageViewController.goCheckLocationAccessPage()
            case .restricted:
                CoordinatorAndControllerInstanceHelper.logInPageViewController.goCheckLocationAccessPage()
            case .denied:
                CoordinatorAndControllerInstanceHelper.logInPageViewController.goCheckLocationAccessPage()
            case .authorizedAlways:
                CoordinatorAndControllerInstanceHelper.logInPageViewController.goFillBasicInfoPage()
            case .authorizedWhenInUse:
                CoordinatorAndControllerInstanceHelper.logInPageViewController.goFillBasicInfoPage()
            }
            
        }
        
    }
    
    
    
    
    
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        
        print("userNotificationCenter 1")
        //如果正在後台，直接顯示
        let state = UIApplication.shared.applicationState
        if state == .background || state == .inactive {
            completionHandler([[.alert]])
            print("userNotificationCenter 2")
            return
        }
        
        let content: UNNotificationContent = notification.request.content
        let userInfo = content.userInfo as NSDictionary as! [String: AnyObject]
        let messageRoomID = userInfo["gcm.notification.messageRoomID"] as! String
        
        //如果正處於mailList，不顯示通知
        if CoordinatorAndControllerInstanceHelper.rootCoordinator.rootTabBarController.selectedIndex == 1{
            if UserSetting.currentChatRoomID == ""{
                return
            }
        }
        
        //當前正在跟通知的主人聊天，忽視通知
        if UserSetting.currentChatRoomID == messageRoomID {
            print("userNotificationCenter 4")
            return
        }
        
        
        //傳送的對象是自己，忽視通知（可能兩個人共用同一個手機導致token一樣）
        if UserSetting.userName == notification.request.content.title {
            print("userNotificationCenter 5")
            return
        }
        
        print("userNotificationCenter 6")
        completionHandler([[.alert]])
        
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Change `2.0` to the desired number of seconds.
           // Code you want to be delayed
            let content: UNNotificationContent = response.notification.request.content
            let userInfo = content.userInfo as NSDictionary as! [String: AnyObject]
            let messageRoomID = userInfo["gcm.notification.messageRoomID"] as! String

            let chatViewController = MessageRoomViewController(chatroomID: messageRoomID, targetPersonInfos: nil)
            CoordinatorAndControllerInstanceHelper.rootCoordinator.rootTabBarController.selectedViewController = CoordinatorAndControllerInstanceHelper.rootCoordinator.mailTab
            CoordinatorAndControllerInstanceHelper.rootCoordinator.mailTab.pushViewController(chatViewController, animated: true)
        }

        
        
        completionHandler()
    }
}

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
    
}
