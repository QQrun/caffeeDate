//
//  NotifyCenterViewControllerModel.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/09/24.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Firebase


protocol NotifyCenterViewControllerModelDelegate: class {
    func reloadData()
    func gotoItemView(item:Item,itemOwnerID:String)
    func showToast(message:String)
}
class NotifyCenterViewControllerModel{
    
    weak var delegate: NotifyCenterViewControllerModelDelegate?
    
    var postNotifcations : [PostNotifcation] = []
    
    func startListenPostNotifcations(){
        let notifyListObserverRef = Database.database().reference(withPath: "Notification/" + UserSetting.UID)
        
        notifyListObserverRef.observe(.childAdded, with: { (snapshot) in
            self.postNotifcations.append(PostNotifcation(snapshot: snapshot))
            self.postNotifcations.sort{ (date1, date2) -> Bool in
                return date1.time.compare(date2.time) == ComparisonResult.orderedDescending
            }
            self.delegate?.reloadData()
        })
        
        notifyListObserverRef.observe(.childChanged, with: { (snapshot) in
            let newPostNotifcation = PostNotifcation(snapshot: snapshot)
            for i in 0 ... self.postNotifcations.count - 1{
                if self.postNotifcations[i].itemID == newPostNotifcation.itemID{
                    self.postNotifcations[i] = newPostNotifcation
                }
            }
            self.postNotifcations.sort{ (date1, date2) -> Bool in
                return date1.time.compare(date2.time) == ComparisonResult.orderedDescending
            }
            self.delegate?.reloadData()
        })
    }
    
    func configure(cell: NotifyTableViewCell, at indexPath: IndexPath) {
        cell.backgroundColor = .clear
        if indexPath.row % 2 == 1{
            cell.separator.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
        cell.time.textColor = .on().withAlphaComponent(0.9)
        cell.time.font = UIFont(name: "HelveticaNeue-Medium", size: 13)
        cell.time.text = postNotifcations[indexPath.row].time
        let currentTime = Date()
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "YYYYMMddHHmmss"
        var finalTimeString = ""
        if let commmentTime = dateFormatter.date(from: postNotifcations[indexPath.row].time){
            
            let elapsedYear = currentTime.years(sinceDate: commmentTime) ?? 0
            var elapsedMonth = currentTime.months(sinceDate: commmentTime) ?? 0
            elapsedMonth %= 12
            var elapsedDay = currentTime.days(sinceDate: commmentTime) ?? 0
            elapsedDay %= 30
            var elapsedHour = currentTime.hours(sinceDate: commmentTime) ?? 0
            elapsedHour %= 24
            var elapsedMinute = currentTime.minutes(sinceDate: commmentTime) ?? 0
            elapsedMinute %= 60
            var elapsedSecond = currentTime.seconds(sinceDate: commmentTime) ?? 0
            elapsedSecond %= 60
            
            if elapsedYear > 0 {
                finalTimeString = "\(elapsedYear)" + "年前"
            }else if elapsedMonth > 0{
                finalTimeString = "\(elapsedMonth)" + "個月前"
            }else if elapsedDay > 0{
                finalTimeString = "\(elapsedDay)" + "天前"
            }else if elapsedHour > 0{
                finalTimeString = "\(elapsedHour)" + "小時前"
            }else if elapsedMinute > 0{
                finalTimeString = "\(elapsedMinute)" + "分前"
            }else {
                finalTimeString = "剛剛"
            }
        }
        cell.time.text = finalTimeString
        
        
        cell.body.textColor = .on().withAlphaComponent(0.9)
        cell.body.font = UIFont(name: "HelveticaNeue-Medium", size: 13)
        
        if postNotifcations[indexPath.row].isRead{
            cell.time.textColor = .on().withAlphaComponent(0.5)
            cell.body.textColor = .on().withAlphaComponent(0.5)
        }
        postNotifcations[indexPath.row].reviewers.sort{ (date1, date2) -> Bool in
            return date1.time.compare(date2.time) == ComparisonResult.orderedDescending
        }
        
        
        var textpart = ""
        if postNotifcations[indexPath.row].notifcationType == .MyItemHasRespond{
            textpart = "您的貼文《" + postNotifcations[indexPath.row].itemName + "》"
        }else if postNotifcations[indexPath.row].notifcationType == .OtherItemHasRespond{
            textpart = "貼文《" + postNotifcations[indexPath.row].itemName + "》"
        }
        
        if postNotifcations[indexPath.row].reviewers.count == 0{
            cell.body.text = "有人回應了" + textpart
        }else if postNotifcations[indexPath.row].reviewers.count == 1{
            cell.body.text =  "\(postNotifcations[indexPath.row].reviewers[0].name)" + "回應了" + textpart
        }else if postNotifcations[indexPath.row].reviewers.count == 2{
            cell.body.text =  "\(postNotifcations[indexPath.row].reviewers[0].name)" + "\(postNotifcations[indexPath.row].reviewers[1].name)"  + "回應了" + textpart
        }else{
            cell.body.text =  "\(postNotifcations[indexPath.row].reviewers[0].name)、" + "\(postNotifcations[indexPath.row].reviewers[1].name)" +
                "和其他" + "\(postNotifcations[indexPath.row].reviewers.count - 2)" + "人回應了" + textpart
        }
        
        
        
    }
    
    func didSelectRowAt(cell: NotifyTableViewCell,indexPath:IndexPath){
        
        if !postNotifcations[indexPath.row].isRead {
            cell.body.textColor = UIColor.hexStringToUIColor(hex: "9B9B9B")
            cell.time.textColor = UIColor.hexStringToUIColor(hex: "9B9B9B")
            
            let isReadRef = Database.database().reference(withPath: "Notification/" + "\(UserSetting.UID)/" + "\(postNotifcations[indexPath.row].itemID)/" + "isRead")
            isReadRef.setValue("1")
        }
        
        var ref = Database.database().reference()
        if postNotifcations[indexPath.row].iWantType == .Buy {
            ref = Database.database().reference().child("PersonDetail/" + "\(postNotifcations[indexPath.row].posterID)/" + "BuyItems" + "/" + "\(postNotifcations[indexPath.row].itemID)")
        }else if postNotifcations[indexPath.row].iWantType == .Sell{
            ref = Database.database().reference().child("PersonDetail/" + "\(postNotifcations[indexPath.row].posterID)/" + "SellItems" + "/" + "\(postNotifcations[indexPath.row].itemID)")
        }
        ref.observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.exists(){
                Analytics.logEvent("通知_前往貼文頁", parameters:nil)
                self.delegate?.gotoItemView(item: Item(snapshot: snapshot), itemOwnerID: self.postNotifcations[indexPath.row].posterID)
            }else{
                Analytics.logEvent("通知_文章已下架", parameters:nil)
                self.delegate?.showToast(message: "文章已下架")
            }
        })
        
        
        
        
    }
    
}
