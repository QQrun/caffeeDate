//
//  PresonAnnotationGetter.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/04/14.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import MapKit
import Firebase
import Alamofire

class PresonAnnotationGetter{
    
    var mapView : MKMapView
    
    var openShopAnnotations : [TradeAnnotation] = []
    var requestAnnotations : [TradeAnnotation] = []
    var teamUpAnnotations : [TradeAnnotation] = []
    var boySayHiAnnotations : [TradeAnnotation] = []
    var girlSayHiAnnotations : [TradeAnnotation] = []
    
    private let durationOfAuction = 60 * 60 * 24 * 7 //刊登持續時間（秒） 7天
    
    var userAnnotation : TradeAnnotation?{
        didSet{
            if userAnnotation != nil{
                CoordinatorAndControllerInstanceHelper.rootCoordinator.settingViewController.storeOpenTimeString = userAnnotation!.openTime
                UserSetting.storeName = userAnnotation!.title!
            }else{
                CoordinatorAndControllerInstanceHelper.rootCoordinator.settingViewController.storeOpenTimeString = ""
            }
        }
    }
    
    init(mapView:MKMapView) {
        self.mapView = mapView
    }
    
    
    
    
    fileprivate func packageTradeAnnotation(_ user_child: NSEnumerator.Element) {
        let user_snap = user_child as! DataSnapshot
        
        let TradeAnnotationData = TradeAnnotationData(snapshot: user_snap)
        if(TradeAnnotationData.openTime == ""){ //這代表解包失敗
            return
        }
        let TradeAnnotation = TradeAnnotation()
        
        if TradeAnnotationData.preferMarkType == "openStore"{
            TradeAnnotation.preferMarkType = .openStore
        }else if TradeAnnotationData.preferMarkType == "request"{
            TradeAnnotation.preferMarkType = .request
        }else if  TradeAnnotationData.preferMarkType == "makeFriend"{
            TradeAnnotation.preferMarkType = .makeFriend
        }else if  TradeAnnotationData.preferMarkType == "teamUp"{
            TradeAnnotation.preferMarkType = .teamUp
        }else{
            TradeAnnotation.preferMarkType = .none
        }
        
        if TradeAnnotationData.gender == 0{
            TradeAnnotation.gender = .Girl
        }else if TradeAnnotationData.gender == 1{
            TradeAnnotation.gender = .Boy
        }
        TradeAnnotation.UID = user_snap.key
        TradeAnnotation.title = TradeAnnotationData.title
        TradeAnnotation.isOpenStore = TradeAnnotationData.isOpenStore
        TradeAnnotation.isTeamUp = TradeAnnotationData.isTeamUp
        TradeAnnotation.isRequest = TradeAnnotationData.isRequest
        TradeAnnotation.wantMakeFriend = TradeAnnotationData.wantMakeFriend
        TradeAnnotation.openTime = TradeAnnotationData.openTime
        
        
        
        //確認那個地點是否有過期，如果有過期，不顯示
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYYMMddHHmmss"
        let seconds = Date().seconds(sinceDate: formatter.date(from: TradeAnnotationData.openTime)!)
        let remainingHour = (self.durationOfAuction - seconds!) / (60 * 60)
        let remainingMin = ((self.durationOfAuction - seconds!) % (60 * 60)) / 60
        let remainingSecond = ((self.durationOfAuction - seconds!) % (60 * 60)) % 60
        if remainingHour < 0 || remainingMin < 0 || remainingSecond < 0{
            if TradeAnnotation.UID == UserSetting.UID{
                FirebaseHelper.deleteTradeAnnotation()
                NotifyHelper.pushNewNoti(title: "擺攤時間到，已收攤", subTitle: "您可以在『我的攤販』設定內再度開啟攤販")
            }
            return
        }
        
        if TradeAnnotation.UID == UserSetting.UID{
            self.userAnnotation = TradeAnnotation
        }
        
        TradeAnnotation.coordinate = CLLocationCoordinate2D(latitude:  CLLocationDegrees((TradeAnnotationData.latitude as NSString).floatValue), longitude: CLLocationDegrees((TradeAnnotationData.longitude as NSString).floatValue))
        
//        if let smallIconUrl = TradeAnnotationData.smallHeadShotForMapIcon{
//            AF.request(smallIconUrl).response { (response) in
//                guard let data = response.data, let image = UIImage(data: data)
//                    else {
//                        print("讀取圖片url失敗")
//                        return }
//                TradeAnnotation.smallHeadShot = image
//                var canShow = false
//                canShow = self.decideCanShowOrNotAndWhichIcon(TradeAnnotation)
//                self.classifyAnnotation(TradeAnnotation)
//                if canShow{
//                    self.mapView.addAnnotation(TradeAnnotation)
//                }
//            }
//
//        }else{
//            var canShow = false
//            canShow = decideCanShowOrNotAndWhichIcon(TradeAnnotation)
//            classifyAnnotation(TradeAnnotation)
//            if canShow{
//                print("canShow")
//                self.mapView.addAnnotation(TradeAnnotation)
//            }else{
//                print("canNotShow")
//            }
//        }
        
        var canShow = false
        canShow = decideCanShowOrNotAndWhichIcon(TradeAnnotation)
        classifyAnnotation(TradeAnnotation)
        if canShow{
            self.mapView.addAnnotation(TradeAnnotation)
        }

    }
    
