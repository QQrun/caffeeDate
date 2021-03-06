//
//  DrawCardViewController.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2022/04/10.
//  Copyright © 2022 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import MapKit
import SpriteKit


class DrawCardViewController: UIViewController {
    
    var customTopBarKit = CustomTopBarKit()
    var topBar = UIView()
    
    let sharedSeatAnnotation:SharedSeatAnnotation
    
    
    var drawBackBtn = UIButton()
    var drawCardBtn = UIButton()
    var loveCardBtn = UIButton()
    var drawForwardBtn = UIButton()
    
    var select1 = "" //選到的第一人ID
    var select2 = "" //選到的第二人ID
    
    var scrollView = UIScrollView()
    var stackView = UIStackView()
    
    //儲存已經抽過的卡片，此為本地儲存
    var storeKey1 = ""
    var storeKey2 = ""
    var drawedUID1 : [String] = []
    var drawedUID2 : [String] = []
    
    var currentPage = 0
    
    //儲值用
    var coinCountLabel = UILabel()
    var coinImageView = UIImageView()

    
    init(sharedSeatAnnotation:SharedSeatAnnotation){
        self.sharedSeatAnnotation = sharedSeatAnnotation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .surface()
        
        getDrawedUID()
        configTopbar()
        configScrollView()
        configBottomBtns()
        changeBtnStatus(scrollView)
    }
    
