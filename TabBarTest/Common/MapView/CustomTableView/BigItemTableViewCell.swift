//
//  BigItemTableViewCell.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/04/17.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class BigItemTableViewCell: UITableViewCell{
    
    //這些資訊是為了點擊用到
    var personInfo : PersonDetailInfo!
    var currentItemType : Item.ItemType = .Sell
    var itemID : String!
    var indexOfRow : Int!
    weak var shopEditViewDelegate: ShopEditViewControllerViewDelegate?
    weak var mapViewDelegate: MapViewControllerViewDelegate?
    
    
    var photo : UIImageView = UIImageView() 
    var reportBtn : UIButton = UIButton()
    var nameLabel = UILabel()
    var priceLabel = UILabel()
    var descriptLabel = UILabel()
    var separator = UIView()
    var commitNumber = UILabel()
    var heartNumberLabel = UILabel()
    var heartBtn = UIButton()
    var heartImage = UIImageView()
    var optionsBtn = UIButton()
    
    var actionSheetBtnsContainer : [UIButton] = []
    var offShelfActionSheetBtnsContainer : [UIButton] = []
    var userPressLike : Bool = false
    
    var actionSheetKit = ActionSheetKit()
    var actionSheetKit_OffShelf = ActionSheetKit()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.frame =  CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 110)
        contentView.backgroundColor = .clear
        
        
        optionsBtn = { () -> UIButton in
            let btn = UIButton()
            btn.frame = contentView.frame
            btn.addTarget(self, action: #selector(self.optionsBtnAct), for: .touchUpInside)
            btn.isEnabled = true
            let btnLabel = { () -> UILabel in
                let label = UILabel()
                label.text = ""
                label.font = UIFont(name: "HelveticaNeue-Bold", size: 17)
                label.textColor = .primary()
                label.frame = CGRect(x: btn.frame.width/2 - label.intrinsicContentSize.width/2, y: 8, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
                return label
            }()
            btn.addSubview(btnLabel)
            
            return btn
        }()
        contentView.addSubview(optionsBtn)
        
        photo = {
            let imageView = UIImageView()
            imageView.frame = CGRect(x: 9, y: 11, width: 88, height: 88)
            imageView.backgroundColor = .clear
            imageView.layer.cornerRadius = 5
            imageView.clipsToBounds = true
            return imageView
        }()
        contentView.addSubview(photo)
        
        
        nameLabel = {
            let label = UILabel()
            label.text = "商品名稱"
            label.textColor = .on()
            label.font = UIFont(name: "HelveticaNeue", size: 16)
            label.frame = CGRect(x: 9 + 88 + 6, y: 8, width: UIScreen.main.bounds.size.width - 143, height: label.intrinsicContentSize.height)
            return label
        }()
        contentView.addSubview(nameLabel)
        
        descriptLabel = {
            let label = UILabel()
            label.text = "商品資訊"
            label.textColor = .on().withAlphaComponent(0.5)
            label.font = UIFont(name: "HelveticaNeue-Light", size: 14)
            label.frame = CGRect(x: 9 + 88 + 6, y: 29, width: UIScreen.main.bounds.size.width - 143, height: label.intrinsicContentSize.height)
            return label
        }()
        contentView.addSubview(descriptLabel)
        
        priceLabel = {
            let label = UILabel()
            label.text = "$：一杯咖啡"
            label.textColor = .on().withAlphaComponent(0.7)
            label.font = UIFont(name: "HelveticaNeue", size: 14)
            label.frame = CGRect(x: 9 + 88 + 6, y: 11 + 88 - label.intrinsicContentSize.height + 2, width: UIScreen.main.bounds.size.width - 240, height: label.intrinsicContentSize.height)
            return label
        }()
        contentView.addSubview(priceLabel)
        
        
        commitNumber = {
            let label = UILabel()
            label.text = "99+"
            label.textColor = .on().withAlphaComponent(0.5)
            label.font = UIFont(name: "HelveticaNeue", size: 14)
            label.frame = CGRect(x: UIScreen.main.bounds.size.width - 6.3 - 6 - 4 - label.intrinsicContentSize.width, y: 110 - 8 - 20 + 2 + 2, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            return label
        }()
        contentView.addSubview(commitNumber)
        
        let chatIconImage = { () -> UIImageView in
            let imageView = UIImageView()
            imageView.image = UIImage(named: "ChatIcon")?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = .on().withAlphaComponent(0.5)
            imageView.frame = CGRect(x:UIScreen.main.bounds.size.width - 6.3 - 6 - 4 - commitNumber.intrinsicContentSize.width - 20 - 4, y:110 - 8 - 20 + 2, width: 20, height: 20)
            return imageView
        }()
        contentView.addSubview(chatIconImage)
        
        heartNumberLabel = {
            let label = UILabel()
            label.text = "99+"
            label.textColor = .primary()
            label.font = UIFont(name: "HelveticaNeue", size: 14)
            label.frame = CGRect(x: UIScreen.main.bounds.size.width - 6.3 - 6 - 4 - commitNumber.intrinsicContentSize.width - 20 - 4 - label.intrinsicContentSize.width - 8, y: 110 - 8 - 20 + 4, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            return label
        }()
        contentView.addSubview(heartNumberLabel)
        
        heartImage = { () -> UIImageView in
            let imageView = UIImageView()
            imageView.image = UIImage(named: "空愛心")?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = .primary()
            imageView.frame = CGRect(x:UIScreen.main.bounds.size.width - 6.3 - 6 - 4 - commitNumber.intrinsicContentSize.width - 20 - 4 - heartNumberLabel.intrinsicContentSize.width - 8 - 22 - 4, y:110 - 8 - 20 + 2, width: 22, height: 20)
            return imageView
        }()
        contentView.addSubview(heartImage)
        
        heartBtn = { () -> UIButton in
            let btn = UIButton()
            btn.frame = CGRect(x: UIScreen.main.bounds.size.width - 6.3 - 6 - 4 - commitNumber.intrinsicContentSize.width - 20 - 4 - heartNumberLabel.intrinsicContentSize.width - 8 - 22 - 4, y: 110 - 8 - 20 + 2 - 15, width: 50, height: 50)
            btn.addTarget(self, action: #selector(heartBtnAct), for: .touchUpInside)
            
            btn.isEnabled = true
            return btn
        }()
        contentView.addSubview(heartBtn)
        
        separator = { () -> UIView in
            let view = UIView()
            view.frame = CGRect(x:5, y:110 - 1.3, width: UIScreen.main.bounds.size.width - 13, height: 1)
            view.backgroundColor = .on().withAlphaComponent(0.08)
            return view
        }()
        contentView.addSubview(separator)
        
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @objc fileprivate func heartBtnAct(){
        
        Analytics.logEvent("地圖_喜歡", parameters:nil)
        
        let ref = Database.database().reference()
        var likeRef = ref.child("PersonDetail")
        if currentItemType == .Sell{
            likeRef = ref.child("PersonDetail/" +  personInfo.UID + "/SellItems/" + itemID + "/likeUIDs/" + UserSetting.UID)
        }else if currentItemType == .Buy{
            likeRef = ref.child("PersonDetail/" +  personInfo.UID + "/BuyItems/" + itemID + "/likeUIDs/" + UserSetting.UID)
        }
        
        let heartNumberLabelText = heartNumberLabel.text!.trimmingCharacters(in: ["+"])
        var heartNumber = Int(heartNumberLabelText)!
        if !userPressLike{
            heartImage.image = UIImage(named: "實愛心")?.withRenderingMode(.alwaysTemplate)
            likeRef.setValue(UserSetting.UID)
            heartNumber += 1
            userPressLike = true
            if currentItemType == .Sell{
                personInfo.sellItems[indexOfRow].likeUIDs!.append(UserSetting.UID)
            }else if currentItemType == .Buy{
                personInfo.buyItems[indexOfRow].likeUIDs!.append(UserSetting.UID)
            }
        }else{
            heartImage.image = UIImage(named: "空愛心")?.withRenderingMode(.alwaysTemplate)
            likeRef.removeValue()
            heartNumber -= 1
            userPressLike = false
            if currentItemType == .Sell{
                if let likeUIDs = personInfo.sellItems[indexOfRow].likeUIDs {
                    if let index = likeUIDs.firstIndex(of: UserSetting.UID) {
                        personInfo.sellItems[indexOfRow].likeUIDs?.remove(at: index)
                    }
                }
            }else if currentItemType == .Buy{
                if let likeUIDs = personInfo.buyItems[indexOfRow].likeUIDs {
                    if let index = likeUIDs.firstIndex(of: UserSetting.UID) {
                        personInfo.buyItems[indexOfRow].likeUIDs?.remove(at: index)
                    }
                }
            }
        }
        if heartNumber > 99{
            heartNumberLabel.text = "99+"
        }else{
            heartNumberLabel.text = "\(heartNumber)"
        }
    }
    
    
    
    @objc fileprivate func optionsBtnAct(){
        
        guard let viewController = CoordinatorAndControllerInstanceHelper.rootCoordinator.rootTabBarController.selectedViewController else { return }
        actionSheetKit = ActionSheetKit()
        actionSheetKit.creatActionSheet(containerView:viewController.view,actionSheetText:["取消","下架","修改","查看"])
        
        //下架
        actionSheetKit.getActionSheetBtn(i: 1)?.addTarget(self, action: #selector(actionSheetOffShelfBtnAct), for: .touchUpInside)
        //修改
        actionSheetKit.getActionSheetBtn(i: 2)?.addTarget(self, action: #selector(actionSheetEditBtnAct), for: .touchUpInside)
        //查看
        actionSheetKit.getActionSheetBtn(i: 3)?.addTarget(self, action: #selector(actionSeeItemBtnAct), for: .touchUpInside)
        
        actionSheetKit.allBtnSlideIn()
        
        
    }
    
    
    @objc fileprivate func actionSheetOffShelfBtnAct(){
        Analytics.logEvent("編輯商店_點擊商品_下架", parameters:nil)
        
        guard let viewController = CoordinatorAndControllerInstanceHelper.rootCoordinator.rootTabBarController.selectedViewController else { return }
        actionSheetKit_OffShelf = ActionSheetKit()
        actionSheetKit_OffShelf.creatActionSheet(containerView: viewController.view, actionSheetText: ["取消","確認下架"])
        //確認下架
        actionSheetKit_OffShelf.getActionSheetBtn(i: 1)?.addTarget(self, action: #selector(offShelfActionSheetOffShelfBtnAct), for: .touchUpInside)
        actionSheetKit_OffShelf.allBtnSlideIn()
    }
    @objc fileprivate func actionSheetEditBtnAct(){
        
        Analytics.logEvent("編輯商店_點擊商品_修改", parameters:nil)
        
        if currentItemType == .Sell{
            
            mapViewDelegate?.gotoWantSellViewController_mapView(defaultItem:personInfo.sellItems[indexOfRow])
            
            shopEditViewDelegate?.gotoWantSellViewController_shopEditView(defaultItem:personInfo.sellItems[indexOfRow])
            
        }else if currentItemType == .Buy{
            
            mapViewDelegate?.gotoWantBuyViewController_mapView(defaultItem:personInfo.buyItems[indexOfRow])
            shopEditViewDelegate?.gotoWantBuyViewController_shopEditView(defaultItem:personInfo.buyItems[indexOfRow])
        }
    }
    @objc fileprivate func actionSeeItemBtnAct(){

        if currentItemType == .Sell{
            mapViewDelegate?.gotoItemViewController_mapView(item: personInfo.sellItems[indexOfRow], personDetail: personInfo)
            shopEditViewDelegate?.gotoItemViewController_shopEditView(item:personInfo.sellItems[indexOfRow],personDetail: personInfo)
            
        }else if currentItemType == .Buy{
            mapViewDelegate?.gotoItemViewController_mapView(item: personInfo.buyItems[indexOfRow], personDetail: personInfo)
            shopEditViewDelegate?.gotoItemViewController_shopEditView(item:personInfo.buyItems[indexOfRow],personDetail: personInfo)
        }
    }
    
    
    
    
    ///點擊『⋯』再點擊下架後跳出
    @objc fileprivate func offShelfActionSheetBGBtnAct(){
        Analytics.logEvent("編輯商店_點擊商品_下架_取消", parameters:nil)
        removeOffShelfActionSheetBtns()
    }
    @objc fileprivate func offShelfActionSheetCancealBtnAct(){
        Analytics.logEvent("編輯商店_點擊商品_下架_取消", parameters:nil)
        removeOffShelfActionSheetBtns()
    }
    @objc fileprivate func offShelfActionSheetOffShelfBtnAct(){
        
        Analytics.logEvent("編輯商店_點擊商品_下架_確認下架", parameters:nil)
        
        removeOffShelfActionSheetBtns()
        ////firebase Remove
        
        var ref = Database.database().reference()
        if currentItemType == .Sell{
            ref = Database.database().reference().child("PersonDetail/" +  personInfo.UID + "/SellItems/" + itemID )
            //先把item照片都刪除
            if let photoUrls = personInfo.sellItems[indexOfRow].photosUrl {
                for photoUrl in photoUrls{
                    let photoStorageRef = Storage.storage().reference(forURL: photoUrl)
                    photoStorageRef.delete(completion: { (error) in
                        if let error = error {
                            print(error)
                        } else {
                            // success
                            print("deleted \(photoUrl)")
                        }
                    })
                }
            }
            if let thumbnailUrl = personInfo.sellItems[indexOfRow].thumbnailUrl{
                let photoStorageRef = Storage.storage().reference(forURL: thumbnailUrl)
                photoStorageRef.delete(completion: { (error) in
                    if let error = error {
                        print(error)
                    } else {
                        // success
                        print("deleted \(thumbnailUrl)")
                    }
                })
            }
            //把itemComment刪除
            if personInfo.sellItems[indexOfRow].commentIDs != nil{
                let commentRef = Database.database().reference().child("Comment/" +  itemID)
                commentRef.removeValue()
            }
            
            //刪除本地端sellItemsID
            if let index = UserSetting.sellItemsID.firstIndex(of: personInfo.sellItems[indexOfRow].itemID!) {
                UserSetting.sellItemsID.remove(at: index)
            }
            //刪除本地端item
            personInfo.sellItems.remove(at: indexOfRow)
            
            //如果本地端item數量為0 關掉isOpenStore
            if personInfo.sellItems.count == 0 {
                //關掉遠端
                let ref2 = Database.database().reference().child("PersonAnnotation/" +  personInfo.UID + "/isOpenStore")
                ref2.setValue(false)
                //關掉本地端
                UserSetting.isWantSellSomething = false
                CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.presonAnnotationGetter.reFreshUserAnnotation(refreshLocation:false)
            }
            
            
            
        }else if currentItemType == .Buy{
            ref = Database.database().reference().child("PersonDetail/" +  personInfo.UID + "/BuyItems/" + itemID)
            //先把item照片都刪除
            if let photoUrls = personInfo.buyItems[indexOfRow].photosUrl {
                for photoUrl in photoUrls{
                    let photoStorageRef = Storage.storage().reference(forURL: photoUrl)
                    photoStorageRef.delete(completion: { (error) in
                        if let error = error {
                            print(error)
                        } else {
                            // success
                            print("deleted \(photoUrl)")
                        }
                    })
                }
            }
            if let thumbnailUrl = personInfo.buyItems[indexOfRow].thumbnailUrl{
                let photoStorageRef = Storage.storage().reference(forURL: thumbnailUrl)
                photoStorageRef.delete(completion: { (error) in
                    if let error = error {
                        print(error)
                    } else {
                        // success
                        print("deleted \(thumbnailUrl)")
                    }
                })
            }
            //把itemComment刪除
            if personInfo.buyItems[indexOfRow].commentIDs != nil{
                let commentRef = Database.database().reference().child("Comment/" +  itemID)
                commentRef.removeValue()
            }
            //刪除本地端buyItemsID
            if let index = UserSetting.buyItemsID.firstIndex(of: personInfo.buyItems[indexOfRow].itemID!) {
                UserSetting.buyItemsID.remove(at: index)
            }
            //刪除本地端item
            personInfo.buyItems.remove(at: indexOfRow)
            //如果本地端item數量為0
            if personInfo.buyItems.count == 0 {
                //關掉遠端
                let ref2 = Database.database().reference().child("PersonAnnotation/" +  personInfo.UID + "/isRequest")
                ref2.setValue(false)
                //關掉本地端
                UserSetting.isWantBuySomething = false
                CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.presonAnnotationGetter.reFreshUserAnnotation(refreshLocation:false)
            }
            
        }
        //刪除PersonDetail的item節點
        ref.removeValue()
        
        //本地端 Reload tableView
        self.tableView?.reloadData()
        
        
    }
    
    
    
    fileprivate func removeOffShelfActionSheetBtns(){
        guard let viewController = CoordinatorAndControllerInstanceHelper.rootCoordinator.rootTabBarController.selectedViewController else { return }
        actionSheetKit_OffShelf.allBtnSlideOut()
    }
    
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if let reorderView = findReorderView(self) {
            for sv in reorderView.subviews {
                if sv is UIImageView {
                    (sv as! UIImageView).image = UIImage(named: "bk_icon_order_20_n2")?.withRenderingMode(.alwaysTemplate)
                    (sv as! UIImageView).tintColor = .primary()
                    (sv as! UIImageView).contentMode = .center
                }
            }
        }
    }
    
    func findReorderView(_ view: UIView) -> UIView? {
        var reorderView: UIView?
        for subView in view.subviews {
            if subView.className.contains("Reorder") {
                reorderView = subView
                break
            }
            else {
                reorderView = findReorderView(subView)
                if reorderView != nil {
                    break
                }
            }
        }
        return reorderView
    }
    
    
}
