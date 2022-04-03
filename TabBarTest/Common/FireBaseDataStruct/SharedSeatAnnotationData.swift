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
    var mode: Int //1 一對一  2 二對二
    var boysID: [String:String]?
    var girlsID: [String:String]?
    var signUpBoysID: [String:String]?
    var signUpGirlsID: [String:String]?
    var reviewTime : String
    var dateTime : String
    var photosUrl: [String]?
    var latitude: String
    var longitude: String
    
    
    init(restaurant: String,address: String, mode: Int, boysID: [String:String]?, girlsID: [String:String]?,signUpBoysID:[String:String]?,signUpGirlsID:[String:String]?, reviewTime: String, dateTime: String,photosUrl: [String]?,latitude: String,longitude:String) {
        self.restaurant = restaurant
        self.address = address
        self.mode = mode
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
           let mode = snapshotValue["mode"] as? Int,
           let reviewTime = snapshotValue["reviewTime"] as? String,
           let dateTime = snapshotValue["dateTime"] as? String,
           let latitude = snapshotValue["latitude"] as? String,
           let longitude = snapshotValue["longitude"] as? String{
            self.restaurant = restaurant
            self.address = address
            self.mode = mode
            self.reviewTime = reviewTime
            self.dateTime = dateTime
            self.latitude = latitude
            self.longitude = longitude
            
        } else {
            self.restaurant = ""
            self.address = ""
            self.mode = 0
            self.reviewTime = ""
            self.dateTime = ""
            self.latitude = ""
            self.longitude = ""
        }
        
        self.photosUrl = snapshotValue["photosUrl"] as? [String]

        
        if let childchildSnapshots = snapshot.childSnapshot(forPath: "boysID").children.allObjects as? [DataSnapshot]{
            self.boysID = [:]
            for childchildSnapshot in childchildSnapshots{
                self.boysID![childchildSnapshot.key] = (childchildSnapshot.value as? String)
            }
        }
        if let childchildSnapshots = snapshot.childSnapshot(forPath: "girlsID").children.allObjects as? [DataSnapshot]{
            self.girlsID = [:]
            for childchildSnapshot in childchildSnapshots{
                self.girlsID![childchildSnapshot.key] = (childchildSnapshot.value as? String)
            }
        }
        if let childchildSnapshots = snapshot.childSnapshot(forPath: "signUpBoysID").children.allObjects as? [DataSnapshot]{
            self.signUpBoysID = [:]
            for childchildSnapshot in childchildSnapshots{
                self.signUpBoysID![childchildSnapshot.key] = (childchildSnapshot.value as? String)
            }
        }
        
        if let childchildSnapshots = snapshot.childSnapshot(forPath: "signUpGirlsID").children.allObjects as? [DataSnapshot]{
            self.signUpGirlsID = [:]
            for childchildSnapshot in childchildSnapshots{
                self.signUpGirlsID![childchildSnapshot.key] = (childchildSnapshot.value as? String)
            }
        }
    }
    
    func toAnyObject() -> Any {
        
        if(boysID != nil && boysID!.count > 0){
            return [
                "restaurant": restaurant,
                "address": address,
                "mode": mode,
                "boysID": boysID,
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
                "mode": mode,
                "girlsID": girlsID,
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
                "mode": mode,
                "reviewTime": reviewTime,
                "dateTime": dateTime,
                "photosUrl": photosUrl,
                "latitude": latitude,
                "longitude": longitude,
            ]
        }
        
        
    }
}