    //載入之前抽過的卡片
    fileprivate func getDrawedUID() {
        storeKey1 = sharedSeatAnnotation.holderUID +  sharedSeatAnnotation.dateTime + "drawedUID1"
        drawedUID1 = UserDefaults.standard.value(forKey: storeKey1) as? [String] ?? []
        
        storeKey2 = sharedSeatAnnotation.holderUID +  sharedSeatAnnotation.dateTime + "drawedUID2"
        drawedUID2 = UserDefaults.standard.value(forKey: storeKey2) as? [String] ?? []
    }
    
    
    fileprivate func addparticle(completion: @escaping (() -> ()),useAnimation:Bool = true) {
        let particlePath1 = Bundle.main.path(forResource: "soul", ofType: "sks")!
        let particlePath2 = Bundle.main.path(forResource: "soul2", ofType: "sks")!
        
        let particle1 = NSKeyedUnarchiver.unarchiveObject(withFile: particlePath1) as! SKEmitterNode
        particle1.name = "AIsoulFX1"
        particle1.position = CGPoint(x:view.frame.size.width/2, y:view.frame.size.height/2)
        
        let particle2 = NSKeyedUnarchiver.unarchiveObject(withFile: particlePath2) as! SKEmitterNode
        particle2.name = "AIsoulFX2"
        particle2.position = CGPoint(x:view.frame.size.width/2, y:view.frame.size.height/2)
        
        
        let spriteKitView = SKView()
        spriteKitView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: view.frame.width)
        spriteKitView.layer.cornerRadius = 125
        spriteKitView.clipsToBounds = true
        let scene = SKScene(size: spriteKitView.frame.size)
        scene.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0/255)
        spriteKitView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0/255)
        spriteKitView.presentScene(scene)
        
        
        particle1.position = CGPoint(x: spriteKitView.frame.width/2, y: spriteKitView.frame.height/2)
        particle2.position = CGPoint(x: spriteKitView.frame.width / 2, y: spriteKitView.frame.height/2 + 20)
        scene.addChild(particle1)
        
        var animation1Duration : Double
        var animation2Duration : Double
        var animation2Delay : Double
        
        if(useAnimation){
            view.addSubview(spriteKitView)
            UIView.animate(withDuration: 3, animations:{
                spriteKitView.frame.origin.y = self.view.frame.height/2 - self.view.frame.width/2
            },completion: {_ in
                scene.addChild(particle2)
                UIView.animate(withDuration: 1, delay: 0.5, options: .curveLinear, animations: {
                    spriteKitView.alpha = 0
                    completion()
                }, completion: { _ in
                    spriteKitView.removeFromSuperview()
                })
            })
            
        }else{
            completion()
        }
    }
    
    
    fileprivate func configTopbar() {
        customTopBarKit.CreatTopBar(view: view,showSeparator:true,considerSafeAreaInsets: false)
        customTopBarKit.CreatCenterTitle(text: "隨機抽卡")
        let gobackBtn = customTopBarKit.getGobackBtn()
        gobackBtn.addTarget(self, action: #selector(gobackBtnAct), for: .touchUpInside)
        
        topBar = customTopBarKit.getTopBar()
        
        coinCountLabel  = { () -> UILabel in
            let label = UILabel()
            label.text = "    999"
            label.textColor = UIColor.hexStringToUIColor(hex: "#e1b808")
            label.font = UIFont(name: "HelveticaNeue", size: 16)
            label.textAlignment = .center
            label.layer.borderColor = UIColor.hexStringToUIColor(hex: "#e1b808").cgColor
            label.layer.borderWidth = 1
            label.layer.cornerRadius = label.intrinsicContentSize.height/2 + 3
            label.layer.backgroundColor = UIColor.sksWhite().cgColor
            label.padding = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
            label.frame = CGRect(x:topBar.frame.width - 16 - (label.intrinsicContentSize.width + 10), y:topBar.frame.height/2 - label.intrinsicContentSize.height/2 - 3, width: label.intrinsicContentSize.width + 10, height: label.intrinsicContentSize.height + 6)
            return label
        }()
        topBar.addSubview(coinCountLabel)
        
        //Coin的圖案
        coinImageView = { () -> UIImageView in
            let imageView = UIImageView(frame: CGRect(x:coinCountLabel.frame.origin.x + 1.5,y:coinCountLabel.frame.origin.y + 3,width:coinCountLabel.frame.height - 6,height:coinCountLabel.frame.height - 6))
            let coinImage = UIImage(named: "icons_24_coin_fill_24")
            imageView.image = coinImage
            return imageView
        }()
        topBar.addSubview(coinImageView)
        
        //儲值按鈕右上的加號
        let addCoinImageView = UIImageView(frame:CGRect(x: coinCountLabel.frame.origin.x + coinCountLabel.frame.width - 9, y: coinCountLabel.frame.origin.y - 5, width: 14, height: 14))
        addCoinImageView.backgroundColor = .clear
        let addCoinImage = UIImage(named: "icons_16_add_outline_16")
        addCoinImageView.image = addCoinImage
        topBar.addSubview(addCoinImageView)
        
        let addCoinBtn = UIButton(frame: CGRect(x: coinCountLabel.frame.origin.x, y: 0, width: topBar.frame.width - coinCountLabel.frame.origin.x, height: topBar.frame.height))
        addCoinBtn.addTarget(self, action: #selector(addCoinBtnAct), for: .touchUpInside)
        topBar.addSubview(addCoinBtn)
    }
    
    fileprivate func configScrollView() {
        
        
        var cardWidth : CGFloat
        var scrollView_y : CGFloat
        if(sharedSeatAnnotation.mode == 1){
            cardWidth = view.frame.width - 48
            //(下方按鈕的y值 + topbar的下底y/2)為卡片應該在的中間位置
            scrollView_y = (view.frame.height - 135)/2 - cardWidth/2
        }else{
            cardWidth =  (view.frame.width + 70) / 2
            scrollView_y = (view.frame.height - 135)/2 - (cardWidth * 2 - 70)/2
        }
        
        
        view.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: scrollView_y).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        if sharedSeatAnnotation.mode == 1{
            scrollView.heightAnchor.constraint(equalToConstant: view.frame.width - 48).isActive = true
        }else{
            scrollView.heightAnchor.constraint(equalToConstant: cardWidth * 2 - 70).isActive = true
        }
        scrollView.contentMode = .scaleToFill
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bouncesZoom = true
        scrollView.bounces = true
        scrollView.delegate = self
        scrollView.addSubview(stackView)
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        // this is important for scrolling
        stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        stackView.autoresizesSubviews = true
        
        
        addDrawedCrad()
    }
    
    fileprivate func addDrawedCrad(){
        if (sharedSeatAnnotation.mode == 1){
            for UID in drawedUID1{
                let ref = Database.database().reference().child("PersonDetail/" + "\(UID)")
                ref.observeSingleEvent(of: .value, with: {(snapshot) in
                    let personInfo = PersonDetailInfo(snapshot: snapshot)
                    self.addCard(personInfo,isDrawedCard: true)
                })
            }
        }else{
            if(drawedUID1.count != 0){
                for i in 0 ... drawedUID1.count - 1{
                    var downloadedPersonInfo : [PersonDetailInfo] = []
                    let ref = Database.database().reference().child("PersonDetail/" + "\(drawedUID1[i])")
                    ref.observeSingleEvent(of: .value, with: {(snapshot) in
                        let personInfo = PersonDetailInfo(snapshot: snapshot)
                        downloadedPersonInfo.append(personInfo)
                        if(downloadedPersonInfo.count == 2){
                            self.addCard(downloadedPersonInfo[0], downloadedPersonInfo[1],isDrawedCard: true)
                        }
                    })
                    
                    let ref2 = Database.database().reference().child("PersonDetail/" + "\(drawedUID2[i])")
                    ref2.observeSingleEvent(of: .value, with: {(snapshot) in
                        let personInfo = PersonDetailInfo(snapshot: snapshot)
                        downloadedPersonInfo.append(personInfo)
                        if(downloadedPersonInfo.count == 2){
                            self.addCard(downloadedPersonInfo[0], downloadedPersonInfo[1],isDrawedCard: true)
                        }
                    })
                }}
            
        }
    }
    
    fileprivate func configBottomBtns() {
        drawBackBtn = UIButton()
        drawBackBtn.frame = CGRect(x: view.frame.width/8 - 25, y: view.frame.height - 125 - 50, width: 50, height: 50)
        drawBackBtn.setImage(UIImage(named: "arrow_left_black_36dp"), for: .normal)
        drawBackBtn.alpha = 0.3
        drawBackBtn.isEnabled = false
        drawBackBtn.addTarget(self, action: #selector(drawBackBtnAct), for: .touchUpInside)
        view.addSubview(drawBackBtn)
        
        drawCardBtn = UIButton()
        drawCardBtn.frame = CGRect(x: (view.frame.width/8) * 3 - 30, y: view.frame.height - 125 - 55, width: 60, height: 60)
        drawCardBtn.setImage(UIImage(named: "random_card_36dp"), for: .normal)
        drawCardBtn.addTarget(self, action: #selector(drawCardBtnAct), for: .touchUpInside)
        view.addSubview(drawCardBtn)
        
        //Coin的圖案
        let coin = { () -> UIImageView in
            let imageView = UIImageView(frame: CGRect(x:drawCardBtn.frame.origin.x + 9,y:drawCardBtn.frame.origin.y + drawCardBtn.frame.height,width:20,height:20))
            let coinImage = UIImage(named: "icons_24_coin_fill_24")
            imageView.image = coinImage
            return imageView
        }()
        view.addSubview(coin)
        
        let oneDrawNeedToPay = {() -> UILabel in
            let label = UILabel()
            label.text = "30"
            label.textColor = UIColor.hexStringToUIColor(hex: "#e1b808")
            label.font = UIFont(name: "HelveticaNeue", size: 14)
            label.frame = CGRect(x:coin.frame.origin.x + coin.frame.width + 5, y:coin.frame.origin.y + 2.2, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            return label
        }()
        view.addSubview(oneDrawNeedToPay)
        
        
        loveCardBtn = UIButton()
        loveCardBtn.frame = CGRect(x: (view.frame.width/8) * 5 - 30, y: view.frame.height - 125 - 55, width: 60, height: 60)
        loveCardBtn.setImage(UIImage(named: "love_card_36dp"), for: .normal)
        loveCardBtn.addTarget(self, action: #selector(confirmBtnAct), for: .touchUpInside)
        loveCardBtn.alpha = 0.3
        loveCardBtn.isEnabled = false
        view.addSubview(loveCardBtn)
        
        drawForwardBtn = UIButton()
        drawForwardBtn.frame = CGRect(x: (view.frame.width/8) * 7 - 25, y: view.frame.height - 125 - 50, width: 50, height: 50)
        drawForwardBtn.setImage(UIImage(named: "arrow_right_black_36dp"), for: .normal)
        drawForwardBtn.alpha = 0.3
        drawForwardBtn.isEnabled = false
        drawForwardBtn.addTarget(self, action: #selector(drawForwardBtnAct), for: .touchUpInside)
        view.addSubview(drawForwardBtn)
    }
    
    
    fileprivate func addCard(_ personInfo: PersonDetailInfo,isDrawedCard: Bool = false) {
        
        let cardContainer = UIView()
        cardContainer.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        stackView.addArrangedSubview(cardContainer)
        scrollView.setContentOffset(CGPoint(x: stackView.frame.width, y: 0), animated: true)
        
        
        
        //        let cardBorder = UIView()
        //        cardBorder.frame = CGRect(x: 24, y: 0, width: view.frame.width - 48, height: view.frame.width - 48)
        //        if(personInfo.gender == 0){
        //            cardBorder.layer.borderColor = UIColor.sksPink().cgColor
        //        }else{
        //            cardBorder.layer.borderColor = UIColor.sksBlue().cgColor
        //        }
        //        cardBorder.layer.borderWidth = 2
        //        cardBorder.layer.cornerRadius = 12
        //        cardBorder.clipsToBounds = true
        //        cardContainer.addSubview(cardBorder)
        
        let card = UIImageView()
        card.frame = CGRect(x: 24, y: 0, width: view.frame.width - 48, height: view.frame.width - 48)
        cardContainer.addSubview(card)
        
        card.layer.borderWidth = 2
        if(personInfo.gender == 0){
            card.layer.borderColor = UIColor.sksPink().cgColor
        }else{
            card.layer.borderColor = UIColor.sksBlue().cgColor
        }
        card.layer.cornerRadius = 12
        card.clipsToBounds = true
        card.alpha = 0
        
        let name = UILabel()
        name.text = ""
        name.font = name.font.withSize(21)
        name.textColor = .white
        name.frame = CGRect(x:45, y: view.frame.width - 48 - 45, width: view.frame.width, height: 30)
        name.alpha = 0
        cardContainer.addSubview(name)
        
        
        let btn = ProfileUIButton()
        btn.frame = card.frame
        btn.backgroundColor = .clear
        btn.addTarget(self, action: #selector(goProfile), for: .touchUpInside)
        btn.UID = personInfo.UID
        cardContainer.addSubview(btn)
        
        addparticle(completion: {
            
            if let photo = personInfo.photos?[0]{
                AF.request(photo).response { (response) in
                    guard let data = response.data, let image = UIImage(data: data)
                    else {
                        return
                    }
                    card.image = image
                    let birthdayFormatter = DateFormatter()
                    birthdayFormatter.dateFormat = "yyyy/MM/dd"
                    let currentTime = Date()
                    let birthDayDate = birthdayFormatter.date(from: personInfo.birthday)
                    let age = currentTime.years(sinceDate: birthDayDate!) ?? 0
                    name.text = personInfo.name + " " + "\(age)"
                    UIView.animate(withDuration: 0.4, animations:{
                        card.alpha = 1
                        name.alpha = 1
                        self.loveCardBtn.alpha = 1
                        self.loveCardBtn.isEnabled = true
                        self.drawCardBtn.isEnabled = true
                    })
                }
            }
        },useAnimation: !isDrawedCard)
        
        if(!isDrawedCard){
            drawedUID1.append(personInfo.UID)
            UserDefaults.standard.set(drawedUID1, forKey: storeKey1)
        }
    }
    
    fileprivate func addCard(_ personInfo1: PersonDetailInfo,_ personInfo2: PersonDetailInfo,isDrawedCard:Bool = false) {
        
        let cardContainer = UIView()
        cardContainer.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        stackView.addArrangedSubview(cardContainer)
        scrollView.setContentOffset(CGPoint(x: stackView.frame.width, y: 0), animated: true)
        
        var genderColor : CGColor
        if(personInfo1.gender == 0){
            genderColor = UIColor.sksPink().cgColor
        }else{
            genderColor = UIColor.sksBlue().cgColor
        }
        
        let cardWidth = (view.frame.width + 70) / 2
        
        let card1 = UIImageView()
        card1.frame = CGRect(x: 0, y: 0, width: cardWidth, height: cardWidth)
        cardContainer.addSubview(card1)
        card1.layer.borderWidth = 2
        card1.layer.borderColor = genderColor
        card1.layer.cornerRadius = 12
        card1.clipsToBounds = true
        card1.alpha = 0
        
        let name1 = UILabel()
        name1.text = ""
        name1.font = name1.font.withSize(21)
        name1.textColor = .white
        name1.frame = CGRect(x:16, y: cardWidth - 25 - 16, width: view.frame.width, height: 25)
        name1.alpha = 0
        cardContainer.addSubview(name1)
        
        let btn1 = ProfileUIButton()
        btn1.frame = card1.frame
        btn1.backgroundColor = .clear
        btn1.addTarget(self, action: #selector(goProfile), for: .touchUpInside)
        btn1.UID = personInfo1.UID
        cardContainer.addSubview(btn1)
        
        
        let card2 = UIImageView()
        card2.frame = CGRect(x: cardWidth - 70, y: cardWidth - 70, width: cardWidth, height: cardWidth)
        cardContainer.addSubview(card2)
        card2.layer.borderWidth = 2
        card2.layer.borderColor = genderColor
        card2.layer.cornerRadius = 12
        card2.clipsToBounds = true
        card2.alpha = 0
        
        let name2 = UILabel()
        name2.text = ""
        name2.font = name2.font.withSize(21)
        name2.textColor = .white
        name2.frame = CGRect(x:cardWidth - 70 + 16, y: card2.frame.origin.y + cardWidth - 25 - 16, width: view.frame.width, height: 25)
        name2.alpha = 0
        cardContainer.addSubview(name2)
        
        let btn2 = ProfileUIButton()
        btn2.frame = card2.frame
        btn2.backgroundColor = .clear
        btn2.addTarget(self, action: #selector(goProfile), for: .touchUpInside)
        btn2.UID = personInfo2.UID
        cardContainer.addSubview(btn2)
        
        
        addparticle(completion: {
            
            if let photo = personInfo1.photos?[0]{
                AF.request(photo).response { (response) in
                    guard let data = response.data, let image = UIImage(data: data)
                    else {
                        return
                    }
                    card1.image = image
                    let birthdayFormatter = DateFormatter()
                    birthdayFormatter.dateFormat = "yyyy/MM/dd"
                    let currentTime = Date()
                    let birthDayDate = birthdayFormatter.date(from: personInfo1.birthday)
                    let age = currentTime.years(sinceDate: birthDayDate!) ?? 0
                    name1.text = personInfo1.name + " " + "\(age)"
                    UIView.animate(withDuration: 0.4, animations:{
                        card1.alpha = 1
                        name1.alpha = 1
                        self.loveCardBtn.alpha = 1
                        self.loveCardBtn.isEnabled = true
                        self.drawCardBtn.isEnabled = true
                    })
                }
            }
            
            if let photo = personInfo2.photos?[0]{
                AF.request(photo).response { (response) in
                    guard let data = response.data, let image = UIImage(data: data)
                    else {
                        return
                    }
                    card2.image = image
                    let birthdayFormatter = DateFormatter()
                    birthdayFormatter.dateFormat = "yyyy/MM/dd"
                    let currentTime = Date()
                    let birthDayDate = birthdayFormatter.date(from: personInfo2.birthday)
                    let age = currentTime.years(sinceDate: birthDayDate!) ?? 0
                    name2.text = personInfo2.name + " " + "\(age)"
                    UIView.animate(withDuration: 0.4, animations:{
                        card2.alpha = 1
                        name2.alpha = 1
                        self.loveCardBtn.alpha = 1
                        self.loveCardBtn.isEnabled = true
                        self.drawCardBtn.isEnabled = true
                    })
                    
                }
            }
            
        },useAnimation: !isDrawedCard)
        
        if(!isDrawedCard){
            drawedUID1.append(personInfo1.UID)
            UserDefaults.standard.set(drawedUID1, forKey: storeKey1)
            drawedUID2.append(personInfo2.UID)
            UserDefaults.standard.set(drawedUID2, forKey: storeKey2)
        }
        
    }
    
    private func drawCard(){
        
        if(sharedSeatAnnotation.mode == 1){ //1v1模式抽卡
            var signUpID : [String : String] = [:]
            if(UserSetting.userGender == 0){
                signUpID = sharedSeatAnnotation.signUpBoysID!
            }else{
                signUpID = sharedSeatAnnotation.signUpGirlsID!
            }
            let selectNumber = Int.random(in: 0...signUpID.count - 1)
            var i = 0
            for (UID,InvitationCode) in signUpID {
                if(i == selectNumber){
                    select1 = UID
                }
                i += 1
            }
            
            let ref = Database.database().reference().child("PersonDetail/" + "\(select1)")
            ref.observeSingleEvent(of: .value, with: {(snapshot) in
                let personInfo = PersonDetailInfo(snapshot: snapshot)
                self.addCard(personInfo)
            })
            
        }else{ //2v2模式抽卡
            
            var signUpID : [String : String] = [:]
            if(UserSetting.userGender == 0){
                signUpID = sharedSeatAnnotation.signUpBoysID!
            }else{
                signUpID = sharedSeatAnnotation.signUpGirlsID!
            }
            var pairSignUpID: [String:[String]] = [:]
            
            for (UID,InvitationCode) in signUpID {
                if pairSignUpID.index(forKey: InvitationCode) != nil {
                    pairSignUpID[InvitationCode] = [pairSignUpID[InvitationCode]![0],UID]
                }else{
                    pairSignUpID[InvitationCode] = [UID]
                }
            }
            
            let selectNumber = Int.random(in: 0...pairSignUpID.count - 1)
            var i = 0
            for (InvitationCode,IDs) in pairSignUpID {
                if(i == selectNumber){
                    select1 = IDs[0]
                    select2 = IDs[1]
                }
                i += 1
            }
            
            var downloadedPersonInfo : [PersonDetailInfo] = []
            let ref = Database.database().reference().child("PersonDetail/" + "\(select1)")
            ref.observeSingleEvent(of: .value, with: {(snapshot) in
                let personInfo = PersonDetailInfo(snapshot: snapshot)
                downloadedPersonInfo.append(personInfo)
                if(downloadedPersonInfo.count == 2){
                    self.addCard(downloadedPersonInfo[0], downloadedPersonInfo[1])
                }
            })
            
            let ref2 = Database.database().reference().child("PersonDetail/" + "\(select2)")
            ref2.observeSingleEvent(of: .value, with: {(snapshot) in
                let personInfo = PersonDetailInfo(snapshot: snapshot)
                downloadedPersonInfo.append(personInfo)
                if(downloadedPersonInfo.count == 2){
                    self.addCard(downloadedPersonInfo[0], downloadedPersonInfo[1])
                }
            })
            
            
        }
        
        
        
        
    }
    
    fileprivate func dismissAndRefresh() {
        //退出然後刷新selectAnnotation
        self.dismiss(animated: true, completion: nil)
        CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.navigationController?.popViewController(animated: true)
        CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.mapView.deselectAnnotation(nil, animated: false)
        let currentSharedSeatAnnotation = CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.currentSharedSeatAnnotation
        CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.mapView.selectAnnotation(currentSharedSeatAnnotation as! MKAnnotation, animated: false)
    }
    
    fileprivate func autoSendFirstMessage(_ chatroomID: String) {
        //自動送出第一則訊息
        let messageId = NSUUID().uuidString
        let messageRef = Database.database().reference(withPath: "Message/" + chatroomID + "/" + messageId)
        let currentTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMddHHmmss"
        let currentTimeString = dateFormatter.string(from: currentTime)
        
        
        var UIDs : [String] = [] //收集非本人的UID
        if(sharedSeatAnnotation.mode == 1){
            UIDs.append(drawedUID1[currentPage])
        }else{
            UIDs.append(drawedUID1[currentPage])
            UIDs.append(drawedUID2[currentPage])
            var IDs : [String:String]? = [:]
            if(UserSetting.userGender == 0){
                IDs = sharedSeatAnnotation.girlsID
            }else if(UserSetting.userGender == 1){
                IDs = sharedSeatAnnotation.boysID
            }
            for(UID,InvitationCode) in IDs!{
                if(UID != UserSetting.UID){
                    UIDs.append(UID)
                }
            }
        }
        
        var collectTokens : [String:String] = [:]
        for id in UIDs{
            let tokenRef = Database.database().reference().child("PersonDetail/" +  id + "/token")
            tokenRef.observeSingleEvent(of: .value, with: {(snapshot) in
                if snapshot.exists(){
                    let targetToken = snapshot.value as! String
                    collectTokens[id] = targetToken
                    var targetGenderChinese : String
                    if self.sharedSeatAnnotation.mode == 1{
                        if UserSetting.userGender == 0{
                            targetGenderChinese = "你"
                        }else{
                            targetGenderChinese = "妳"
                        }
                    }else{
                        targetGenderChinese = "各位"
                    }
                    let messageValue =
                    [
                        "time": currentTimeString,
                        "UID": UserSetting.UID,
                        "name": UserSetting.userName,
                        "text": "哈囉 很榮幸能在茫茫人海中邀請" + targetGenderChinese + "去《" + self.sharedSeatAnnotation.title! + "》吃頓飯",
                        "targetToken":collectTokens,
                    ] as [String : Any]
                    messageRef.setValue(messageValue)
                }
            })
        }
        
    }
    
    //本地端資料修改
    fileprivate func localDataChange() {
        if(UserSetting.userGender == 0){
            sharedSeatAnnotation.boysID = [:]
            sharedSeatAnnotation.boysID![drawedUID1[currentPage]] = "-"
            if(drawedUID2.count == drawedUID1.count){
                sharedSeatAnnotation.boysID![drawedUID2[currentPage]] = "-"
            }
        }else{
            sharedSeatAnnotation.girlsID = [:]
            sharedSeatAnnotation.girlsID![drawedUID1[currentPage]] = "-"
            if(drawedUID2.count == drawedUID1.count){
                sharedSeatAnnotation.girlsID![drawedUID2[currentPage]] = "-"
            }
        }
    }
    
    fileprivate func open4PeopleMessageRoom() {
        //開啟四人聊天室
        var IDs : [String:String]? = [:]
        if(UserSetting.userGender == 0 && sharedSeatAnnotation.girlsID!.count == 2){
            IDs = sharedSeatAnnotation.girlsID
        }else if(UserSetting.userGender == 1 && sharedSeatAnnotation.boysID!.count == 2){
            IDs = sharedSeatAnnotation.boysID
        }
        var partnerUID = ""
        for(UID,InvitationCode) in IDs!{
            if(UID != UserSetting.UID){
                partnerUID = UID
            }
        }
        if(partnerUID != ""){
            let sortedIDs = [self.drawedUID1[self.currentPage],self.drawedUID2[self.currentPage],UserSetting.UID,partnerUID].sorted()
            let chatroomID = sortedIDs[0] + "-" + sortedIDs[1] + "-" + sortedIDs[2] + "-" + sortedIDs[3]
            chatroomID.components(separatedBy: "-").forEach{
                (uid) in
                Database.database().reference(withPath: "MessageRoom/" + uid + "/" + chatroomID).setValue(self.sharedSeatAnnotation.title! + "_" + self.sharedSeatAnnotation.photosUrl![0])
            }
            self.autoSendFirstMessage(chatroomID)
        }
    }
    
    @objc private func confirmBtnAct(){
        
        if(sharedSeatAnnotation.mode == 1){
            if drawedUID1.count > currentPage{
                //上傳
                var updateGender = ""
                if(UserSetting.userGender == 0){
                    updateGender = "boysID"
                }else{
                    updateGender = "girlsID"
                }
                let ref = Database.database().reference().child("SharedSeatAnnotation/" + sharedSeatAnnotation.holderUID + "/" + updateGender + "/" + drawedUID1[currentPage])
                ref.setValue("-"){ (error, ref) -> Void in
                    if error != nil{
                        print(error ?? "上傳參加者失敗")
                    }
                    self.localDataChange()

                    //開啟聊天室
                    let sortedIDs = [self.drawedUID1[self.currentPage],UserSetting.UID].sorted()
                    let chatroomID = sortedIDs[0] + "-" + sortedIDs[1]
                    chatroomID.components(separatedBy: "-").forEach{
                        (uid) in
                        Database.database().reference(withPath: "MessageRoom/" + uid + "/" + chatroomID).setValue(self.sharedSeatAnnotation.title)
                    }
                    
                    self.autoSendFirstMessage(chatroomID)
                    self.dismissAndRefresh()
                }
            }
        }else{
            if drawedUID1.count > currentPage{
                //上傳
                var updateGender = ""
                if(UserSetting.userGender == 0){
                    updateGender = "boysID"
                }else{
                    updateGender = "girlsID"
                }
                let ref1 = Database.database().reference().child("SharedSeatAnnotation/" + sharedSeatAnnotation.holderUID + "/" + updateGender + "/" + drawedUID1[currentPage])
                let ref2 = Database.database().reference().child("SharedSeatAnnotation/" + sharedSeatAnnotation.holderUID + "/" + updateGender + "/" + drawedUID2[currentPage])
                let refs = [ref1,ref2]
                var updateCount = 0
                for ref in refs{
                    ref.setValue("-"){ (error, ref) -> Void in
                        if error != nil{
                            print(error ?? "上傳參加者失敗")
                        }
                        updateCount += 1
                        if(updateCount == 2){
                            self.localDataChange()
                            self.open4PeopleMessageRoom()
                            self.dismissAndRefresh()
                        }
                    }
                }
            }
        }
        
        
    }
    
    @objc private func gobackBtnAct(){
        //        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func drawCardBtnAct(){
        drawCardBtn.isEnabled = false
        drawCard()
    }
    
    @objc private func addCoinBtnAct(){
        
        coinCountLabel.text = "    9"
        coinCountLabel.layer.borderColor = UIColor.hexStringToUIColor(hex: "#e1b808").cgColor
        coinCountLabel.layer.borderWidth = 1
        coinCountLabel.layer.cornerRadius = coinCountLabel.intrinsicContentSize.height/2 + 3
        coinCountLabel.layer.backgroundColor = UIColor.sksWhite().cgColor
        coinCountLabel.padding = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        coinCountLabel.frame = CGRect(x:topBar.frame.width - 16 - (coinCountLabel.intrinsicContentSize.width + 10), y:topBar.frame.height/2 - coinCountLabel.intrinsicContentSize.height/2 - 3, width: coinCountLabel.intrinsicContentSize.width + 10, height: coinCountLabel.intrinsicContentSize.height + 6)
        
        coinImageView.frame = CGRect(x:coinCountLabel.frame.origin.x + 1.5,y:coinCountLabel.frame.origin.y + 3,width:coinCountLabel.frame.height - 6,height:coinCountLabel.frame.height - 6)
        
    }
    
    @objc private func drawBackBtnAct(){
        let currentPage = Int(ceil(scrollView.contentOffset.x / view.frame.width))
        if(currentPage > 0){
            scrollView.setContentOffset(CGPoint(x: view.frame.width * CGFloat(currentPage - 1), y: 0), animated: true)
        }
    }
    
    @objc private func drawForwardBtnAct(){
        let currentPage = Int(ceil(scrollView.contentOffset.x / view.frame.width))
        if(currentPage + 1 < stackView.arrangedSubviews.count){
            scrollView.setContentOffset(CGPoint(x: view.frame.width * CGFloat(currentPage + 1), y: 0), animated: true)
        }
    }
    
    @objc private func goProfile(sender:ProfileUIButton){
        let profileViewController = ProfileViewController(UID: sender.UID!)
        profileViewController.modalPresentationStyle = .overFullScreen
        present(profileViewController, animated: true,completion: nil)
    }
    
}


extension DrawCardViewController: UIScrollViewDelegate {
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        changeBtnStatus(scrollView)
    }
    
    fileprivate func changeBtnStatus(_ scrollView: UIScrollView) {
        currentPage = Int(ceil(scrollView.contentOffset.x / view.frame.width))
        
        drawForwardBtn.alpha = 0.3
        drawForwardBtn.isEnabled = false
        drawBackBtn.alpha = 0.3
        drawBackBtn.isEnabled = false
        
        loveCardBtn.alpha = 0.3
        loveCardBtn.isEnabled = false
        
        if stackView.arrangedSubviews.count > 0 {
            loveCardBtn.alpha = 1
            loveCardBtn.isEnabled = true
        }
        
        if currentPage > 0 {
            drawBackBtn.alpha = 1
            drawBackBtn.isEnabled = true
        }
        
        if currentPage + 1 < stackView.arrangedSubviews.count {
            drawForwardBtn.alpha = 1
            drawForwardBtn.isEnabled = true
        }
    }
    
    
    
}


class ProfileUIButton: UIButton {
    var UID: String?
}
