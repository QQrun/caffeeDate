//
//  Item.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/04/14.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Alamofire

class Item {
    var itemID : String? //上傳時不上傳此資訊，這是下載後再把key放進去，單純方便處理用
    var thumbnailUrl : String?
    var photosUrl : [String]?
    var name : String = ""
    var price : String = ""
    var descript : String = ""
    var order : Int = 0
    var done : Bool = false //被買或是被賣了
    var likeUIDs : [String]?
    var subscribedIDs : [String]? //因為是放在key值，需要格外的取法，toAnyObject()完後還需要處理
    var commentIDs : [String]? //因為是放在key值，需要格外的取法，toAnyObject()完後還需要處理
    var thumbnail : UIImage?
    var itemType : ItemType
    
    init(itemID: String?,thumbnailUrl: String?,photosUrl: [String]?, name: String, price: String, descript: String,order:Int,done:Bool,likeUIDs:[String]?,subscribedIDs:[String]?,commentIDs:[String]?,itemType:ItemType) {
        self.thumbnailUrl = thumbnailUrl
        self.itemID = itemID
        self.photosUrl = photosUrl
        self.name = name
        self.price = price
        self.descript = descript
        self.order = order
        self.done = done
        self.likeUIDs = likeUIDs
        self.subscribedIDs = subscribedIDs
        self.commentIDs = commentIDs
        self.itemType = itemType
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        itemID = snapshot.key
        thumbnailUrl = snapshotValue["thumbnailUrl"] as? String
        photosUrl = snapshotValue["photosUrl"] as? [String]
        name = snapshotValue["name"] as! String
        price = snapshotValue["price"] as! String
        descript = snapshotValue["descript"] as! String
        order = snapshotValue["order"] as! Int
        done = snapshotValue["done"] as! Bool
        let itemTypeString = snapshotValue["itemType"] as! String
        if itemTypeString == "Buy" {
            self.itemType = .Buy
        }else if itemTypeString == "Sell" {
            self.itemType = .Sell
        }else{
            self.itemType = .Sell
        }
        
        if let childchildSnapshots = snapshot.childSnapshot(forPath: "likeUIDs").children.allObjects as? [DataSnapshot]{
            likeUIDs = []
            for childchildSnapshot in childchildSnapshots{
                likeUIDs?.append(childchildSnapshot.key as String)
            }
        }
        if let childchildSnapshots = snapshot.childSnapshot(forPath: "commentIDs").children.allObjects as? [DataSnapshot]{
            commentIDs = []
            for childchildSnapshot in childchildSnapshots{
                commentIDs?.append(childchildSnapshot.key as String)
            }
        }
        if let childchildSnapshots = snapshot.childSnapshot(forPath: "subscribedIDs").children.allObjects as? [DataSnapshot]{
            subscribedIDs = []
            for childchildSnapshot in childchildSnapshots{
                subscribedIDs?.append(childchildSnapshot.key as String)
            }
        }
        
        
        
    }
    
    func toAnyObject() -> Any {
        
        var itemTypeString = ""
        if itemType == .Buy {
            itemTypeString = "Buy"
        }else if itemType == .Sell{
            itemTypeString = "Sell"
        }
        
        return [
            "itemID": itemID,
            "thumbnailUrl": thumbnailUrl,
            "photosUrl": photosUrl,
            "name": name,
            "price": price,
            "descript": descript,
            "order": order,
            "done":done,
            "likeUIDs":likeUIDs,
            "itemType":itemTypeString,
        ]
    }
    
    enum ItemType{
        case Sell
        case Buy
    }
    
}
