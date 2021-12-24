//
//  ShopEditViewModel.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/10/06.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Alamofire


protocol ShopModelDelegate : class{
    func stopLoadingView()
    func reloadTableView()
    func reloadTableView(indexPath:IndexPath)
    func updateHeadShot()
}


class ShopModel {
    
    weak var viewDelegate: ShopModelDelegate?
    var customBookMarkKit : CustomBookMarkKit?
    
    var currentItemType : Item.ItemType = .Sell {
        didSet{
            viewDelegate?.reloadTableView()
//            if currentItemType == .Sell{
//                customBookMarkKit?.pressBookMark(at: 0)
//            }else if currentItemType == .Buy{
//                customBookMarkKit?.pressBookMark(at: 1)
//            }
        }
    }
    var personInfo : PersonDetailInfo! {
        didSet{
            if personInfo.photos != nil {
                AF.request(personInfo.photos![0]).response { (response) in
                    guard let data = response.data, let image = UIImage(data: data)
                    else { return }
                    self.personInfo.headShotContainer = image
                    self.viewDelegate?.updateHeadShot()
                }
            }
        }
    }
    
    func fetchPersonDetail(completion: @escaping (() -> ())) {
        let ref =  Database.database().reference(withPath: "PersonDetail")
        
        ref.child(UserSetting.UID).observeSingleEvent(of: .value, with: { (snapshot) in
            self.personInfo = PersonDetailInfo(snapshot: snapshot)
            completion()
        }) { (error) in
            self.viewDelegate?.stopLoadingView()
            print(error.localizedDescription)
        }
    }
        
    
    func putItemOrderToFireBase() {
        //這方法是上傳多次，但量小，要思考是否上傳一次，但量大更好，就是直接複寫storeSellItems
        if currentItemType == .Sell{
            for item in personInfo.sellItems{
                let ref =  Database.database().reference(withPath: "PersonDetail")
                let orderRef = ref.child(UserSetting.UID + "/SellItems/" + item.itemID! + "/order")
                orderRef.setValue(item.order)
            }
        }else if currentItemType == .Buy{
            for item in personInfo.buyItems{
                let ref =  Database.database().reference(withPath: "PersonDetail")
                let orderRef = ref.child(UserSetting.UID + "/BuyItems/" + item.itemID! + "/order")
                orderRef.setValue(item.order)
            }
        }
    }
    
    
    
    
    
    
}
