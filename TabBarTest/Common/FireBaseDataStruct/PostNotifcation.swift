//
//  PostNotifcation.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/09/24.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import Firebase


class PostNotifcation {
    
    var isRead : Bool
    var itemName : String
    var itemID : String
    var posterID : String
    var time : String
    var notifcationType : PostNotifcationType
    var iWantType : Item.ItemType
    var reviewers : [ReviewerData]
    
    init(isRead: Bool,itemName: String, itemID: String, posterID: String, time: String,notifcationType: PostNotifcationType,iWantType: Item.ItemType,reviewers: [ReviewerData]) {
        self.isRead = isRead
        self.itemName = itemName
        self.itemID = itemID
        self.posterID = posterID
        self.time = time
        self.notifcationType = notifcationType
        self.iWantType = iWantType
        self.reviewers = reviewers
    }
    
    //
    init(snapshot: DataSnapshot) {

        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.itemID = snapshot.key
        
        self.posterID = snapshotValue["posterID"] as? String ?? ""
        self.itemName = snapshotValue["itemName"] as? String ?? ""
        
        if snapshotValue["isRead"] as? String == "0"{
            self.isRead = false
        }else{
            self.isRead = true
        }
        if snapshotValue["type"] as? String == "1"{
            self.notifcationType = .MyItemHasRespond
        }else {
            self.notifcationType = .OtherItemHasRespond
        }
        if snapshotValue["iWantType"] as? String == "SellItems"{
            self.iWantType = .Sell
        }else if snapshotValue["iWantType"] as? String == "BuyItems"{
            self.iWantType = .Buy
        }else{
            self.iWantType = .Sell
        }
        self.reviewers = []
        if let childSnapshots = snapshot.childSnapshot(forPath: "reviewers").children.allObjects as? [DataSnapshot]{
            for childSnapshot in childSnapshots{
                let childSnapshotTime = childSnapshot.value as! String
                self.reviewers.append(ReviewerData(name: childSnapshot.key, time: childSnapshotTime))
            }
        }
        self.time = snapshotValue["time"] as! String
        
    }
    //
    
}

struct ReviewerData {
    var name : String
    var time : String
}

enum PostNotifcationType {
    case MyItemHasRespond //有人回覆我的文章
    case OtherItemHasRespond //有人回覆他人的文章
}