    func getPersonData() {
        
        let ref =  Database.database().reference(withPath: "PersonAnnotation")
        ref.queryOrdered(byChild: "openTime").observeSingleEvent(of: .value, with: { (snapshot) in
            //先將TradeAnnotationData做成TradeAnnotation
            for user_child in (snapshot.children){
                self.packageTradeAnnotation(user_child)
            }})
    }
    
    
    fileprivate func classifyAnnotation(_ annotation: TradeAnnotation) {
        if annotation.isOpenStore {
            openShopAnnotations.append(annotation)
        }
        if annotation.isRequest {
            requestAnnotations.append(annotation)
        }
        if annotation.isTeamUp {
            teamUpAnnotations.append(annotation)
        }
        
        if annotation.wantMakeFriend {
            switch annotation.gender {
            case .Boy:
                boySayHiAnnotations.append(annotation)
                break
            case .Girl:
                girlSayHiAnnotations.append(annotation)
                break
            }
        }
    }
    
    
    
    func decideCanShowOrNotAndWhichIcon(_ annotation:TradeAnnotation) -> Bool{
        
        var canShow = false
        annotation.markTypeToShow = .none
        ////決定是否要顯示這個annotation
        //使用者想要認識男生
        if UserSetting.isMapShowMakeFriend_Boy{
            //對方是男生
            if  annotation.gender == .Boy{
                //對方想被認識
                if annotation.wantMakeFriend{
                    canShow = true
                    if  annotation.preferMarkType == .makeFriend{
                        annotation.markTypeToShow = .makeFriend
                    }
                }
            }
        }
        //使用者想要認識女生
        if UserSetting.isMapShowMakeFriend_Girl{
            //對方是女生
            if  annotation.gender == .Girl{
                //對方想被認識
                if annotation.wantMakeFriend{
                    canShow = true
                    if annotation.preferMarkType == .makeFriend{
                        annotation.markTypeToShow = .makeFriend
                    }
                }
            }
        }
        if UserSetting.isMapShowOpenStore{
            if annotation.isOpenStore{
                canShow = true
                if annotation.preferMarkType == .openStore{
                    annotation.markTypeToShow = .openStore
                }
            }
        }
        if UserSetting.isMapShowRequest{
            if annotation.isRequest{
                canShow = true
                if annotation.preferMarkType == .request{
                    annotation.markTypeToShow = .request
                }
            }
        }
        if UserSetting.isMapShowTeamUp{
            if annotation.isTeamUp {
                canShow = true
                if annotation.preferMarkType == .teamUp{
                    annotation.markTypeToShow = .teamUp
                }
            }
        }
        
        ////如果還未指派哪個icon，依照順序指派下去
        if annotation.markTypeToShow == .none{
            //                print("未指派")
            if UserSetting.isMapShowMakeFriend_Girl{
                if  annotation.gender == .Girl{
                    if annotation.wantMakeFriend{
                        annotation.markTypeToShow = .makeFriend
                    }
                }
            }
            if UserSetting.isMapShowMakeFriend_Boy{
                if  annotation.gender == .Boy{
                    if annotation.wantMakeFriend{
                        annotation.markTypeToShow = .makeFriend
                    }
                }
            }
            if UserSetting.isMapShowRequest{
                if annotation.isRequest{
                    annotation.markTypeToShow = .request
                }
            }
            if UserSetting.isMapShowOpenStore{
                if annotation.isOpenStore{
                    annotation.markTypeToShow = .openStore
                }
            }
            if UserSetting.isMapShowTeamUp{
                if annotation.isTeamUp{
                    annotation.markTypeToShow = .openStore
                }
            }
        }
        
        if canShow{
            return true
        }
        
        return false
    }
    
