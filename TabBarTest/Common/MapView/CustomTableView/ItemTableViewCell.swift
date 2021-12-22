//
//  ItemTableViewCell.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/04/13.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit
import Firebase

class ItemTableViewCell: UITableViewCell {
    
    //這些資訊是為了點擊用到
    var personInfo : PersonDetailInfo!
    var currentItemType : Item.ItemType = .Sell
    
    var itemID : String!
    var indexOfRow : Int!
    
    var nameLabel = UILabel()
    var priceLabel = UILabel()
    var separator = UIView()
    var commitNumber = UILabel()
    var heartNumberLabel = UILabel()
    var heartBtn = UIButton()
    var heartImage = UIImageView()
    var userPressLike : Bool = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.frame =  CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44)
        contentView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        nameLabel = {
            let label = UILabel()
            label.text = "商品名稱"
            label.textColor = .on()
            label.font = UIFont(name: "HelveticaNeue", size: 14)
            label.frame = CGRect(x: 12, y: 4, width: UIScreen.main.bounds.size.width/2, height: label.intrinsicContentSize.height)
            return label
        }()
        contentView.addSubview(nameLabel)
        
        
        priceLabel = {
            let label = UILabel()
            label.text = "$：一杯咖啡"
            label.textColor = .on().withAlphaComponent(0.7)
            label.font = UIFont(name: "HelveticaNeue", size: 14)
            label.frame = CGRect(x: 12, y: 22, width: UIScreen.main.bounds.size.width/2, height: label.intrinsicContentSize.height)
            return label
        }()
        contentView.addSubview(priceLabel)
        
        commitNumber = {
            let label = UILabel()
            label.text = "99+"
            label.textColor = .on().withAlphaComponent(0.5)
            label.font = UIFont(name: "HelveticaNeue", size: 14)
            label.frame = CGRect(x: UIScreen.main.bounds.size.width - 6.3 - 6 - 4 - label.intrinsicContentSize.width, y: 44/2 - label.intrinsicContentSize.height/2, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            return label
        }()
        contentView.addSubview(commitNumber)
        
        
        let chatIconImage = { () -> UIImageView in
            let imageView = UIImageView()
            imageView.image = UIImage(named: "ChatIcon")?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = .on().withAlphaComponent(0.5)
            imageView.frame = CGRect(x:UIScreen.main.bounds.size.width - 6.3 - 6 - 4 - commitNumber.intrinsicContentSize.width - 20 - 4, y:44/2 - 20/2, width: 20, height: 20)
            return imageView
        }()
        contentView.addSubview(chatIconImage)
        
        heartNumberLabel = {
            let label = UILabel()
            label.text = "99+"
            label.textColor = .primary()
            label.font = UIFont(name: "HelveticaNeue", size: 14)
            label.frame = CGRect(x: UIScreen.main.bounds.size.width - 6.3 - 6 - 4 - commitNumber.intrinsicContentSize.width - 20 - 4 - label.intrinsicContentSize.width - 8, y: 44/2 - label.intrinsicContentSize.height/2, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            return label
        }()
        contentView.addSubview(heartNumberLabel)
        
        heartImage = { () -> UIImageView in
            let imageView = UIImageView()
            imageView.image = UIImage(named: "空愛心")?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = .primary()
            imageView.frame = CGRect(x:UIScreen.main.bounds.size.width - 6.3 - 6 - 4 - commitNumber.intrinsicContentSize.width - 20 - 4 - heartNumberLabel.intrinsicContentSize.width - 8 - 22 - 4, y:44/2 - 20/2, width: 22, height: 20)
            return imageView
        }()
        contentView.addSubview(heartImage)
        
        heartBtn = { () -> UIButton in
            let btn = UIButton()
            btn.frame = CGRect(x: UIScreen.main.bounds.size.width - 6.3 - 6 - 4 - commitNumber.intrinsicContentSize.width - 20 - 4 - heartNumberLabel.intrinsicContentSize.width - 8 - 22 - 4, y: 0, width: 50, height: contentView.frame.height)
            btn.addTarget(self, action: #selector(heartBtnAct), for: .touchUpInside)
            
            btn.isEnabled = true
            return btn
        }()
        contentView.addSubview(heartBtn)
        
        separator = { () -> UIView in
            let view = UIView()
            view.frame = CGRect(x:5, y:44 - 1.3, width: UIScreen.main.bounds.size.width - 13, height: 1)
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
            userPressLike = true
            likeRef.setValue(UserSetting.UID)
            heartNumber += 1
            if currentItemType == .Sell{
                personInfo.sellItems[indexOfRow].likeUIDs!.append(UserSetting.UID)
            }else if currentItemType == .Buy{
                personInfo.buyItems[indexOfRow].likeUIDs!.append(UserSetting.UID)
            }
        }else{
            heartImage.image = UIImage(named: "空愛心")?.withRenderingMode(.alwaysTemplate)
            likeRef.removeValue()
            userPressLike = false
            heartNumber -= 1
            if currentItemType == .Sell{
                if let itemUIDs = personInfo.sellItems[indexOfRow].likeUIDs {
                    if let index = itemUIDs.firstIndex(of: UserSetting.UID) {
                        personInfo.sellItems[indexOfRow].likeUIDs!.remove(at: index)
                    }                }
            }else if currentItemType == .Buy{
                if var itemUIDs = personInfo.buyItems[indexOfRow].likeUIDs {
                    if let index = itemUIDs.firstIndex(of: UserSetting.UID) {
                        personInfo.buyItems[indexOfRow].likeUIDs!.remove(at: index)
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
    
    
    
    
}
