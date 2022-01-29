//
//  CoffeeScoreData.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2022/01/29.
//  Copyright © 2022 金融研發一部-邱冠倫. All rights reserved.
//


import Foundation
import Firebase


//For 上傳
class CoffeeScoreData {
    
    var wifiScore : Int
    var quietScore : Int
    var seatScore : Int
    var tastyScore : Int
    var cheapScore : Int
    var musicScore : Int
    
    init(wifiScore: Int,quietScore : Int,seatScore: Int,tastyScore : Int,cheapScore: Int,musicScore : Int) {
        self.wifiScore = wifiScore
        self.quietScore = quietScore
        self.seatScore = seatScore
        self.tastyScore = tastyScore
        self.cheapScore = cheapScore
        self.musicScore = musicScore
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        
        if let wifiScore = snapshotValue["wifiScore"] as? Int,
           let quietScore = snapshotValue["quietScore"] as? Int,
           let seatScore = snapshotValue["seatScore"] as? Int,
           let tastyScore = snapshotValue["tastyScore"] as? Int,
           let cheapScore = snapshotValue["cheapScore"] as? Int,
           let musicScore = snapshotValue["musicScore"] as? Int{
            self.wifiScore = wifiScore
            self.quietScore = quietScore
            self.seatScore = seatScore
            self.tastyScore = tastyScore
            self.cheapScore = cheapScore
            self.musicScore = musicScore
        } else{
            self.wifiScore = 0
            self.quietScore = 0
            self.seatScore = 0
            self.tastyScore = 0
            self.cheapScore = 0
            self.musicScore = 0
        }
        
    }
    
    func toAnyObject() -> Any {
        return [
            "wifiScore": wifiScore,
            "quietScore": quietScore,
            "seatScore": seatScore,
            "tastyScore": tastyScore,
            "cheapScore": cheapScore,
            "musicScore": musicScore,
        ]
    }
    
    
}