    func decideCanShowOrNotAndWhichIcon(_ annotations:[TradeAnnotation]) -> [TradeAnnotation]{
        
        var annotationsCanShow : [TradeAnnotation] = []
        
        for annotation in annotations{
            var canShow = false
            annotation.markTypeToShow = .none
            ////決定是否要顯示這個annotation
            //使用者想要認識男生
            if UserSetting.isMapShowMakeFriend_Boy{
                //對方是男生
                if  annotation.gender == .Boy{
                    //對方想被認識
                    if annotation.wantMakeFriend{
                        canShow = true
                        if  annotation.preferMarkType == .makeFriend{
                            annotation.markTypeToShow = .makeFriend
                        }
                    }
                }
            }
            //使用者想要認識女生
            if UserSetting.isMapShowMakeFriend_Girl{
                //對方是女生
                if  annotation.gender == .Girl{
                    //對方想被認識
                    if annotation.wantMakeFriend{
                        canShow = true
                        if annotation.preferMarkType == .makeFriend{
                            annotation.markTypeToShow = .makeFriend
                        }
                    }
                }
            }
            if UserSetting.isMapShowOpenStore{
                if annotation.isOpenStore{
                    canShow = true
                    if annotation.preferMarkType == .openStore{
                        annotation.markTypeToShow = .openStore
                    }
                }
            }
            if UserSetting.isMapShowRequest{
                if annotation.isRequest{
                    canShow = true
                    if annotation.preferMarkType == .request{
                        annotation.markTypeToShow = .request
                    }
                }
            }
            if UserSetting.isMapShowTeamUp{
                if annotation.isTeamUp {
                    canShow = true
                    if annotation.preferMarkType == .teamUp{
                        annotation.markTypeToShow = .teamUp
                    }
                }
            }
            
            if canShow{
                annotationsCanShow.append(annotation)
            }else{
                continue
            }
            
            
            ////如果還未指派哪個icon，依照順序指派下去
            if annotation.markTypeToShow == .none{
                //                print("未指派")
                if UserSetting.isMapShowMakeFriend_Girl{
                    if  annotation.gender == .Girl{
                        if annotation.wantMakeFriend{
                            annotation.markTypeToShow = .makeFriend
                        }
                    }
                }
                if UserSetting.isMapShowMakeFriend_Boy{
                    if  annotation.gender == .Boy{
                        if annotation.wantMakeFriend{
                            annotation.markTypeToShow = .makeFriend
                        }
                    }
                }
                if UserSetting.isMapShowRequest{
                    if annotation.isRequest{
                        annotation.markTypeToShow = .request
                    }
                }
                if UserSetting.isMapShowOpenStore{
                    if annotation.isOpenStore{
                        annotation.markTypeToShow = .openStore
                    }
                }
                if UserSetting.isMapShowTeamUp{
                    if annotation.isTeamUp{
                        annotation.markTypeToShow = .teamUp
                    }
                }
            }
        }
        return annotationsCanShow
    }
    
    fileprivate func GetFakeAnnotations() -> [TradeAnnotation] {
        
        var annotations : [TradeAnnotation] = []
        let annotation = TradeAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude:  25.053227, longitude: 121.527007)
        annotation.title = "好難過，只求一醉⋯⋯"
        annotation.isRequest = true
        annotation.preferMarkType = .request
        annotation.wantMakeFriend = true
        annotation.gender = .Boy
        annotations.append(annotation)
        
        let annotation2 = TradeAnnotation()
        annotation2.coordinate = CLLocationCoordinate2D(latitude:  25.054070, longitude: 121.523923)
        annotation2.title = "桌遊團 -2"
        annotation2.preferMarkType = .teamUp
        annotation2.isTeamUp = true
        annotation2.wantMakeFriend = true
        annotations.append(annotation2)
        
