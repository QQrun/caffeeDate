//
//  SharedSeatAnnotationGetter.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2022/03/07.
//  Copyright © 2022 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import MapKit
import Firebase
import Alamofire

class SharedSeatAnnotationGetter{
    
    var mapView : MKMapView
    
    var sharedSeat2Annotation : [SharedSeatAnnotation] = []
    var sharedSeat4Annotation : [SharedSeatAnnotation] = []
    var sharedSeatMyJoinedAnnotation : [SharedSeatAnnotation] = []{
        didSet{
            if sharedSeatMyJoinedAnnotation.count == 0{
                CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.circleButton_mySharedSeat.isHidden = true
            }else{
                CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.circleButton_mySharedSeat.isHidden = false
            }
        }
    }
    
    
//    circleButton_mySharedSeat
    
    
    init(mapView:MKMapView) {
        self.mapView = mapView
    }

    func fetchSharedSeatData() {
        
        let ref =  Database.database().reference(withPath: "SharedSeatAnnotation")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            //先將personAnnotationData做成personAnnotation
            for user_child in (snapshot.children){
                self.packageSharedSeatAnnotation(user_child)
            }})
        
    }
    
    fileprivate func packageSharedSeatAnnotation(_ user_child: NSEnumerator.Element) {
        
        let user_snap = user_child as! DataSnapshot
        
        let sharedSeatAnnotationData = SharedSeatAnnotationData(snapshot: user_snap)
        
        if(sharedSeatAnnotationData.dateTime == ""){ //這代表解包失敗
            return
        }
        
        let sharedSeatAnnotation = SharedSeatAnnotation()
        
        sharedSeatAnnotation.title = sharedSeatAnnotationData.restaurant
        sharedSeatAnnotation.holderUID = user_snap.key
        sharedSeatAnnotation.address = sharedSeatAnnotationData.address
        sharedSeatAnnotation.girlsID = sharedSeatAnnotationData.girlsID
        sharedSeatAnnotation.boysID = sharedSeatAnnotationData.boysID
        sharedSeatAnnotation.signUpGirlsID = sharedSeatAnnotationData.signUpGirlsID
        sharedSeatAnnotation.signUpBoysID = sharedSeatAnnotationData.signUpBoysID
        sharedSeatAnnotation.dateTime = sharedSeatAnnotationData.dateTime
        sharedSeatAnnotation.reviewTime = sharedSeatAnnotationData.reviewTime
        sharedSeatAnnotation.mode = sharedSeatAnnotationData.mode
        sharedSeatAnnotation.photosUrl = sharedSeatAnnotationData.photosUrl
        
        
        //確認那個地點是否有過期，如果有過期，不顯示
        //TODO
        
        sharedSeatAnnotation.coordinate = CLLocationCoordinate2D(latitude:  CLLocationDegrees((sharedSeatAnnotationData.latitude as NSString).floatValue), longitude: CLLocationDegrees((sharedSeatAnnotationData.longitude as NSString).floatValue))

        
        var canShow = false
        canShow = decideCanShowOrNotAndWhichIcon(sharedSeatAnnotation)
        if canShow{
            self.mapView.addAnnotation(sharedSeatAnnotation)
        }
        
    }
    //1.賦予markTypeToShow 2.將Annotation分類 3.判斷是否要顯示在地圖上
    func decideCanShowOrNotAndWhichIcon(_ annotation:SharedSeatAnnotation) -> Bool{
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMddHHmmss"
        let dateTime = dateFormatter.date(from: annotation.dateTime)!
        let drawTime = dateFormatter.date(from: annotation.reviewTime)!
        
        //已過約會時間三個鐘頭，任何人都可以自動下架此聚會
        if(Int(Date() - dateTime) > 60 * 60 * 3){
            FirebaseHelper.deleteSharedSeatAnnotation(annotation:annotation)
            return false
        }
        
        if(Int(Date() - drawTime) > 0){
            
            //如果自己是舉辦人
            if(UserSetting.UID == annotation.holderUID){
                if(UserSetting.userGender == 0){
                    if(annotation.mode == 1){
                        if(annotation.boysID == nil){
                            CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.showToast(message: "您的聚會過了抽卡時間未抽卡，已自動下架")
                            FirebaseHelper.deleteSharedSeatAnnotation(annotation:annotation)
                            return false
                        }
                        if(annotation.boysID != nil && annotation.boysID!.count == 0){
                            CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.showToast(message: "您的聚會過了抽卡時間未抽卡，已自動下架")
                            FirebaseHelper.deleteSharedSeatAnnotation(annotation:annotation)
                            return false
                        }
                    }
                    if(annotation.mode == 2){
                        if(annotation.boysID == nil){
                            CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.showToast(message: "您的聚會過了抽卡時間未抽卡，已自動下架")
                            FirebaseHelper.deleteSharedSeatAnnotation(annotation:annotation)
                            return false
                        }else{
                            if(annotation.girlsID!.count != 2){
                                CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.showToast(message: "您的聚會未加入同性同行者，已自動下架")
                                FirebaseHelper.deleteSharedSeatAnnotation(annotation:annotation)
                                return false
                            }else if(annotation.boysID!.count != 2){
                                CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.showToast(message: "您的聚會過了抽卡時間未抽卡，已自動下架")
                                FirebaseHelper.deleteSharedSeatAnnotation(annotation:annotation)
                                return false
                            }
                        }
                    }
                }
                if(UserSetting.userGender == 1){
                    if(annotation.mode == 1){
                        if(annotation.girlsID == nil){
                            CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.showToast(message: "您的聚會過了抽卡時間未抽卡，已自動下架")
                            FirebaseHelper.deleteSharedSeatAnnotation(annotation:annotation)
                            return false
                        }
                        if(annotation.girlsID != nil && annotation.girlsID!.count == 0){
                            CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.showToast(message: "您的聚會過了抽卡時間未抽卡，已自動下架")
                            FirebaseHelper.deleteSharedSeatAnnotation(annotation:annotation)
                            return false
                        }
                    }
                    if(annotation.mode == 2){
                        if(annotation.girlsID == nil){
                            CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.showToast(message: "您的聚會過了抽卡時間未抽卡，已自動下架")
                            FirebaseHelper.deleteSharedSeatAnnotation(annotation:annotation)
                            return false
                        }else{
                            if(annotation.boysID!.count != 2){
                                CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.showToast(message: "您的聚會未加入同性同行者，已自動下架")
                                FirebaseHelper.deleteSharedSeatAnnotation(annotation:annotation)
                                return false
                            }else if(annotation.girlsID!.count != 2){
                                CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.showToast(message: "您的聚會過了抽卡時間未抽卡，已自動下架")
                                FirebaseHelper.deleteSharedSeatAnnotation(annotation:annotation)
                                return false
                            }
                        }
                    }
                }
            }else{
                //如果自己不是舉辦人
                if(annotation.boysID != nil && annotation.boysID![UserSetting.UID] != nil){
                    //如果自己是參加人
                }else if(annotation.girlsID != nil && annotation.girlsID![UserSetting.UID] != nil){
                    //如果自己是參加人
                }else{
                    //如果自己不是舉辦人不是參加人，又過了抽卡時間，不顯示
                    return false
                }

            }
        }
        
        
        //如果自己有參加，就加入sharedSeatMyJoinedAnnotation
        if(annotation.boysID != nil){
            if(annotation.boysID![UserSetting.UID] != nil){
                sharedSeatMyJoinedAnnotation.append(annotation)
            }
        }
        if(annotation.girlsID != nil){
            if(annotation.girlsID![UserSetting.UID] != nil){
                sharedSeatMyJoinedAnnotation.append(annotation)
            }
        }
        
        if(annotation.mode == 1){
            sharedSeat2Annotation.append(annotation)
            if(UserSetting.isMapShowSharedSeat2){
                return true
            }
        }else if(annotation.mode == 2){
            sharedSeat4Annotation.append(annotation)
            if(UserSetting.isMapShowSharedSeat4){
                return true
            }
        }
        
        return false
    }
}
