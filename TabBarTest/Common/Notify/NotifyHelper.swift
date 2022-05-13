//
//  NotifyHelper.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/08/30.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation

import UIKit
import UserNotifications


class NotifyHelper {
    
    
    static func pushNewMsgNoti(title:String,subTitle:String,chatRoomID:String) {
        
        let state = UIApplication.shared.applicationState
        
        //如果是在mailTab，那麼顯示推播的條件是在聊天室並且聊天室id != 推播聊天室的id
        if state == .active{
            if CoordinatorAndControllerInstanceHelper.rootCoordinator.rootTabBarController.selectedIndex == 1 {
                
                let visibleViewController =  CoordinatorAndControllerInstanceHelper.rootCoordinator.mailTab.visibleViewController
                if visibleViewController is MessageRoomViewController{
                    if chatRoomID == (visibleViewController as! MessageRoomViewController).chatroomID{
                        return //如果chatRoomID相同（也就是正在跟要推播的本人聊天），不顯示推播
                    }
                }else{
                    return //如果當前在mailList，不顯示推播
                }
            }
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subTitle
        var request = UNNotificationRequest(identifier: "tempExist", content: content, trigger: .none)
        
        if state == .background || state == .inactive {
            request = UNNotificationRequest(identifier: "longExist", content: content, trigger: .none)
        }
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
   
    }
    
    static func pushNewNoti(title:String,subTitle:String){
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subTitle
        var request = UNNotificationRequest(identifier: "tempExist", content: content, trigger: .none)
        let state = UIApplication.shared.applicationState
        if state == .background || state == .inactive {
            request = UNNotificationRequest(identifier: "longExist", content: content, trigger: .none)
        }
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    static func pushNewNoti(title:String,subTitle:String,roomID:String){
        print("pushNewNoti!!!!!!!!!!!!")
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subTitle
        var userInfo : [String: String] = [:]
        userInfo["gcm.notification.messageRoomID"] = roomID
        content.userInfo = userInfo
        var request = UNNotificationRequest(identifier: "tempExist", content: content, trigger: .none)
        let state = UIApplication.shared.applicationState
        if state == .background || state == .inactive {
            request = UNNotificationRequest(identifier: "longExist", content: content, trigger: .none)
        }
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
}
