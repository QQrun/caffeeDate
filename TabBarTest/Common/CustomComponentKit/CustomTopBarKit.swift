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
    
    private var topBar = UIView()
    
    private var headShotContainer : UIImage?
    
    
    func CreatTopBar(view:UIView,showSeparator:Bool = false){
        
        if alreadyCreat{
            return
        }else{
            alreadyCreat = true
        }
        
        let window = UIApplication.shared.keyWindow
        topPadding = window?.safeAreaInsets.top ?? 0
        
        topBar = UIView(frame: CGRect(x: 0, y:  topPadding, width: UIScreen.main.bounds.size.width + 2, height: 45))
        view.addSubview(topBar)
        
        if(showSeparator){
            let separator = { () -> UIView in
                let view = UIView()
                view.frame = CGRect(x:5, y:topBar.frame.height - 1, width: UIScreen.main.bounds.size.width - 13, height: 1)
                view.backgroundColor = .on().withAlphaComponent(0.16)
                return view
            }()
            topBar.addSubview(separator)}
        
        gobackImageView = UIImageView(frame: CGRect(x: 16, y: topBar.frame.height/2 - 32/2, width: 32, height: 32))
        gobackImageView.image = UIImage(named: "icons24NavigateBack24")?.withRenderingMode(.alwaysTemplate)
        gobackImageView.tintColor = .primary()
        gobackImageView.contentMode = .scaleToFill
        topBar.addSubview(gobackImageView)
        
        
        gobackBtn = UIButton(frame: CGRect(x:  0, y: 0, width: 40, height: 60))
        gobackBtn.isEnabled = true
        topBar.addSubview(gobackBtn)
        
    }
    
    func CreatMoreBtn(){
        moreBtn = { () -> UIButton in
            let btn = UIButton()
//            btn.setTitle("⋯", for: [])
            btn.setImage(UIImage(named: "icons24MoreDotFilledGrey24")?.withRenderingMode(.alwaysTemplate), for: .normal)
            btn.tintColor = .white
            btn.layer.backgroundColor = UIColor.primary().cgColor
            btn.layer.cornerRadius = 14
            btn.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 17)
            if(mailBtn != nil){
                btn.frame = CGRect(x: UIScreen.main.bounds.size.width - 28 - 16 - 28 - 12, y: topBar.frame.height/2 - 28/2, width: 28, height: 28)
            }else{
                btn.frame = CGRect(x: UIScreen.main.bounds.size.width - 28 - 16, y: topBar.frame.height/2 - 28/2, width: 28, height: 28)
            }
            btn.isEnabled = true
            return btn
        }()
        topBar.addSubview(moreBtn)
    }
    
    func CreatDoSomeThingTextBtn(text:String){
        doSomeThingTextBtn = { () -> UIButton in
            let btn = UIButton()
            btn.setTitleColor(.primary(), for:.normal)
            btn.setTitle(text, for: .normal)
            btn.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
            btn.frame = CGRect(x: UIScreen.main.bounds.size.width - 15 - 50 + 5, y: 2, width: 50, height: 44)
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
        var mailImage = UIImage(named: "icons24MessageFilledGrey24")?.withRenderingMode(.alwaysTemplate)
        mailBtn?.setImage(mailImage, for: .normal)
        mailBtn?.contentMode = .scaleAspectFit
        mailBtn?.setImage(mailImage?.imageWithInsets(insets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))?.withRenderingMode(.alwaysTemplate), for: .normal)
        mailBtn?.backgroundColor = .primary()
        mailBtn?.layer.cornerRadius = 14
        mailBtn?.tintColor = .white
        mailBtn?.frame = CGRect(x: UIScreen.main.bounds.size.width - 28 - 16, y: topBar.frame.height/2 - 28/2, width: 28, height: 28)
//        mailBtn?.frame = CGRect(x: topBar.frame.width - 28 - 9, y: topBar.frame.height/2 - 28/2 - 5, width: 28, height: 28)
        
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
            label.textColor = .on()
            label.font = UIFont(name: "HelveticaNeue-bold", size: 18)
            label.frame = CGRect(x: UIScreen.main.bounds.size.width/2 - label.intrinsicContentSize.width/2, y: 13, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            return label
        }()
        topBar.addSubview(titleLabel)
    }
    
    func CreatHeatShotAndName(personDetailInfo: PersonDetailInfo,canGoProfileView:Bool = true){
        
        let nameLabel = { () -> UILabel in
            let label = UILabel()
            label.text = personDetailInfo.name
            label.textColor = .on()
            label.font = UIFont(name: "HelveticaNeue", size: 18)
            return label
        }()
        topBar.addSubview(nameLabel)
        
        let genderIcon = UIImageView(frame: CGRect(x: UIScreen.main.bounds.size.width/2 - (nameLabel.intrinsicContentSize.width + 36 + 6)/2, y: 45/2 - 36/2, width: 36, height: 36))
        let headShot = UIImageView(frame: CGRect(x: UIScreen.main.bounds.size.width/2 - (nameLabel.intrinsicContentSize.width + 36 + 6)/2, y: 45/2 - 36/2, width: 36, height: 36))
        
        nameLabel.frame = CGRect(x: headShot.frame.maxX + 6, y: 45/2 - nameLabel.intrinsicContentSize.height/2, width: nameLabel.intrinsicContentSize.width, height: nameLabel.intrinsicContentSize.height)
        
        
        
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
                genderIcon.image = UIImage(named:"girlIcon")?.withRenderingMode(.alwaysTemplate)
            }else{
                genderIcon.image = UIImage(named:"boyIcon")?.withRenderingMode(.alwaysTemplate)
            }
            genderIcon.tintColor = .lightGray
            
            if let headShotUrl = personDetailInfo.headShot {
                AF.request(headShotUrl).response { (response) in
                    guard let data = response.data, let image = UIImage(data: data)
                    else {
                        if personDetailInfo.gender == 0{
                            headShot.image = UIImage(named:"girlIcon")?.withRenderingMode(.alwaysTemplate)
                        }else{
                            headShot.image = UIImage(named:"boyIcon")?.withRenderingMode(.alwaysTemplate)
                        }
                        headShot.contentMode = .scaleAspectFit
                        headShot.tintColor = .lightGray
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
            profileBtn.frame = CGRect(x: genderIcon.frame.minX, y: 7.5, width: 140, height: 36)
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
