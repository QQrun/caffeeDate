//
//  TradeAnnotationData.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/04/24.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import Firebase


//For 上傳
class TradeAnnotationData {
    
    var openTime : String
    var title: String
    var gender: Int
    var preferMarkType: String
    
    var wantMakeFriend: Bool
    var isOpenStore: Bool
    var isRequest: Bool
    var isTeamUp: Bool
    
    var latitude: String
    var longitude: String
    
    
    init(openTime: String,title: String, gender: Int, preferMarkType: String, wantMakeFriend: Bool, isOpenStore: Bool, isRequest: Bool,isTeamUp: Bool,latitude: String,longitude:String) {
        self.openTime = openTime
        self.title = title
        self.gender = gender
        self.preferMarkType = preferMarkType
        self.wantMakeFriend = wantMakeFriend
        self.isOpenStore = isOpenStore
        self.isRequest = isRequest
        self.isTeamUp = isTeamUp
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        if let openTime = snapshotValue["openTime"] as? String ,
           let title = snapshotValue["title"] as? String,
           let gender = snapshotValue["gender"] as? Int,
           let preferMarkType = snapshotValue["preferMarkType"] as? String,
           let wantMakeFriend = snapshotValue["wantMakeFriend"] as? Bool,
           let isOpenStore = snapshotValue["isOpenStore"] as? Bool,
           let isRequest = snapshotValue["isRequest"] as? Bool,
           let isTeamUp = snapshotValue["isTeamUp"] as? Bool,
           let latitude = snapshotValue["latitude"] as? String,
           let longitude = snapshotValue["longitude"] as? String{
            self.openTime = openTime
            self.title = title
            self.gender = gender
            self.preferMarkType = preferMarkType
            self.wantMakeFriend = wantMakeFriend
            self.isOpenStore = isOpenStore
            self.isRequest = isRequest
            self.isTeamUp = isTeamUp
            self.latitude = latitude
            self.longitude = longitude
            
        } else {
            self.openTime = ""
            self.title = ""
            self.gender = 0
            self.preferMarkType = ""
            self.wantMakeFriend = false
            self.isOpenStore = false
            self.isRequest = false
            self.isTeamUp = false
            self.latitude = ""
            self.longitude = ""
        }
        
    
    }
    
    
    func toAnyObject() -> Any {
        return [
            "openTime": openTime,
            "title": title,
            "gender": gender,
            "preferMarkType": preferMarkType,
            "wantMakeFriend": wantMakeFriend,
            "isOpenStore": isOpenStore,
            "isRequest": isRequest,
            "isTeamUp": isTeamUp,
            "latitude": latitude,
            "longitude": longitude,
        ]
    }
}
