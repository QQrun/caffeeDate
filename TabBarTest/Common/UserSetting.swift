//
//  UserSetting.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/04/09.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//


import Foundation


class UserSetting{
    
    //是否往FireBase上傳過PersonDetail
    static var alreadyUpdatePersonDetail: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "alreadyUpdatePersonDetail")
        }
        get {
            return UserDefaults.standard.bool(forKey: "alreadyUpdatePersonDetail")
        }
    }
    
    
    
    // 恆亮設置
    static var isIdleTimerDisabled: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "isIdleTimerDisabled")
        }
        get {
            return UserDefaults.standard.bool(forKey: "isIdleTimerDisabled")
        }
    }
    // 地圖上是否顯示 開店、任務、揪團、咖啡店、男性交友、女性交友資訊
    static var isMapShowOpenStore: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "isMapShowOpenStore")
        }
        get {
            return UserDefaults.standard.bool(forKey: "isMapShowOpenStore")
        }
    }
    static var isMapShowRequest: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "isMapShowRequest")
        }
        get {
            return UserDefaults.standard.bool(forKey: "isMapShowRequest")
        }
    }
    static var isMapShowTeamUp: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "isMapShowTeamUp")
        }
        get {
            return UserDefaults.standard.bool(forKey: "isMapShowTeamUp")
        }
    }
    static var isMapShowCoffeeShop: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "isMapShowCoffeeShop")
        }
        get {
            return UserDefaults.standard.bool(forKey: "isMapShowCoffeeShop")
        }
    }
    static var isMapShowMakeFriend_Boy: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "isMapShowMakeFriend_Boy")
        }
        get {
            return UserDefaults.standard.bool(forKey: "isMapShowMakeFriend_Boy")
        }
    }
    static var isMapShowMakeFriend_Girl: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "isMapShowMakeFriend_Girl")
        }
        get {
            return UserDefaults.standard.bool(forKey: "isMapShowMakeFriend_Girl")
        }
    }

    //For PersonDetail
    
    static var UID: String {
         set {
             UserDefaults.standard.set(newValue, forKey: "UID")
         }
         get {
             return UserDefaults.standard.string(forKey: "UID") ?? ""
         }
     }
    
    static var userName: String {
         set {
             UserDefaults.standard.set(newValue, forKey: "userName")
         }
         get {
             return UserDefaults.standard.string(forKey: "userName") ?? ""
         }
     }
    
    static var userSelfIntroduction: String {
        set {
            UserDefaults.standard.set(newValue, forKey: "userSelfIntroduction")
        }
        get {
            return UserDefaults.standard.string(forKey: "userSelfIntroduction") ?? ""
        }
    }
    
    static var userGender: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: "userGender")
        }
        get {
            return UserDefaults.standard.integer(forKey: "userGender")
        }
    }
    
    
    static var userBirthDay: String {
        set {
            UserDefaults.standard.set(newValue, forKey: "userBirthDay")
        }
        get {
            return UserDefaults.standard.string(forKey: "userBirthDay") ?? ""
        }
    }

    
    static var userSmallHeadShotURL: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "userSmallHeadShotURL")
        }
        get {
            return UserDefaults.standard.string(forKey: "userSmallHeadShotURL")
        }
    }
    
    
    static var userPhotosUrl: [String] {
        set {
            UserDefaults.standard.set(newValue, forKey: "userPhotosUrl")
        }
        get {
            return (UserDefaults.standard.value(forKey: "userPhotosUrl") as! [String])
        }
    }
    
    static var sellItemsID: [String] {
        set {
            UserDefaults.standard.set(newValue, forKey: "sellItemsID")
        }
        get {
            return (UserDefaults.standard.value(forKey: "sellItemsID") as! [String])
        }
    }
    
    static var buyItemsID: [String] {
        set {
            UserDefaults.standard.set(newValue, forKey: "buyItemsID")
        }
        get {
            return (UserDefaults.standard.value(forKey: "buyItemsID") as! [String])
        }
    }
    
    

    
    
    //For PersonAnnotation
    
    
    static var storeName: String {
        set {
            UserDefaults.standard.set(newValue, forKey: "storeName")
        }
        get {
            return UserDefaults.standard.string(forKey: "storeName") ?? ""
        }
    }
    
    static var perferIconStyleToShowInMap: String {
        set {
            UserDefaults.standard.set(newValue, forKey: "perferIconStyleToShowInMap")
        }
        get {
            return UserDefaults.standard.string(forKey: "perferIconStyleToShowInMap") ?? "none"
        }
    }
    
    static var isWantSellSomething: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "isWantSellSomething")
        }
        get {
            return UserDefaults.standard.bool(forKey: "isWantSellSomething")
        }
    }
    
    static var isWantBuySomething: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "isWantBuySomething")
        }
        get {
            return UserDefaults.standard.bool(forKey: "isWantBuySomething")
        }
    }
    
    static var isWantTeamUp: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "isWantTeamUp")
        }
        get {
            return UserDefaults.standard.bool(forKey: "isWantTeamUp")
        }
    }
    
    static var isWantMakeFriend: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "isWantMakeFriend")
        }
        get {
            return UserDefaults.standard.bool(forKey: "isWantMakeFriend")
        }
    }
    
    
    static var userLatitude: String{
        set {
            UserDefaults.standard.set(newValue, forKey: "userLatitude")
        }
        get {
            return UserDefaults.standard.string(forKey: "userLatitude") ?? ""
        }
    }
    
    static var userLongitude: String{
        set {
            UserDefaults.standard.set(newValue, forKey: "userLongitude")
        }
        get {
            return UserDefaults.standard.string(forKey: "userLongitude") ?? ""
        }
    }
    
    
    
    static var keyBoardHeight: Float? {
        set {
            UserDefaults.standard.set(newValue, forKey: "keyBoardHeight")
        }
        get {
            return UserDefaults.standard.float(forKey: "keyBoardHeight")
        }
    }
    
    static var currentChatTarget: String {
        set {
            UserDefaults.standard.set(newValue, forKey: "currentChatTarget")
        }
        get {
            return UserDefaults.standard.string(forKey: "currentChatTarget") ?? ""
        }
    }
    
    // 是否評分過
    static var isRatinged: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "isRatinged")
        }
        get {
            return UserDefaults.standard.bool(forKey: "isRatinged")
        }
    }
    
    // 是否拒絕評分過
    static var isRejectRating: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "isRejectRating")
        }
        get {
            return UserDefaults.standard.bool(forKey: "isRejectRating")
        }
    }
    
    // 使用者超過一分鐘次數
    static var userMore1MinCount: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: "userMore1MinCount")
        }
        get {
            return UserDefaults.standard.integer(forKey: "userMore1MinCount")
        }
    }
    
    
    // 背景
    static var background: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "kBackground")
        }
        get {
            return UserDefaults.standard.string(forKey: "kBackground") ?? nil
        }
    }
    
    // 主色
    static var primary: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "kPrimary")
        }
        get {
            return UserDefaults.standard.string(forKey: "kPrimary") ?? nil
        }
    }
    
    // 深色模式
    static var isNightMode: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "kNightMode")
        }
        get {
            return UserDefaults.standard.bool(forKey: "kNightMode")
        }
    }
    
    
}
