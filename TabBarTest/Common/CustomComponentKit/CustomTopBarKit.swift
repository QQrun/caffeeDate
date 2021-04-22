//
//  CustomPersonalTopBarKit.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/05/30.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Firebase

//預設gobackBtn會顯示 moreBtn不會顯示
class CustomTopBarKit {
    
    private var gobackBtn = UIButton()
    private var gobackImageView = UIImageView()
    private var moreBtn = UIButton()
    private var doSomeThingTextBtn = UIButton()
    private var mailBtn : MailButton?
    private var reportBtn = UIButton()
    
    private var alreadyCreat = false
    
    private var topPadding : CGFloat = 0
    
    private let topBarXoffset : CGFloat = -2 //這是圖導致的偏差
    private let topBarYoffset : CGFloat = -3 //這是圖導致的偏差
    private var topBar = UIView()
    
    private var headShotContainer : UIImage?
    
    func CreatTopBar(view:UIView){
        
        if alreadyCreat{
            return
        }else{
            alreadyCreat = true
        }
        
        let window = UIApplication.shared.keyWindow
        topPadding = window?.safeAreaInsets.top ?? 0
        
        topBar = UIView(frame: CGRect(x: topBarXoffset, y: topBarYoffset + topPadding, width: UIScreen.main.bounds.size.width + 2, height: 62))
        view.addSubview(topBar)
        
        let bulletinBoardBookmarkBG = UIImageView()
        bulletinBoardBookmarkBG.frame = CGRect(x: -6, y: 0, width: topBar.frame.width +  14, height: topBar.frame.height)
        bulletinBoardBookmarkBG.contentMode = .scaleToFill
        bulletinBoardBookmarkBG.image = UIImage(named: "bulletinBoardBookMarkBG")
        topBar.addSubview(bulletinBoardBookmarkBG)
        
        
        gobackImageView = UIImageView(frame: CGRect(x: 16 - topBarXoffset, y: topBar.frame.height/2 - 24/2 - 5 - topBarYoffset, width: 12, height: 24))
        gobackImageView.image = UIImage(named: "gobackIcon")
        topBar.addSubview(gobackImageView)
        
        
        gobackBtn = UIButton(frame: CGRect(x:  -topBarXoffset, y: -topBarYoffset, width: 40, height: 60))
        gobackBtn.isEnabled = true
        topBar.addSubview(gobackBtn)
        
    }
    
