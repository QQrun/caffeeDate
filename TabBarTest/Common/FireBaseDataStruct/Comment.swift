//
//  Comment.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/05/03.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import UIKit
import Firebase


class Comment {
    
    var time : String
    var UID : String
    var name : String
    var gender : Int
    var smallHeadshotURL : String?
    var content : String
    var likeUIDs : [String]?
    var commentID : String?
    var smallHeadshot : UIImage?
    init(time:String,UID:String,name:String,gender:Int,smallHeadshotURL:String?,content:String,likeUIDs:[String]?) {
        
        self.time = time
        self.UID = UID
        self.name = name
        self.gender = gender
        self.smallHeadshotURL = smallHeadshotURL
        self.content = content
        self.likeUIDs = likeUIDs
        
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        time = snapshotValue["time"] as! String
        UID = snapshotValue["UID"] as! String
        name = snapshotValue["name"] as! String
        gender = snapshotValue["gender"] as! Int
        smallHeadshotURL = snapshotValue["smallHeadshotURL"] as? String
        content = snapshotValue["content"] as! String
        likeUIDs = snapshotValue["likeUIDs"] as? [String]
    }
    
    func toAnyObject() -> Any {
        return [
            "time": time,
            "UID": UID,
            "name": name,
            "gender": gender,
            "smallHeadshotURL": smallHeadshotURL,
            "content": content,
            "likeUIDs": likeUIDs,
        ]
    }
    
}