        let annotation3 = TradeAnnotation()
        annotation3.coordinate = CLLocationCoordinate2D(latitude:  25.052722, longitude: 121.523527)
        annotation3.title = "童·叟·無·欺"
        annotation3.isOpenStore = true
        annotation3.isRequest = true
//        annotation3.smallHeadShot = UIImage(named: "Thumbnail")
        annotation3.preferMarkType = .openStore
        annotations.append(annotation3)
        
        let annotation4 = TradeAnnotation()
        annotation4.coordinate = CLLocationCoordinate2D(latitude:  25.052724, longitude: 121.526130)
        annotation4.title = "貂蟬"
        annotation4.isOpenStore = true
        annotation4.preferMarkType = .makeFriend
        annotation4.wantMakeFriend = true
        annotation4.gender = .Girl
        
        annotations.append(annotation4)
        
        return annotations
    }
    
    
    func reFreshUserAnnotation(smallHeadShot:UIImage? = nil,refreshLocation: Bool = true){
        if let annotation = userAnnotation{
            mapView.removeAnnotation(annotation)
            
            annotation.isOpenStore = UserSetting.isWantSellSomething
            annotation.isRequest = UserSetting.isWantBuySomething
            annotation.isTeamUp = UserSetting.isWantTeamUp
            annotation.wantMakeFriend = UserSetting.isWantMakeFriend
            annotation.openTime = Date().getCurrentTimeString()
            annotation.title = UserSetting.storeName
            if refreshLocation{
                annotation.coordinate = CLLocationCoordinate2D(latitude:  CLLocationDegrees((UserSetting.userLatitude as NSString).floatValue), longitude: CLLocationDegrees((UserSetting.userLongitude as NSString).floatValue))
            }
            
            if UserSetting.perferIconStyleToShowInMap == "openStore"{
                annotation.preferMarkType = .openStore
            }else if UserSetting.perferIconStyleToShowInMap == "request"{
                annotation.preferMarkType = .request
            }else if  UserSetting.perferIconStyleToShowInMap == "makeFriend"{
                annotation.preferMarkType = .makeFriend
            }else if  UserSetting.perferIconStyleToShowInMap == "teamUp"{
                annotation.preferMarkType = .teamUp
            }else{
                annotation.preferMarkType = .none
            }
            
            let temp = decideCanShowOrNotAndWhichIcon([annotation])
            if temp.count > 0{
                userAnnotation = temp[0]
                mapView.addAnnotation(userAnnotation!)
            }
        }else{
            
            let annotation = TradeAnnotation()
            if UserSetting.userGender == 0 {
                annotation.gender = .Girl
            }else{
                annotation.gender = .Boy
            }
            annotation.UID = UserSetting.UID
            annotation.userName = UserSetting.userName
            annotation.isOpenStore = UserSetting.isWantSellSomething
            annotation.isRequest = UserSetting.isWantBuySomething
            annotation.isTeamUp = UserSetting.isWantTeamUp
            annotation.wantMakeFriend = UserSetting.isWantMakeFriend
            annotation.openTime = Date().getCurrentTimeString()
            annotation.title = UserSetting.storeName
            if refreshLocation{
                annotation.coordinate = CLLocationCoordinate2D(latitude:  CLLocationDegrees((UserSetting.userLatitude as NSString).floatValue), longitude: CLLocationDegrees((UserSetting.userLongitude as NSString).floatValue))
            }
            
            if UserSetting.perferIconStyleToShowInMap == "openStore"{
                annotation.preferMarkType = .openStore
            }else if UserSetting.perferIconStyleToShowInMap == "request"{
                annotation.preferMarkType = .request
            }else if  UserSetting.perferIconStyleToShowInMap == "makeFriend"{
                annotation.preferMarkType = .makeFriend
            }else if  UserSetting.perferIconStyleToShowInMap == "teamUp"{
                annotation.preferMarkType = .teamUp
            }else{
                annotation.preferMarkType = .none
            }
            let temp = decideCanShowOrNotAndWhichIcon([annotation])
            if temp.count > 0{
                userAnnotation = temp[0]
                mapView.addAnnotation(userAnnotation!)
            }
            
        }
        
    }
    
    
    
}


