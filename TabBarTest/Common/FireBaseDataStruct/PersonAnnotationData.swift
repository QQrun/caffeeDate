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
    var isOpenStore: Bool
    var isRequest: Bool
    var latitude: String
    var longitude: String
    
    
    init(openTime: String,title: String, gender: Int, isOpenStore: Bool, isRequest: Bool,latitude: String,longitude:String) {
        self.openTime = openTime
        self.title = title
        self.gender = gender
        self.isOpenStore = isOpenStore
        self.isRequest = isRequest
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        if let openTime = snapshotValue["openTime"] as? String ,
           let title = snapshotValue["title"] as? String,
           let gender = snapshotValue["gender"] as? Int,
           let isOpenStore = snapshotValue["isOpenStore"] as? Bool,
           let isRequest = snapshotValue["isRequest"] as? Bool,
           let latitude = snapshotValue["latitude"] as? String,
           let longitude = snapshotValue["longitude"] as? String{
            self.openTime = openTime
            self.title = title
            self.gender = gender
            self.isOpenStore = isOpenStore
            self.isRequest = isRequest
            self.latitude = latitude
            self.longitude = longitude
            
        } else {
            self.openTime = ""
            self.title = ""
            self.gender = 0
            self.isOpenStore = false
            self.isRequest = false
            self.latitude = ""
            self.longitude = ""
        }
        
    
    }
    
    
    func toAnyObject() -> Any {
        return [
            "openTime": openTime,
            "title": title,
            "gender": gender,
            "isOpenStore": isOpenStore,
            "isRequest": isRequest,
            "latitude": latitude,
            "longitude": longitude,
        ]
    }
}
