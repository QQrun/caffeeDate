//
//  BigItemTableViewDelegate.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/04/17.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Firebase

public class BigItemTableViewDelegate :NSObject,UITableViewDataSource,UITableViewDelegate {
    
    var personDetail : PersonDetailInfo!
    var currentItemType : Item.ItemType = .Sell
    
    weak var shopEditViewDelegate : ShopEditViewControllerViewDelegate?
    weak var mapViewDelegate: MapViewControllerViewDelegate?
    
    var noDataLabel = UILabel()
    
    public var canMoveRow = false
    public var orderChanged = false
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        noDataLabel.removeFromSuperview()
        
        noDataLabel = { () -> UILabel in
            let label = UILabel()
            let str = "沒有資料喔。\n點擊下方按鈕來刊登第一個商品或任務吧！"
            let paraph = NSMutableParagraphStyle()
            paraph.lineSpacing = 8
            let attributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 15),
                              NSAttributedString.Key.paragraphStyle: paraph]
            label.attributedText = NSAttributedString(string: str, attributes: attributes)
            label.numberOfLines = 2
            label.textColor = .gray
            label.textAlignment = .center
            label.font = UIFont(name: "HelveticaNeue", size: 16)
            label.frame = CGRect(x: tableView.frame.width/2 - label.intrinsicContentSize.width/2, y: 45, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            label.tag = 999
            return label
        }()
        
        
        
        if currentItemType == .Sell{
            if shopEditViewDelegate != nil{
                if personDetail.sellItems.count == 0 {
                    tableView.addSubview(noDataLabel)
                }}
            return personDetail.sellItems.count
        }else{
            if shopEditViewDelegate != nil{
                if personDetail.buyItems.count == 0{
                    tableView.addSubview(noDataLabel)
                }}
            return personDetail.buyItems.count
        }
        
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bigItemTableViewCell", for: indexPath) as! BigItemTableViewCell
        
        
        var thumbnail : UIImage?
        var thumbnailUrl : String?
        if currentItemType == .Sell{
            thumbnail = personDetail.sellItems[indexPath.row].thumbnail
            thumbnailUrl = personDetail.sellItems[indexPath.row].thumbnailUrl
        }else if currentItemType == .Buy{
            thumbnail = personDetail.buyItems[indexPath.row].thumbnail
            thumbnailUrl = personDetail.buyItems[indexPath.row].thumbnailUrl
        }
        
        if (thumbnail != nil){
            cell.photo.image = thumbnail!
            cell.photo.contentMode = .scaleAspectFill
            cell.photo.alpha = 1
        }else{
            if cell.viewWithTag(1) == nil{
                let loadingView = UIView(frame: CGRect(x: cell.photo.frame.origin.x  + cell.photo.frame.width/8, y: cell.photo.frame.origin.y + cell.photo.frame.width/8, width: cell.photo.frame.width * 3/4, height: cell.photo.frame.height * 3/4))
                loadingView.layer.cornerRadius = 7
                loadingView.layer.borderWidth = 2.5
                loadingView.layer.borderColor = UIColor.lightGray.cgColor
                loadingView.backgroundColor = .clear
                loadingView.tag = 2
                let imageView = UIImageView(frame: CGRect(x: cell.photo.frame.origin.x  + cell.photo.frame.width/4, y: cell.photo.frame.origin.y + cell.photo.frame.width/4, width: cell.photo.frame.width/2, height: cell.photo.frame.height/2))
                if currentItemType == .Sell{
                    imageView.image = UIImage(named: "icons24ShopLocateFilledBk24")?.withRenderingMode(.alwaysTemplate)
                }else{
                    imageView.image = UIImage(named: "捲軸小icon")?.withRenderingMode(.alwaysTemplate)
                }
                imageView.tintColor = .lightGray
                imageView.tag = 1
                cell.addSubview(loadingView)
                cell.sendSubviewToBack(loadingView)
                cell.addSubview(imageView)
                cell.sendSubviewToBack(imageView)
            }
            
            if let url = thumbnailUrl{
                
                cell.photo.alpha = 0
                
                let type : Item.ItemType!
                if(self.currentItemType == .Sell){
                    type = .Sell
                }else{
                    type = .Buy
                }
                
                AF.request(url).response { (response) in
                    guard let data = response.data, let image = UIImage(data: data)
                    else { return }
                    
                    
                    if type == .Sell{
                        self.personDetail.sellItems[indexPath.row].thumbnail = image
                    }else if type == .Buy{
                        self.personDetail.buyItems[indexPath.row].thumbnail = image
                    }
                    cell.photo.image = image
                    UIView.animate(withDuration: 0.4, animations: {
                        cell.photo.alpha = 1
                    }, completion: { result -> Void in
                        cell.viewWithTag(1)?.removeFromSuperview()
                        cell.viewWithTag(2)?.removeFromSuperview()
                        })
                    cell.photo.contentMode = .scaleAspectFill
                }
            }
        }
        
        if currentItemType == .Sell{
            cell.nameLabel.text = personDetail.sellItems[indexPath.row].name
            cell.priceLabel.text = "$：" + personDetail.sellItems[indexPath.row].price
            cell.descriptLabel.text = personDetail.sellItems[indexPath.row].descript
            cell.itemID = personDetail.sellItems[indexPath.row].itemID
        }else if currentItemType == .Buy{
            cell.nameLabel.text = personDetail.buyItems[indexPath.row].name
            cell.priceLabel.text = "賞金：" + personDetail.buyItems[indexPath.row].price
            cell.descriptLabel.text = personDetail.buyItems[indexPath.row].descript
            cell.itemID = personDetail.buyItems[indexPath.row].itemID
        }
        
        var likeUIDs : [String]!
        if currentItemType == .Sell{
            likeUIDs = personDetail.sellItems[indexPath.row].likeUIDs
        }
        else if currentItemType == .Buy{
            likeUIDs = personDetail.buyItems[indexPath.row].likeUIDs
        }
        cell.heartImage.image = UIImage(named: "空愛心")?.withRenderingMode(.alwaysTemplate)
        if likeUIDs.count > 99{
            cell.heartNumberLabel.text = "99+"
        }else{
            cell.heartNumberLabel.text = "\(likeUIDs.count)"
        }
        for likeUID in likeUIDs{
            if likeUID == UserSetting.UID{
                cell.userPressLike = true
                cell.heartImage.image = UIImage(named: "實愛心")?.withRenderingMode(.alwaysTemplate)
            }
        }
        
        let item : Item!
        if currentItemType == .Sell{
            item = personDetail.sellItems[indexPath.row]
        }
        else{
            item = personDetail.buyItems[indexPath.row]
        }
        let commentCount = item.commentIDs!.count
        if commentCount > 99{
            cell.commitNumber.text = "99+"
        }else{
            cell.commitNumber.text = "\(commentCount)"
        }
        
        cell.descriptLabel.numberOfLines = 0
        cell.descriptLabel.textAlignment = .left
        cell.descriptLabel.frame = CGRect(x: 9 + 88 + 6, y: 30, width: UIScreen.main.bounds.size.width - 143, height: 50)