    func CreatMoreBtn(){
        moreBtn = { () -> UIButton in
            let btn = UIButton()
            btn.setTitle("⋯", for: [])
            btn.setTitleColor(UIColor.hexStringToUIColor(hex: "751010"), for:.normal)
            btn.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 17)
            btn.frame = CGRect(x: UIScreen.main.bounds.size.width - 15 - 30 - topBarXoffset, y: -topBarYoffset, width: 30, height: 44)
            btn.isEnabled = true
            btn.isHidden = true //預設不顯示
            return btn
        }()
        topBar.addSubview(moreBtn)
    }
    
    func CreatDoSomeThingTextBtn(text:String){
        doSomeThingTextBtn = { () -> UIButton in
            let btn = UIButton()
            btn.setTitleColor(UIColor.hexStringToUIColor(hex: "751010"), for:.normal)
            btn.setTitle(text, for: .normal)
            btn.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
            btn.frame = CGRect(x: UIScreen.main.bounds.size.width - 15 - 50 - topBarXoffset + 5, y: -topBarYoffset + 2, width: 50, height: 44)
            btn.isEnabled = true
            btn.alpha = 1
            return btn
        }()
        topBar.addSubview(doSomeThingTextBtn)
    }
    
    func CreatMailBtn(personDetailInfo: PersonDetailInfo){
        
        if personDetailInfo.UID == UserSetting.UID{
            return
        }
        mailBtn = MailButton(personInfo: personDetailInfo)
        mailBtn!.setImage(UIImage(named: "飛鴿傳書icon"), for: .normal)
        mailBtn!.frame = CGRect(x: topBar.frame.width - 50 - 9, y: topBar.frame.height/2 - 42/2 - 5 - topBarYoffset, width: 50, height: 42)
        mailBtn!.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        topBar.addSubview(mailBtn!)
        
    }
    
    func CreatReportBtn(){
        reportBtn.frame = CGRect(x: UIScreen.main.bounds.size.width - 25 - 10, y:topBar.frame.height/2 - 25/2 - 3, width: 25, height: 25)
        let icon = UIImage(named: "reportIcon")?.withRenderingMode(.alwaysTemplate)
        reportBtn.setImage(icon, for: .normal)
        reportBtn.tintColor = UIColor.hexStringToUIColor(hex: "#751010")
        reportBtn.alpha = 0.8
        reportBtn.contentMode = .center
        topBar.addSubview(reportBtn)
    }
    
    func CreatCenterTitle(text:String){
        let titleLabel = { () -> UILabel in
            let label = UILabel()
            label.text = text
            label.textColor = UIColor.hexStringToUIColor(hex: "000000")
            label.font = UIFont(name: "HelveticaNeue", size: 18)
            label.frame = CGRect(x: UIScreen.main.bounds.size.width/2 - label.intrinsicContentSize.width/2 - topBarXoffset, y: 13 - topBarYoffset, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            return label
        }()
        topBar.addSubview(titleLabel)
    }
    
    func CreatHeatShotAndName(personDetailInfo: PersonDetailInfo,canGoProfileView:Bool = true){
        
        let nameLabel = { () -> UILabel in
            let label = UILabel()
            label.text = personDetailInfo.name
            label.textColor = UIColor.hexStringToUIColor(hex: "000000")
            label.font = UIFont(name: "HelveticaNeue", size: 18)
                        return label
        }()
        topBar.addSubview(nameLabel)
        
        let genderIcon = UIImageView(frame: CGRect(x: UIScreen.main.bounds.size.width/2 - (nameLabel.intrinsicContentSize.width + 36 + 6)/2, y: 7.5 - topBarYoffset, width: 36, height: 36))
        let headShot = UIImageView(frame: CGRect(x: UIScreen.main.bounds.size.width/2 - (nameLabel.intrinsicContentSize.width + 36 + 6)/2, y: 7.5 - topBarYoffset, width: 36, height: 36))
    
        nameLabel.frame = CGRect(x: headShot.frame.maxX + 6, y: 15 - topBarYoffset, width: nameLabel.intrinsicContentSize.width, height: nameLabel.intrinsicContentSize.height)

        
        
        if let personHeadShot = personDetailInfo.headShotContainer{
            //girlIcon和boyIcon需要Fit,照片需要Fill
            headShot.contentMode = .scaleAspectFill
            headShot.image = personHeadShot
        }
        else if headShotContainer != nil{
            //girlIcon和boyIcon需要Fit,照片需要Fill
            headShot.contentMode = .scaleAspectFill
            headShot.image = headShotContainer
        }
        else{
            genderIcon.contentMode = .scaleAspectFit
            if personDetailInfo.gender == 0{
                genderIcon.image = UIImage(named:"girlIcon")
            }else{
                genderIcon.image = UIImage(named:"boyIcon")
            }
            
            if let headShotUrl = personDetailInfo.headShot {
                AF.request(headShotUrl).response { (response) in
                    guard let data = response.data, let image = UIImage(data: data)
                    else {
                        if personDetailInfo.gender == 0{
                            headShot.image = UIImage(named:"girlIcon")
                        }else{
                            headShot.image = UIImage(named:"boyIcon")
                        }
                        headShot.contentMode = .scaleAspectFit
                        return }
                    headShot.contentMode = .scaleAspectFill
                    headShot.image = image
                    self.headShotContainer = image
                    headShot.alpha = 0
                    UIView.animate(withDuration: 0.3, animations: {
                        genderIcon.alpha = 0
                        headShot.alpha = 1
                    })
                }
            }
        }
        headShot.layer.cornerRadius = 18
        headShot.clipsToBounds = true
        topBar.addSubview(genderIcon)
        topBar.addSubview(headShot)
        
        
        
        if canGoProfileView{
            let profileBtn = ProfileButton(personInfo: personDetailInfo)
            profileBtn.frame = CGRect(x: genderIcon.frame.minX, y: 7.5 - topBarYoffset, width: 140, height: 36)
            topBar.addSubview(profileBtn)
        }
    }
    
    
    func getGobackBtn() -> UIButton{
        return gobackBtn
    }
    func hiddenGobackBtn(){
        gobackBtn.isHidden = true
        gobackImageView.isHidden = true
    }
    func showGobackBtn(){
        gobackBtn.isHidden = false
        gobackImageView.isHidden = false
    }
    
    func getMoreBtn() -> UIButton{
        return moreBtn
    }
    func getDoSomeThingTextBtn() -> UIButton{
        return doSomeThingTextBtn
    }
    func getMailBtn() -> MailButton?{
        return mailBtn
    }
    
    func getReportBtn() ->UIButton{
        return reportBtn
    }
    func getDoSomeThingBtn() ->  UIButton{
        return doSomeThingTextBtn
    }
    
    func getTopBar() -> UIView{
        return topBar
    }
}
