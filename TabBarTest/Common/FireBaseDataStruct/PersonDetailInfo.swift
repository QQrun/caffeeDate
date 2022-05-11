//
//  PersonDetailInfo.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/04/15.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class PersonDetailInfo {
    var UID = "" //UserID
    var name = "" //名子
    var gender : Int = 0 //性別
    var birthday : String = ""
    var lastSignInTime : String = "" //最後上線時間 YYYYMMddHHmmss ex:20200416163112
    var selfIntroduction = "" //自我介紹
    var photos : [String]? //照片
    var headShot : String? //超小的大頭貼
    var headShotContainer : UIImage? //拿來暫存大頭貼照片，才不會需要重新讀取，節省流量
    
    var sellItems : [Item] = []
    var buyItems : [Item] = []
    
    var perferIconStyleToShowInMap : String = ""
    
    var sharedSeatScore : [String:Int] = [:]
    var sharedSeatComment : [String:Comment] = [:]
    
    init(UID:String,name: String, gender: Int,birthday:String, lastSignInTime: String,  selfIntroduction: String,photos:[String]?,headShot:String?,perferIconStyleToShowInMap:String) {
        self.UID = UID
        self.name = name
        self.gender = gender
        self.birthday = birthday
        self.lastSignInTime = lastSignInTime
        self.selfIntroduction = selfIntroduction
        self.photos = photos
        self.headShot = headShot
        self.perferIconStyleToShowInMap = perferIconStyleToShowInMap
    }
    
    init(snapshot: DataSnapshot){
        guard let snapshotValue = snapshot.value as? [String: AnyObject] else { return }
        UID = snapshot.key
        name = snapshotValue["name"] as? String ?? "error"
        selfIntroduction = snapshotValue["selfIntroduction"] as? String ?? ""
        gender = snapshotValue["gender"] as? Int ?? 0
        birthday = snapshotValue["birthday"] as? String ?? "2000/01/01"
        lastSignInTime = snapshotValue["lastSignInTime"] as? String ?? "20000408014655"
        photos = snapshotValue["photos"] as? [String]
        headShot = snapshotValue["headShot"] as? String
        perferIconStyleToShowInMap = snapshotValue["perferIconStyleToShowInMap"] as? String ?? ""
        
        sellItems = []
        if let childSnapshots = snapshot.childSnapshot(forPath: "SellItems").children.allObjects as? [DataSnapshot] {
            for childSnapshot in childSnapshots{
                let item = Item(snapshot: childSnapshot)
                sellItems.append(item)
            }
        }
        sellItems = Util.quicksort_Item(sellItems)
        sellItems.reverse()
        
        buyItems = []
        if let childSnapshots = snapshot.childSnapshot(forPath: "BuyItems").children.allObjects as? [DataSnapshot] {
            for childSnapshot in childSnapshots{
                let item = Item(snapshot: childSnapshot)
                buyItems.append(item)
            }
        }
        buyItems = Util.quicksort_Item(buyItems)
        buyItems.reverse()
        
        if let childSnapshots = snapshot.childSnapshot(forPath: "sharedSeatScore").children.allObjects as? [DataSnapshot] {
            for childSnapshot in childSnapshots{
                sharedSeatScore[childSnapshot.key] = childSnapshot.value as? Int
            }
        }
        
        if let childSnapshots = snapshot.childSnapshot(forPath: "sharedSeatComment").children.allObjects as? [DataSnapshot] {
            for childSnapshot in childSnapshots{
                var comment = Comment(snapshot: childSnapshot as! DataSnapshot)
                if(comment.UID == "錯誤"){
                    continue
                }
                comment.commentID = comment.UID
                sharedSeatComment[comment.UID] = comment
            }
        }
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "gender": gender,
            "birthday": birthday,
            "lastSignInTime": lastSignInTime,
            "selfIntroduction": selfIntroduction,
            "photos": photos,
            "headShot":headShot,
            "perferIconStyleToShowInMap":perferIconStyleToShowInMap,
        ]
    }
    
}


enum Gender {
    case Girl
    case Boy
}
