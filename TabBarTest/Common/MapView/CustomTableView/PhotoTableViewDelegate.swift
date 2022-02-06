//
//  photoTableViewDelegate.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/04/13.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Firebase

public class PhotoTableViewDelegate :NSObject,UITableViewDataSource,UITableViewDelegate {
    
    //這些資訊是為了點擊用到
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "photoTableViewCell", for: indexPath) as! PhotoTableViewCell
        
        
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
                    imageView.image = UIImage(named: "icons24ShopNeedWt24")?.withRenderingMode(.alwaysTemplate)
                }
                imageView.tintColor = .lightGray
                imageView.tag = 1
                imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi)/2)
                cell.addSubview(loadingView)
                cell.sendSubviewToBack(loadingView)
                cell.addSubview(imageView)
                cell.sendSubviewToBack(imageView)
            }
            
            if let url = thumbnailUrl{
                
                cell.photo.image = UIImage()
                cell.photo.alpha = 0
                
                let type : Item.ItemType!
                if(currentItemType == .Sell){
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
        
        
        cell.backgroundColor = .clear
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        cell.selectedBackgroundView = selectedBackgroundView
        
        return cell
    }
    public func tableView(_ tableView: UITableView,
                          didSelectRowAt indexPath: IndexPath) {
        // 取消 cell 的選取狀態
        Analytics.logEvent("地圖_縮圖_前往商品頁面", parameters:nil)
        
        tableView.deselectRow(at: indexPath, animated: false)
        if currentItemType == .Sell{
            viewDelegate?.gotoItemViewController_mapView(item:personDetail.sellItems[indexPath.row],personDetail : personDetail)
        }else if currentItemType == .Buy{
            viewDelegate?.gotoItemViewController_mapView(item:personDetail.buyItems[indexPath.row],personDetail : personDetail)
        }
    }
    
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 96.0;//Choose your custom row height
    }
    
    
}