//        cell.descriptLabel.sizeToFit()
//        //66.4是三行的高度 如果超過四行，就縮小
//        if cell.descriptLabel.frame.height > 50{
//            cell.descriptLabel.frame = CGRect(x: 9 + 88 + 6, y: 30, width: UIScreen.main.bounds.size.width - 143, height: 50)
//        }
        
        let oneDegree = CGFloat.pi / 180
        if indexPath.row % 2 == 1{
            cell.separator.transform = CGAffineTransform(rotationAngle: oneDegree * 180)
        }
        
        if shopEditViewDelegate != nil{
            cell.reportBtn.alpha = 0
            cell.optionsBtn.isHidden = false
        }else{
            cell.optionsBtn.isHidden = true
        }
        
        
        cell.indexOfRow = indexPath.row
        cell.mapViewDelegate = mapViewDelegate
        cell.shopEditViewDelegate = shopEditViewDelegate
        cell.personInfo = personDetail
        cell.currentItemType = currentItemType
        
        cell.backgroundColor = .clear
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        cell.selectedBackgroundView = selectedBackgroundView
        return cell
    }
    
    public func tableView(_ tableView: UITableView,
                          didSelectRowAt indexPath: IndexPath) {
        // 取消 cell 的選取狀態
        tableView.deselectRow(at: indexPath, animated: false)
        
        var item : Item!
        if currentItemType == .Sell{
            item = personDetail.sellItems[indexPath.row]
        }else if currentItemType == .Buy{
            item = personDetail.buyItems[indexPath.row]
        }
        
        if let delegate = shopEditViewDelegate{
            delegate.gotoItemViewController_shopEditView(item:item,personDetail : personDetail)
        }else{
            Analytics.logEvent("地圖_大itemTable_前往商品頁面", parameters:nil)
            let itemViewController = ItemViewController(item : item,personInfo: personDetail)
            itemViewController.modalPresentationStyle = .overCurrentContext
            if let viewController = CoordinatorAndControllerInstanceHelper.rootCoordinator.rootTabBarController.selectedViewController{
                (viewController as! UINavigationController).pushViewController(itemViewController, animated: true)
            }
        }
    }
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 110;//Choose your custom row height
    }
    
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return canMoveRow
    }
    
    
    // 編輯狀態時 拖曳切換 cell 位置後執行動作的方法
    // (必須實作這個方法才會出現排序功能)
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        if currentItemType == .Sell{
            let tempItem = personDetail.sellItems[sourceIndexPath.row]
            personDetail.sellItems.remove(at: sourceIndexPath.row)
            personDetail.sellItems.insert(tempItem, at: destinationIndexPath.row)
            for i in 0 ... personDetail.sellItems.count - 1{
                personDetail.sellItems[i].order = personDetail.sellItems.count - i
            }
        }else if currentItemType == .Buy{
            let tempItem = personDetail.buyItems[sourceIndexPath.row]
            personDetail.buyItems.remove(at: sourceIndexPath.row)
            personDetail.buyItems.insert(tempItem, at: destinationIndexPath.row)
            for i in 0 ... personDetail.buyItems.count - 1{
                personDetail.buyItems[i].order = personDetail.buyItems.count - i
            }
        }
        orderChanged = true
        Analytics.logEvent("編輯商店_拖曳改變商品順序", parameters:nil)
    }
    
    
}
