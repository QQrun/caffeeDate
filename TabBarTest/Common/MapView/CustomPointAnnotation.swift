//
//  CustomPointAnnotation.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/04/14.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import MapKit
import UIKit


class CustomPointAnnotation: MKPointAnnotation {
    
    enum MarkType {
        case makeFriend
        case openStore
        case request
        case teamUp
        case none
    }
}



class CoffeeAnnotation : CustomPointAnnotation{
    var name: String = ""
    var city: String = ""
    var wifi: CGFloat = 0
    var seat: CGFloat = 0
    var quiet: CGFloat = 0
    var tasty: CGFloat = 0
    var cheap: CGFloat = 0
    var music: CGFloat = 0
    var url: String = ""
    var address: String = ""
    var latitude: String = ""
    var longitude: String = ""
    var open_time: String = ""
    var business_hours : Business_hours? = nil
    var wishes: Int = 0
    var favorites: Int = 0
    var checkins: Int = 0
    var reviews: Int = 0
    var tags:[String] = []

}

class PersonAnnotation : CustomPointAnnotation {
    
    var preferMarkType : MarkType = .openStore
    var markTypeToShow : MarkType = .none
    var UID = ""
    var userName = ""
    var openTime = ""
    var gender : Gender = .Boy
    var wantMakeFriend = false
    var isOpenStore = false
    var isRequest = false
    var isTeamUp = false
    var smallHeadShot :UIImage!
}
