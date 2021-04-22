//
//  itemTableViewDelegate.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/04/13.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//


import Foundation
import UIKit
import Firebase

public class ItemTableViewDelegate :NSObject,UITableViewDataSource,UITableViewDelegate {
    
    var personDetail : PersonDetailInfo!
    var currentItemType : Item.ItemType = .Sell
    
    weak var viewDelegate: MapViewControllerViewDelegate?
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentItemType == .Sell{
            return personDetail.sellItems.count
        }else{
            return personDetail.buyItems.count
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemTableViewCell", for: indexPath) as! ItemTableViewCell
        cell.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        if currentItemType == .Sell{
            cell.nameLabel.text = personDetail.sellItems[indexPath.row].name
            cell.priceLabel.text = "$：" + personDetail.sellItems[indexPath.row].price
        }else if currentItemType == .Buy{
            cell.nameLabel.text = personDetail.buyItems[indexPath.row].name
            cell.priceLabel.text = "賞金：" + personDetail.buyItems[indexPath.row].price
        }
        
        var likeUIDs : [String]!
        if currentItemType == .Sell{
            likeUIDs = personDetail.sellItems[indexPath.row].likeUIDs
        }
        else if currentItemType == .Buy{
            likeUIDs = personDetail.buyItems[indexPath.row].likeUIDs
        }
        cell.heartImage.image = UIImage(named: "空愛心")
        if likeUIDs.count > 99{
            cell.heartNumberLabel.text = "99+"
        }else{
            cell.heartNumberLabel.text = "\(likeUIDs.count)"
        }
        for likeUID in likeUIDs{
            if likeUID == UserSetting.UID{
                cell.userPressLike = true
                cell.heartImage.image = UIImage(named: "實愛心")
            }
        }
        
        let item : Item!
        if currentItemType == .Sell{
            item = personDetail.sellItems[indexPath.row]
        }else {
            item = personDetail.buyItems[indexPath.row]
        }
        
        let commentCount = item.commentIDs!.count
        if commentCount > 99{
            cell.commitNumber.text = "99+"
        }else{
            cell.commitNumber.text = "\(commentCount)"
        }
        
        let oneDegree = CGFloat.pi / 180
        if indexPath.row % 2 == 0{
            cell.separator.transform = CGAffineTransform(rotationAngle: oneDegree * 180)
        }
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        cell.selectedBackgroundView = selectedBackgroundView
        cell.indexOfRow = indexPath.row
        if currentItemType == .Sell{
            cell.itemID = personDetail.sellItems[indexPath.row].itemID
        }else if currentItemType == .Buy{
            cell.itemID = personDetail.buyItems[indexPath.row].itemID
        }
        cell.currentItemType = currentItemType
        cell.personInfo = personDetail
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView,
                          didSelectRowAt indexPath: IndexPath) {
        Analytics.logEvent("地圖_小itemTable_前往商品頁面", parameters:nil)
        // 取消 cell 的選取狀態
        tableView.deselectRow(at: indexPath, animated: false)
        if currentItemType == .Sell{
            viewDelegate?.gotoItemViewController_mapView(item:personDetail.sellItems[indexPath.row],personDetail:personDetail)
        }else {
            viewDelegate?.gotoItemViewController_mapView(item:personDetail.buyItems[indexPath.row],personDetail:personDetail)
        }
    }
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 36;//Choose your custom row height
    }
    
    
}
