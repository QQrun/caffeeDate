//
//  FirebaseHelper.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/05/13.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import Firebase
import Alamofire
import PromiseKit

enum FirebaseStorageError: Error {
    case noData
}

class FirebaseHelper{
    
    
    //completion (url:String) ->()
    static func putThumbnail(image:UIImage,completion: @escaping ((String) -> ())){
        var smallCompressedPhoto = image.imageWithNewSize(size: CGSize(width: 200, height: 200))
        smallCompressedPhoto = smallCompressedPhoto!.compressQuality(maxLength: 1500000)
        let storageRefForItemSmallPhoto = Storage.storage().reference().child("thumbnailUrl/" + NSUUID().uuidString)
        
        
        if let smallCompressedPhotoUploadData = smallCompressedPhoto!.jpegData(compressionQuality: 1){
            storageRefForItemSmallPhoto.putData(smallCompressedPhotoUploadData,metadata: nil,completion: {
                (metadata,error) in
                if error != nil {
                    print(error ?? "上傳item的thumbnail失敗")
                }
                
                storageRefForItemSmallPhoto.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        print(error ?? "thumbnailUrl產生url失敗")
                        return
                    }
                    completion(downloadURL.absoluteString)
                }
            }
        )}
    }

    //completion (url:String) ->()
    static func putItemPhoto(image:UIImage,completion: @escaping ((String) -> ())){
        
        var compressedPhoto = image.imageWithNewSize(size: CGSize(width: 1024, height: 1024))
        compressedPhoto = compressedPhoto!.compressQuality(maxLength: 1024 * 1024)//照片的目標壓縮大小

        let storageRefForItemPhoto = Storage.storage().reference().child("itemPhoto/" + NSUUID().uuidString)
        
        if let compressedPhotoUploadData = compressedPhoto!.jpegData(compressionQuality: 1){
            storageRefForItemPhoto.putData(compressedPhotoUploadData,metadata: nil,completion: {
                (metadata,error) in
                if error != nil {
                    print(error ?? "上傳item的photo失敗")
                }
                
                storageRefForItemPhoto.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        print(error ?? "itemPhoto產生url失敗")
                        return
                    }
                    completion(downloadURL.absoluteString)
                }
            }
        )}
    }
    
    static func uploadItemImage(_ image: UIImage) -> Promise<URL> {
        return Promise<URL> { seal in
            if let data = image.jpegData(compressionQuality: 1) {
                let ref = Storage.storage().reference().child("itemPhoto/" + NSUUID().uuidString + ".jpg")
                ref.putData(data, metadata: nil) { meta, error in
                    if let error = error {
                        seal.reject(error)
                    } else {
                        ref.downloadURL { url, error in
                            if let error = error {
                                seal.reject(error)
                            } else if let url = url {
                                seal.fulfill(url)
                            }
                        }
                    }
                }
            } else {
                seal.reject(FirebaseStorageError.noData)
            }
        }
    }

    

    //completion (url:String) ->()
    static func putUserPhoto(image:UIImage,completion: @escaping ((String) -> ())){
        
        var compressedPhoto = image.imageWithNewSize(size: CGSize(width: 1024, height: 1024))
        compressedPhoto = compressedPhoto!.compressQuality(maxLength: 1024 * 1024)//照片的目標壓縮大小

        let storageRefForItemPhoto = Storage.storage().reference().child("userPhoto/" + UserSetting.UID + "/" + NSUUID().uuidString)
        
        if let compressedPhotoUploadData = compressedPhoto!.jpegData(compressionQuality: 1){
            storageRefForItemPhoto.putData(compressedPhotoUploadData,metadata: nil,completion: {
                (metadata,error) in
                if error != nil {
                    print(error ?? "上傳user的photo失敗")
                }
                
                storageRefForItemPhoto.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        print(error ?? "userPhoto產生url失敗")
                        return
                    }
                    completion(downloadURL.absoluteString)
                }
            }
        )}
    }
    
    //此func包含更新firebase DataBase 跟 firebase Storage
    //completion (url:String) ->()
    static func putUserSmallHeadShot(image:UIImage,completion: @escaping ((String) -> ())){
        
        var compressedPhoto = image.imageWithNewSize(size: CGSize(width: 150, height: 150))
        compressedPhoto = compressedPhoto!.compressQuality(maxLength:100000)//照片的目標壓縮大小

        let storageRefForItemPhoto = Storage.storage().reference().child("userSmallHeadShot/" + UserSetting.UID)
        
        if let compressedPhotoUploadData = compressedPhoto!.jpegData(compressionQuality: 1){
            storageRefForItemPhoto.putData(compressedPhotoUploadData,metadata: nil,completion: {
                (metadata,error) in
                if error != nil {
                    print(error ?? "上傳user的thumbnail失敗")
                }
                
                storageRefForItemPhoto.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        print(error ?? "userSmallHeadShot產生url失敗")
                        return
                    }
                    
                    let ref2 = Database.database().reference().child("PersonDetail/" + UserSetting.UID + "/headShot")
                    ref2.setValue(downloadURL.absoluteString)
                    
                    completion(downloadURL.absoluteString)
                }
            }
        )}
    }
    
    static func updateSignInTime(){
        let lastSignInTimeRef = Database.database().reference().child("PersonDetail/" +  Auth.auth().currentUser!.uid + "/lastSignInTime")
        lastSignInTimeRef.setValue(Date().getCurrentTimeString()){ (error, ref) -> Void in
            if error != nil{
                print(error ?? "updateSignInTime失敗")
            }
        }
        updateToken()
    }
    
    
    static func updateToken(){
        let tokenRef = Database.database().reference().child("PersonDetail/" +  Auth.auth().currentUser!.uid + "/token")
        
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            print("FCM registration token: \(token)")
            tokenRef.setValue(token)
          }
        }
    }
    
    static func updateTradeAnnotation(){
        //上傳TradeAnnotation
        let mapViewController = CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController
        if mapViewController != nil{
            UserSetting.userLatitude = String(format: "%f", (mapViewController!.mapView.userLocation.coordinate.latitude))
            UserSetting.userLongitude = String(format: "%f", (mapViewController!.mapView.userLocation.coordinate.longitude))
        }
        
        let currentTimeString = Date().getCurrentTimeString()
        let myAnnotation = TradeAnnotationData(openTime: currentTimeString, title: UserSetting.storeName, gender: UserSetting.userGender, isOpenStore: UserSetting.isWantSellSomething, isRequest: UserSetting.isWantBuySomething, latitude: UserSetting.userLatitude, longitude: UserSetting.userLongitude)
        
        let ref = Database.database().reference()
        let personAnnotationWithIDRef = ref.child("PersonAnnotation/" +  UserSetting.UID)
        personAnnotationWithIDRef.setValue(myAnnotation.toAnyObject()){ (error, ref) -> Void in
            if error != nil{
                print(error ?? "上傳TradeAnnotation失敗")
                
            }
            CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController?.presonAnnotationGetter.reFreshUserAnnotation()
        }
    }
    
    static func uploadTradeAnnotation(_ annotation: TradeAnnotationData) -> Promise<Bool> {
        return Promise<Bool> { seal in
            let ref = Database.database().reference().child("PersonAnnotation/" +  UserSetting.UID)
            ref.setValue(annotation.toAnyObject()) { error, ref in
                if let error = error {
                    seal.reject(error)
                } else {
                    seal.fulfill(true)
                }
            }
        }
    }
    
    static func deleteTradeAnnotation(){
        //刪除雲端部分
        let ref = Database.database().reference()
        let personAnnotationWithIDRef = ref.child("PersonAnnotation/" +  UserSetting.UID)
        personAnnotationWithIDRef.removeValue()
        //關掉本地端部分
        let userAnnotation =  CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.presonAnnotationGetter.userAnnotation
        if userAnnotation != nil{
            
            if let oldUserAnnotation = CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.presonAnnotationGetter.userAnnotation{
                CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.mapView.removeAnnotation(oldUserAnnotation)
            }
            CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.presonAnnotationGetter.userAnnotation = nil
        }
        
    }
    
}
