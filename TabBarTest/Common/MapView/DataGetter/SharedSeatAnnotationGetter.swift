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
        sharedSeatAnnotation.headCount = sharedSeatAnnotationData.headCount
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
        
        
        if(annotation.headCount == 2){
            sharedSeat2Annotation.append(annotation)
            if(UserSetting.isMapShowSharedSeat2){
                return true
            }
            
        }else if(annotation.headCount == 4){
            sharedSeat4Annotation.append(annotation)
            if(UserSetting.isMapShowSharedSeat4){
                return true
            }
        }
        
        return false
    }
}
