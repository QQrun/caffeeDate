//
//  SharedSeatAnnotationData.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2022/03/05.
//  Copyright © 2022 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Alamofire

//For 上傳
class SharedSeatAnnotationData {
    
    var restaurant: String
    var address: String
    var headCount: Int
    var boysID: [String]?
    var girlsID: [String]?
    var signUpBoysID: [String]?
    var signUpGirlsID: [String]?
    var reviewTime : String
    var dateTime : String
    var photosUrl: [String]?

    var latitude: String
    var longitude: String
    
    init(restaurant: String,address: String, headCount: Int, boysID: [String]?, girlsID: [String]?,signUpBoysID:[String]?,signUpGirlsID:[String]?, reviewTime: String, dateTime: String,photosUrl: [String]?,latitude: String,longitude:String) {
        self.restaurant = restaurant
        self.address = address
        self.headCount = headCount
        self.boysID = boysID
        self.girlsID = girlsID
        self.signUpBoysID = signUpBoysID
        self.signUpGirlsID = signUpGirlsID
        self.reviewTime = reviewTime
        self.dateTime = dateTime
        self.photosUrl = photosUrl
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        if let restaurant = snapshotValue["restaurant"] as? String ,
           let address = snapshotValue["address"] as? String,
           let headCount = snapshotValue["headCount"] as? Int,
           let reviewTime = snapshotValue["reviewTime"] as? String,
           let dateTime = snapshotValue["dateTime"] as? String,
           let latitude = snapshotValue["latitude"] as? String,
           let longitude = snapshotValue["longitude"] as? String{
            self.restaurant = restaurant
            self.address = address
            self.headCount = headCount
            self.reviewTime = reviewTime
            self.dateTime = dateTime
            self.latitude = latitude
            self.longitude = longitude
            
        } else {
            self.restaurant = ""
            self.address = ""
            self.headCount = 0
            self.reviewTime = ""
            self.dateTime = ""
            self.latitude = ""
            self.longitude = ""
        }
        
        self.photosUrl = snapshotValue["photosUrl"] as? [String]

        if let childchildSnapshots = snapshot.childSnapshot(forPath: "boysID").children.allObjects as? [DataSnapshot]{
            self.boysID = []
            for childchildSnapshot in childchildSnapshots{
                self.boysID?.append(childchildSnapshot.key as String)
            }
        }
        if let childchildSnapshots = snapshot.childSnapshot(forPath: "girlsID").children.allObjects as? [DataSnapshot]{
            self.girlsID = []
            for childchildSnapshot in childchildSnapshots{
                self.girlsID?.append(childchildSnapshot.key as String)
            }
        }
        if let childchildSnapshots = snapshot.childSnapshot(forPath: "signUpBoysID").children.allObjects as? [DataSnapshot]{
            self.signUpBoysID = []
            for childchildSnapshot in childchildSnapshots{
                self.signUpBoysID?.append(childchildSnapshot.key as String)
            }
        }
        
        if let childchildSnapshots = snapshot.childSnapshot(forPath: "signUpGirlsID").children.allObjects as? [DataSnapshot]{
            self.signUpGirlsID = []
            for childchildSnapshot in childchildSnapshots{
                self.signUpGirlsID?.append(childchildSnapshot.key as String)
            }
        }
    }
    
    func toAnyObject() -> Any {
        
        if(boysID != nil && boysID!.count > 0){
            return [
                "restaurant": restaurant,
                "address": address,
                "headCount": headCount,
                "boysID": [boysID![0]:UserSetting.userName], //舉辦人自己是參與者
                "reviewTime": reviewTime,
                "dateTime": dateTime,
                "photosUrl": photosUrl,
                "latitude": latitude,
                "longitude": longitude,
            ]
        }else if(girlsID != nil && girlsID!.count > 0){
            return [
                "restaurant": restaurant,
                "address": address,
                "headCount": headCount,
                "boysID": [girlsID![0]:UserSetting.userName], //舉辦人自己是參與者
                "reviewTime": reviewTime,
                "dateTime": dateTime,
                "photosUrl": photosUrl,
                "latitude": latitude,
                "longitude": longitude,
            ]
        }else{
            return [
                "restaurant": restaurant,
                "address": address,
                "headCount": headCount,
                "reviewTime": reviewTime,
                "dateTime": dateTime,
                "photosUrl": photosUrl,
                "latitude": latitude,
                "longitude": longitude,
            ]
        }
        
        
    }
}

