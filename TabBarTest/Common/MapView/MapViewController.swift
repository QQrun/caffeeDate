//
//  ViewController.swift
//  AppMapTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/04/06.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import Alamofire
import SnapKit

protocol MapViewControllerViewDelegate: AnyObject {
    func gotoItemViewController_mapView(item:Item,personDetail:PersonDetailInfo)
    func gotoProfileViewController_mapView(personDetail:PersonDetailInfo)
    func gotoWantSellViewController_mapView(defaultItem:Item?)
    func gotoWantBuyViewController_mapView(defaultItem:Item?)
}

class MapViewController: UIViewController {
    
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    weak var viewDelegate: MapViewControllerViewDelegate?
    
    var mapView : MKMapView = MKMapView()
    var locationManager : CLLocationManager!
    
    let statusHeight = UIApplication.shared.statusBarFrame.size.height
    
    let exclamationPopUpBGButton = UIButton()
    let exclamationPopUpContainerView = UIView()
    let showOpenStoreButton = UIButton()
    let showRequestButton = UIButton()
    let showTeamUpButton = UIButton()
    let showCoffeeShopButton = UIButton()
    let showBoyButton = UIButton()
    let showGirlButton = UIButton()
    let bulletinBoardContainer = UIView() //for 背景
    let bulletinBoardTempContainer = UIView() //for 可替換的內部東西
    let bulletinBoard_BuySellPart = UIView() //bulletinBoardTempContainer的子view
    let bulletinBoard_ProfilePart = UIView() //bulletinBoardTempContainer的子view
    var bulletinBoard_ProfilePart_Middle = UIView() //bulletinBoard_ProfilePart的子view
    var bulletinBoard_ProfilePart_Bottom = UIView() //bulletinBoard_ProfilePart的子view
    let bulletinBoard_TeamUpPart = UIView() //bulletinBoardTempContainer的子view
    let bulletinBoard_CoffeeShop = UIView() //bulletinBoardTempContainer的子view
    let iWantActionSheetContainer = UIButton() //我想⋯⋯開店、徵求、揪團btn的容器
    
    
    var bookMarkClassificationNameLabels : [UILabel] = []
    var bookMarkClassificationNameBtns : [UIButton] = []
    var bookMarkClassificationNameLabels_ProfileBoard : [UILabel] = []
    
    let smallIconUnactiveColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 0.2)
    
    var bulletinBoardExpansionState: BulletinBoardExpansionState = .NotExpanded
    var actionSheetExpansionState: ActionSheetExpansionState = .NotExpanded
    
    var coffeeAnnotationGetter : CoffeeAnnotationGetter!
    var presonAnnotationGetter : PresonAnnotationGetter!
    
    var coffeeShop_url : String = "" //為了開啟瀏覽器去
    
    var photoTableView = UITableView()
    var smallItemTableView = UITableView()
    var bigItemTableView = UITableView()
    var photoDelegate = PhotoTableViewDelegate()
    var smallItemDelegate = ItemTableViewDelegate()
    var bigItemDelegate = BigItemTableViewDelegate()
    var bigItemTableViewRefreshControl : UIRefreshControl!
    
    var currentBulletinBoard : CurrentBulletinBoard = .Profile
    
    let bookMarkName_Sell = "擺攤"
    let bookMarkName_Buy = "任務"
    let bookMarkName_TeamUp = "號召"
    let bookMarkName_MakeFriend = "Hi！"
    var currentItemType : Item.ItemType = .Sell
    var personInfo : PersonDetailInfo! //現在要show的個人資訊
    
    let storeNameWordLimit = 12
    let storeNameTextFieldDelegate = WordLimitUITextFieldDelegate()
    var storeNameTextFieldCountLabel = UILabel()
    var storeNameTextField = UITextField()
    
    let iWantSayHiBtn = UIButton()
    
    private var storeRemainingTimeTimer = Timer()
    
    private let actionSheetKit = ActionSheetKit()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLocalUserDefaultByRemote()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        configureMapView()
        configMapButtons()
        
        initBulletinBoard()
        
        configureExclamationBtnPopUp()
        
        presonAnnotationGetter = PresonAnnotationGetter(mapView: mapView)
        presonAnnotationGetter.getPersonData()
        
        coffeeAnnotationGetter = CoffeeAnnotationGetter(mapView: mapView)
        coffeeAnnotationGetter.fetchCoffeeData()
        
        
        configureIWantActionSheet()
        
        AppStoreRating.share.listener()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        bigItemTableView.reloadData()
        smallItemTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        centerMapOnUserLocation(shouldLoadAnnotations: true)
    }
    
    fileprivate func configureIWantActionSheet() {
        
        
        iWantActionSheetContainer.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: view.frame.height)
        //        view.addSubview(iWantActionSheetContainer)
        
        let actionSheetText = ["取消","發布任務(徵求一場約會、二手物品⋯⋯)","擺攤(賣全新或二手商品、技術)","向周遭Say Hi交朋友"]
        actionSheetKit.creatActionSheet(containerView: view, actionSheetText: actionSheetText)
        actionSheetKit.getbgBtn().addTarget(self, action: #selector(iWantActionSheetBGBtnAct), for: .touchUpInside)
        actionSheetKit.getbgBtn().addSubview(iWantActionSheetContainer)
        iWantActionSheetContainer.addTarget(self, action: #selector(iWantActionSheetContainerAct), for: .touchUpInside)
        
        actionSheetKit.getActionSheetBtn(i: 0)?.addTarget(self, action: #selector(iWantConcealBtnAct), for: .touchUpInside)
        actionSheetKit.getActionSheetBtn(i: 1)?.addTarget(self, action: #selector(iWantRequestBtnAct), for: .touchUpInside)
        actionSheetKit.getActionSheetBtn(i: 2)?.addTarget(self, action: #selector(iWantOpenStoreBtnAct), for: .touchUpInside)
        actionSheetKit.getActionSheetBtn(i: 3)?.addTarget(self, action: #selector(iWantSayHiBtnAct), for: .touchUpInside)
        
        storeNameTextFieldCountLabel  = { () -> UILabel in
            let label = UILabel()
            label.text = "\(storeNameWordLimit - UserSetting.storeName.count)"
            label.textColor = UIColor.hexStringToUIColor(hex: "FFFFFF")
            label.font = UIFont(name: "HelveticaNeue", size: 12)
            label.textAlignment = .left
            label.frame = CGRect(x:view.frame.width/2 - 80, y:self.view.frame.height/2 - 90, width: 26, height: label.intrinsicContentSize.height)
            return label
        }()
        iWantActionSheetContainer.addSubview(storeNameTextFieldCountLabel)
        
        let separatorOfTextField = {() -> UIView in
            let view = UIView(frame: CGRect(x: self.view.frame.width/2 - 80, y: self.view.frame.height/2 - 94, width: 160, height: 1))
            view.backgroundColor = .white
            view.layer.cornerRadius = 2
            return view
        }()
        iWantActionSheetContainer.addSubview(separatorOfTextField)
        
        storeNameTextField = {() -> UITextField in
            let textField = UITextField()
            textField.tintColor = .white
            textField.frame = CGRect(x:self.view.frame.width/2 - 120, y: view.frame.height/2 - 135, width: 240, height: 60)
            textField.attributedPlaceholder = NSAttributedString(string:
                                                                    "在這寫下店名或想大聲說的話", attributes:
                                                                        [NSAttributedString.Key.foregroundColor:UIColor.hexStringToUIColor(hex: "B7B7B7")])
            textField.text = UserSetting.storeName
            textField.clearButtonMode = .whileEditing
            textField.textAlignment = .center
            textField.returnKeyType = .done
            textField.textColor = .white
            textField.font = UIFont(name: "HelveticaNeue-Light", size: 14)
            textField.backgroundColor = .clear
            storeNameTextFieldDelegate.wordLimitForTypeDelegate = self
            storeNameTextFieldDelegate.wordLimit = storeNameWordLimit
            storeNameTextFieldDelegate.wordLimitLabel = storeNameTextFieldCountLabel
            textField.delegate = storeNameTextFieldDelegate
            return textField
        }()
        iWantActionSheetContainer.addSubview(storeNameTextField)
        iWantActionSheetContainer.alpha = 0
    }
    
    
    
    fileprivate func initBulletinBoard(){
        
        bulletinBoardContainer.frame = CGRect(x: 0, y: view.frame.height , width: view.frame.width, height: view.frame.height - 40)
        
        bulletinBoardTempContainer.frame = CGRect(x: 0, y: 0 , width: view.frame.width, height: view.frame.height - 40)
        
        let bulletinBoardBG = UIImageView(frame: CGRect(x: 0, y: 10, width: view.frame.width, height: view.frame.height - 40 - 10))
        bulletinBoardBG.contentMode = .scaleToFill
        
        bulletinBoardBG.image = UIImage(named: "bulletinBoardParchmentBG")
        
        let bulletinBoardBookmarkBG = UIImageView()
        bulletinBoardBookmarkBG.frame = CGRect(x: -6, y: 0, width: view.frame.width + 14, height: 45)
        bulletinBoardBookmarkBG.contentMode = .scaleToFill
        bulletinBoardBookmarkBG.image = UIImage(named: "bulletinBoardBookMarkBG")
        
        view.addSubview(bulletinBoardContainer)
        bulletinBoardContainer.addSubview(bulletinBoardBG)
        bulletinBoardContainer.addSubview(bulletinBoardBookmarkBG)
        bulletinBoardContainer.addSubview(bulletinBoardTempContainer)
        
        bulletinBoard_BuySellPart.frame = CGRect(x: 0, y: 0 , width: bulletinBoardTempContainer.frame.width, height: bulletinBoardTempContainer.frame.height)
        bulletinBoardTempContainer.addSubview(bulletinBoard_BuySellPart)
        
        bulletinBoard_TeamUpPart.frame = CGRect(x: 0, y: 0 , width: bulletinBoardTempContainer.frame.width, height: bulletinBoardTempContainer.frame.height)
        bulletinBoardTempContainer.addSubview(bulletinBoard_TeamUpPart)
        
        bulletinBoard_ProfilePart.frame = CGRect(x: 0, y: 0 , width: bulletinBoardTempContainer.frame.width, height: bulletinBoardTempContainer.frame.height)
        bulletinBoardTempContainer.addSubview(bulletinBoard_ProfilePart)
        
        bulletinBoard_CoffeeShop.frame = CGRect(x: 0, y: 0 , width: bulletinBoardTempContainer.frame.width, height: bulletinBoardTempContainer.frame.height)
        bulletinBoardTempContainer.addSubview(bulletinBoard_CoffeeShop)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeUp.direction = .up
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeDown.direction = .down
        bulletinBoardTempContainer.addGestureRecognizer(swipeUp)
        bulletinBoardTempContainer.addGestureRecognizer(swipeDown)
        
    }
    
    @objc func handleSwipeGesture(sender: UISwipeGestureRecognizer) {
        
        if sender.direction == .up {
            //如果是在CoffeeShop頁，不能上滑
            if bulletinBoard_CoffeeShop.subviews.count > 0{
                return
            }
            
            if bulletinBoardExpansionState == .NotExpanded {
                let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
                animateBulletinBoard(targetPosition: view.frame.height - 274 - bottomPadding) { (_) in
                    self.bulletinBoardExpansionState = .PartiallyExpanded
                }
            }
            if bulletinBoardExpansionState == .PartiallyExpanded {
                
                bigItemTableView.reloadData()
                animateBulletinBoard(targetPosition: 40) { (_) in
                    self.bulletinBoardExpansionState = .FullyExpanded
                }
                
                
                if bulletinBoard_ProfilePart.isHidden == true{
                    bulletinBoard_ProfilePart.isHidden = false
                    bulletinBoard_ProfilePart.alpha = 0
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                        self.bulletinBoard_ProfilePart.alpha = 1
                        self.bulletinBoard_TeamUpPart.alpha = 0
                        self.bulletinBoard_BuySellPart.alpha = 0
                        self.bulletinBoard_CoffeeShop.alpha = 0
                    }, completion:  { _ in
                        self.bulletinBoard_TeamUpPart.isHidden = true
                        self.bulletinBoard_BuySellPart.isHidden = true
                        self.bulletinBoard_CoffeeShop.isHidden = true
                        self.bulletinBoard_TeamUpPart.alpha = 1
                        self.bulletinBoard_BuySellPart.alpha = 1
                        self.bulletinBoard_CoffeeShop.alpha = 1
                    })
                }
                
                
                
                //準備好profile面板的下方
                bulletinBoard_ProfilePart_Bottom.isHidden = false
                bulletinBoard_ProfilePart_Bottom.alpha = 0
                
                //關掉標籤的btn
                for btn in bookMarkClassificationNameBtns{
                    btn.isEnabled = false
                }
                //標籤fadeOut profile面板下方fadeIn
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                    for label in self.bookMarkClassificationNameLabels{
                        label.alpha = 0
                        self.bulletinBoard_ProfilePart_Middle.alpha = 0
                        self.bulletinBoard_ProfilePart_Bottom.alpha = 1
                    }
                }, completion: nil)
                
            }
        } else {
            
            bulletinBoard_ProfilePart_Middle.alpha = 1
            
            if bulletinBoardExpansionState == .FullyExpanded {
                //                animateBulletinBoard(targetPosition: view.frame.height - 274) { (_) in
                //                    self.bulletinBoardExpansionState = .PartiallyExpanded
                //                }
                //
                //
                //                switch currentBulletinBoard {
                //                case .Profile:
                //                    break
                //                case .Buy:
                //                    fadeInBuySellBoard()
                //                    break
                //                case .Sell:
                //                    fadeInBuySellBoard()
                //                    break
                //                case .TeamUp:
                //                    fadeInTeamUpBoard()
                //                    break
                //                }
                //
                //
                //                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                //                    for label in self.bookMarkClassificationNameLabels{
                //                        label.alpha = 1
                //                        self.bulletinBoard_ProfilePart_Bottom.alpha = 0
                //                    }
                //                }, completion: { _ in
                //                    for btn in self.bookMarkClassificationNameBtns{
                //                        btn.isEnabled = true
                //                    }
                //                    self.bulletinBoard_ProfilePart_Bottom.isHidden = true
                //                })
                mapView.deselectAnnotation(nil, animated: true)
                animateBulletinBoard(targetPosition: view.frame.height) { (_) in
                    self.bulletinBoardExpansionState = .NotExpanded
                }
                smallItemTableView.reloadData()
            }
            
            if bulletinBoardExpansionState == .PartiallyExpanded {
                mapView.deselectAnnotation(nil, animated: true)
                animateBulletinBoard(targetPosition: view.frame.height) { (_) in
                    self.bulletinBoardExpansionState = .NotExpanded
                }
            }
        }
    }
    
    func animateBulletinBoard(targetPosition: CGFloat, completion: @escaping(Bool) -> ()) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.bulletinBoardContainer.frame.origin.y = targetPosition
        }, completion: completion)
    }
    
    func animateActionSheet(targetAlpha:CGFloat,targetPosition: CGFloat, completion: @escaping(Bool) -> ()) {
        if targetAlpha == 1{
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, animations: {
                self.iWantActionSheetContainer.alpha = targetAlpha
                self.iWantActionSheetContainer.frame.origin.y = targetPosition
            }, completion: completion)
        }else{
            UIView.animate(withDuration: 0.5, delay: 0, animations: {
                self.iWantActionSheetContainer.alpha = targetAlpha
                self.iWantActionSheetContainer.frame.origin.y = targetPosition
            }, completion: completion)
        }
        
    }
    
    fileprivate func DrawStarsAfterLabel(_ board: UIView,_ label: UILabel,_ point:CGFloat) {
        
        
        let interval : CGFloat = 2
        let wifiStar_1 = UIImageView(frame: CGRect(x: label.frame.origin.x - 100 + view.frame.width/2 - interval * 4, y: label.frame.origin.y + 1, width: 16, height: 14.4))
        if point == 0{
            wifiStar_1.image = UIImage(named: "EmptyStar")
        }else if point == 0.5{
            wifiStar_1.image = UIImage(named: "HalfStar")
        }else {
            wifiStar_1.image = UIImage(named: "FullStar")
        }
        board.addSubview(wifiStar_1)
        let wifiStar_2 = UIImageView(frame: CGRect(x: label.frame.origin.x - 84 + view.frame.width/2 - interval * 3, y: label.frame.origin.y + 1, width: 16, height: 14.4))
        if point <= 1{
            wifiStar_2.image = UIImage(named: "EmptyStar")
        }else if point == 1.5{
            wifiStar_2.image = UIImage(named: "HalfStar")
        }else {
            wifiStar_2.image = UIImage(named: "FullStar")
        }
        board.addSubview(wifiStar_2)
        let wifiStar_3 = UIImageView(frame: CGRect(x: label.frame.origin.x - 68 + view.frame.width/2 - interval * 2, y: label.frame.origin.y + 1, width: 16, height: 14.4))
        if point <= 2{
            wifiStar_3.image = UIImage(named: "EmptyStar")
        }else if point == 2.5{
            wifiStar_3.image = UIImage(named: "HalfStar")
        }else {
            wifiStar_3.image = UIImage(named: "FullStar")
        }
        board.addSubview(wifiStar_3)
        let wifiStar_4 = UIImageView(frame: CGRect(x: label.frame.origin.x - 52 + view.frame.width/2 - interval, y: label.frame.origin.y + 1, width: 16, height: 14.4))
        if point <= 3{
            wifiStar_4.image = UIImage(named: "EmptyStar")
        }else if point == 3.5{
            wifiStar_4.image = UIImage(named: "HalfStar")
        }else {
            wifiStar_4.image = UIImage(named: "FullStar")
        }
        board.addSubview(wifiStar_4)
        let wifiStar_5 = UIImageView(frame: CGRect(x: label.frame.origin.x - 36 + view.frame.width/2, y: label.frame.origin.y + 1, width: 16, height: 14.4))
        if point <= 4{
            wifiStar_5.image = UIImage(named: "EmptyStar")
        }else if point == 4.5{
            wifiStar_5.image = UIImage(named: "HalfStar")
        }else {
            wifiStar_5.image = UIImage(named: "FullStar")
        }
        bulletinBoard_CoffeeShop.addSubview(wifiStar_5)
    }
    
    fileprivate func DrawStarsUnderLabel(_ board: UIView,_ label: UILabel,_ point:CGFloat) {
        
        let interval : CGFloat = 18
        let wifiStar_1 = UIImageView(frame: CGRect(x: label.frame.origin.x + label.intrinsicContentSize.width/2 - 88/2, y: label.frame.origin.y + 22, width: 16, height: 14.4))
        if point == 0{
            wifiStar_1.image = UIImage(named: "EmptyStar")
        }else if point == 0.5{
            wifiStar_1.image = UIImage(named: "HalfStar")
        }else {
            wifiStar_1.image = UIImage(named: "FullStar")
        }
        board.addSubview(wifiStar_1)
        let wifiStar_2 = UIImageView(frame: CGRect(x: label.frame.origin.x + label.intrinsicContentSize.width/2 - 88/2 + interval, y: label.frame.origin.y + 22, width: 16, height: 14.4))
        if point <= 1{
            wifiStar_2.image = UIImage(named: "EmptyStar")
        }else if point == 1.5{
            wifiStar_2.image = UIImage(named: "HalfStar")
        }else {
            wifiStar_2.image = UIImage(named: "FullStar")
        }
        board.addSubview(wifiStar_2)
        let wifiStar_3 = UIImageView(frame: CGRect(x: label.frame.origin.x + label.intrinsicContentSize.width/2 - 88/2 + interval * 2, y: label.frame.origin.y + 22, width: 16, height: 14.4))
        if point <= 2{
            wifiStar_3.image = UIImage(named: "EmptyStar")
        }else if point == 2.5{
            wifiStar_3.image = UIImage(named: "HalfStar")
        }else {
            wifiStar_3.image = UIImage(named: "FullStar")
        }
        board.addSubview(wifiStar_3)
        let wifiStar_4 = UIImageView(frame: CGRect(x: label.frame.origin.x + label.intrinsicContentSize.width/2 - 88/2 + interval * 3, y: label.frame.origin.y + 22, width: 16, height: 14.4))
        if point <= 3{
            wifiStar_4.image = UIImage(named: "EmptyStar")
        }else if point == 3.5{
            wifiStar_4.image = UIImage(named: "HalfStar")
        }else {
            wifiStar_4.image = UIImage(named: "FullStar")
        }
        board.addSubview(wifiStar_4)
        let wifiStar_5 = UIImageView(frame: CGRect(x: label.frame.origin.x + label.intrinsicContentSize.width/2 - 88/2 + interval * 4, y: label.frame.origin.y + 22, width: 16, height: 14.4))
        if point <= 4{
            wifiStar_5.image = UIImage(named: "EmptyStar")
        }else if point == 4.5{
            wifiStar_5.image = UIImage(named: "HalfStar")
        }else {
            wifiStar_5.image = UIImage(named: "FullStar")
        }
        board.addSubview(wifiStar_5)
    }
    
    fileprivate func setBulletinBoard_coffeeData(coffeeAnnotation : CoffeeAnnotation){
        
        bulletinBoard_CoffeeShop.isHidden = false
        bulletinBoard_TeamUpPart.isHidden = true
        bulletinBoard_BuySellPart.isHidden = true
        bulletinBoard_ProfilePart.isHidden = true
        
        let shopNameLabel = UILabel()
        shopNameLabel.font = UIFont(name: "HelveticaNeue", size: 16)
        shopNameLabel.text = coffeeAnnotation.name
        shopNameLabel.frame = CGRect(x: 15, y: 4, width: shopNameLabel.intrinsicContentSize.width, height: shopNameLabel.intrinsicContentSize.height)
        shopNameLabel.textColor = UIColor.hexStringToUIColor(hex: "000000")
        bulletinBoard_CoffeeShop.addSubview(shopNameLabel)
        
        let userloc = CLLocation(latitude: mapView.userLocation.coordinate.latitude, longitude: mapView.userLocation.coordinate.longitude)
        let coffeeloc = CLLocation(latitude: coffeeAnnotation.coordinate.latitude, longitude: coffeeAnnotation.coordinate.longitude)
        var distance = userloc.distance(from: coffeeloc)
        
        //        let distanceLabel = UILabel()
        //        distanceLabel.font = UIFont(name: "HelveticaNeue", size: 14)
        
        //        if Int(distance) >= 1000{
        //            distance = distance/1000
        //            distance = Double(Int(distance * 10))/10
        //            distanceLabel.text = "\(distance)" + "km"
        //        }else{
        //            distanceLabel.text = "\(Int(distance))" + "m"
        //        }
        //        distanceLabel.frame = CGRect(x: 15 + shopNameLabel.intrinsicContentSize.width + 2, y: 6, width: distanceLabel.intrinsicContentSize.width, height: distanceLabel.intrinsicContentSize.height)
        //        distanceLabel.textColor = UIColor.hexStringToUIColor(hex: "414141")
        //        bulletinBoard_CoffeeShop.addSubview(distanceLabel)
        
        let addressLabel = UILabel()
        addressLabel.font = UIFont(name: "HelveticaNeue", size: 12)
        addressLabel.text = coffeeAnnotation.address
        addressLabel.frame = CGRect(x: 15, y: 21, width: addressLabel.intrinsicContentSize.width, height: addressLabel.intrinsicContentSize.height)
        addressLabel.textColor = UIColor.hexStringToUIColor(hex: "414141")
        bulletinBoard_CoffeeShop.addSubview(addressLabel)
        
        
        if verifyUrl(urlString: coffeeAnnotation.url){
            coffeeShop_url = coffeeAnnotation.url
            let fbBtn = UIButton()
            fbBtn.frame = CGRect(x: view.frame.width - 24 - 12, y: 7, width: 24, height: 24)
            let fbIcon = UIImage(named: "facebookIcon")?.withRenderingMode(.alwaysTemplate)
            fbBtn.setImage(fbIcon, for: .normal)
            fbBtn.tintColor = UIColor.hexStringToUIColor(hex: "#751010")
            fbBtn.isEnabled = true
            fbBtn.addTarget(self, action: #selector(fbBtnAct), for: .touchUpInside)
            bulletinBoard_CoffeeShop.addSubview(fbBtn)
        }
        
        let commitIcon = UIImageView(frame: CGRect(x: 9, y: 45, width: 20, height: 18))
        commitIcon.image = UIImage(named: "commitIcon")
        bulletinBoard_CoffeeShop.addSubview(commitIcon)
        let commitLabel = UILabel()
        commitLabel.text = "評分：" + "\(coffeeAnnotation.reviews)" + "人"
        commitLabel.textColor = UIColor.hexStringToUIColor(hex: "000000")
        commitLabel.font = UIFont(name: "HelveticaNeue", size: 13)
        commitLabel.frame = CGRect(x: 9 + 20 + 2, y: 46, width: commitLabel.intrinsicContentSize.width, height: commitLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(commitLabel)
        
        let loveShopIcon = UIImageView(frame: CGRect(x: 9 + 20 + 2 + commitLabel.intrinsicContentSize.width + 4, y: 45, width: 18, height: 16))
        loveShopIcon.image = UIImage(named: "loveIcon")
        bulletinBoard_CoffeeShop.addSubview(loveShopIcon)
        let loveShopLabel = UILabel()
        loveShopLabel.text = "愛店：" + "\(coffeeAnnotation.favorites)" + "人"
        loveShopLabel.textColor = UIColor.hexStringToUIColor(hex: "000000")
        loveShopLabel.font = UIFont(name: "HelveticaNeue", size: 13)
        loveShopLabel.frame = CGRect(x: 9 + 20 + 2 + commitLabel.intrinsicContentSize.width + 4 + 18 + 3, y: 46, width: loveShopLabel.intrinsicContentSize.width, height: loveShopLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(loveShopLabel)
        
        let checkInIcon = UIImageView(frame: CGRect(x:9 + 20 + 2 + commitLabel.intrinsicContentSize.width + 4 + 18 + 3 + loveShopLabel.intrinsicContentSize.width + 4, y: 43, width: 15, height: 19))
        checkInIcon.image = UIImage(named: "chechInIcon")
        bulletinBoard_CoffeeShop.addSubview(checkInIcon)
        let checkInLabel = UILabel()
        checkInLabel.text = "打卡：" + "\(coffeeAnnotation.checkins)" + "人"
        checkInLabel.textColor = UIColor.hexStringToUIColor(hex: "000000")
        checkInLabel.font = UIFont(name: "HelveticaNeue", size: 13)
        checkInLabel.frame = CGRect(x: 9 + 20 + 2 + commitLabel.intrinsicContentSize.width + 4 + 18 + 3 + loveShopLabel.intrinsicContentSize.width + 4 + 15 + 3, y: 46, width: checkInLabel.intrinsicContentSize.width, height: checkInLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(checkInLabel)
        
        let wifiLabel = UILabel()
        wifiLabel.text = "WIFI穩定"
        wifiLabel.textColor = UIColor.hexStringToUIColor(hex: "000000")
        wifiLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        wifiLabel.frame = CGRect(x: 10, y: 68, width: wifiLabel.intrinsicContentSize.width, height: wifiLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(wifiLabel)
        let labelHeightWithInterval = wifiLabel.intrinsicContentSize.height + 8
        DrawStarsAfterLabel(bulletinBoard_CoffeeShop,wifiLabel,coffeeAnnotation.wifi)
        
        
        let quietLabel = UILabel()
        quietLabel.text = "安靜程度"
        quietLabel.textColor = UIColor.hexStringToUIColor(hex: "000000")
        quietLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        quietLabel.frame = CGRect(x: 10, y: 68 + labelHeightWithInterval, width: quietLabel.intrinsicContentSize.width, height: quietLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(quietLabel)
        DrawStarsAfterLabel(bulletinBoard_CoffeeShop,quietLabel,coffeeAnnotation.quiet)
        
        let seatLabel = UILabel()
        seatLabel.text = "通常有位"
        seatLabel.textColor = UIColor.hexStringToUIColor(hex: "000000")
        seatLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        seatLabel.frame = CGRect(x: 10, y: 68 + labelHeightWithInterval * 2, width: seatLabel.intrinsicContentSize.width, height: seatLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(seatLabel)
        DrawStarsAfterLabel(bulletinBoard_CoffeeShop,seatLabel,coffeeAnnotation.seat)
        
        let mondayLabel = UILabel()
        mondayLabel.text = "週一"
        mondayLabel.textColor = UIColor.hexStringToUIColor(hex: "000000")
        mondayLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        mondayLabel.frame = CGRect(x: 10, y: 68 + labelHeightWithInterval * 3, width: mondayLabel.intrinsicContentSize.width, height: mondayLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(mondayLabel)
        
        let mondayLabel_value = UILabel()
        mondayLabel_value.text = "公休"
        if let open = coffeeAnnotation.business_hours?.monday.open,let close = coffeeAnnotation.business_hours?.monday.close{
            mondayLabel_value.text = open + " ~ " + close
        }
        mondayLabel_value.textColor = UIColor.hexStringToUIColor(hex: "000000")
        mondayLabel_value.font = UIFont(name: "HelveticaNeue", size: 15)
        mondayLabel_value.frame = CGRect(x: view.frame.width/2 - mondayLabel_value.intrinsicContentSize.width - 10, y: 68 + labelHeightWithInterval * 3, width: mondayLabel_value.intrinsicContentSize.width, height: mondayLabel_value.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(mondayLabel_value)
        
        let tuesdayLabel = UILabel()
        tuesdayLabel.text = "週二"
        tuesdayLabel.textColor = UIColor.hexStringToUIColor(hex: "000000")
        tuesdayLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        tuesdayLabel.frame = CGRect(x: 10, y: 68 + labelHeightWithInterval * 4, width: tuesdayLabel.intrinsicContentSize.width, height: tuesdayLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(tuesdayLabel)
        
        let tuesdayLabel_value = UILabel()
        tuesdayLabel_value.text = "公休"
        if let open = coffeeAnnotation.business_hours?.tuesday.open,let close = coffeeAnnotation.business_hours?.tuesday.close{
            tuesdayLabel_value.text = open + " ~ " + close
        }
        tuesdayLabel_value.textColor = UIColor.hexStringToUIColor(hex: "000000")
        tuesdayLabel_value.font = UIFont(name: "HelveticaNeue", size: 15)
        tuesdayLabel_value.frame = CGRect(x: view.frame.width/2 - tuesdayLabel_value.intrinsicContentSize.width - 10, y: 68 + labelHeightWithInterval * 4, width: tuesdayLabel_value.intrinsicContentSize.width, height: tuesdayLabel_value.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(tuesdayLabel_value)
        
        let wednesdayLabel = UILabel()
        wednesdayLabel.text = "週三"
        wednesdayLabel.textColor = UIColor.hexStringToUIColor(hex: "000000")
        wednesdayLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        wednesdayLabel.frame = CGRect(x: 10, y: 68 + labelHeightWithInterval * 5, width: wednesdayLabel.intrinsicContentSize.width, height: wednesdayLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(wednesdayLabel)
        
        let wednesdayLabel_value = UILabel()
        wednesdayLabel_value.text = "公休"
        if let open = coffeeAnnotation.business_hours?.wednesday.open,let close = coffeeAnnotation.business_hours?.wednesday.close{
            wednesdayLabel_value.text = open + " ~ " + close
        }
        wednesdayLabel_value.textColor = UIColor.hexStringToUIColor(hex: "000000")
        wednesdayLabel_value.font = UIFont(name: "HelveticaNeue", size: 15)
        wednesdayLabel_value.frame = CGRect(x: view.frame.width/2 - wednesdayLabel_value.intrinsicContentSize.width - 10, y: 68 + labelHeightWithInterval * 5, width: wednesdayLabel_value.intrinsicContentSize.width, height: wednesdayLabel_value.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(wednesdayLabel_value)
        
        let thursdayLabel = UILabel()
        thursdayLabel.text = "週四"
        thursdayLabel.textColor = UIColor.hexStringToUIColor(hex: "000000")
        thursdayLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        thursdayLabel.frame = CGRect(x: 10, y: 68 + labelHeightWithInterval * 6, width: thursdayLabel.intrinsicContentSize.width, height: thursdayLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(thursdayLabel)
        
        let thursdayLabel_value = UILabel()
        thursdayLabel_value.text = "公休"
        if let open = coffeeAnnotation.business_hours?.thursday.open,let close = coffeeAnnotation.business_hours?.thursday.close{
            thursdayLabel_value.text = open + " ~ " + close
        }
        thursdayLabel_value.textColor = UIColor.hexStringToUIColor(hex: "000000")
        thursdayLabel_value.font = UIFont(name: "HelveticaNeue", size: 15)
        thursdayLabel_value.frame = CGRect(x: view.frame.width/2 - thursdayLabel_value.intrinsicContentSize.width - 10, y: 68 + labelHeightWithInterval * 6, width: thursdayLabel_value.intrinsicContentSize.width, height: thursdayLabel_value.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(thursdayLabel_value)
        
        let fridayLabel = UILabel()
        fridayLabel.text = "週五"
        fridayLabel.textColor = UIColor.hexStringToUIColor(hex: "000000")
        fridayLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        fridayLabel.frame = CGRect(x: 10, y: 68 + labelHeightWithInterval * 7, width: fridayLabel.intrinsicContentSize.width, height: fridayLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(fridayLabel)
        
        let fridayLabel_value = UILabel()
        fridayLabel_value.text = "公休"
        if let open = coffeeAnnotation.business_hours?.friday.open,let close = coffeeAnnotation.business_hours?.friday.close{
            fridayLabel_value.text = open + " ~ " + close
        }
        fridayLabel_value.textColor = UIColor.hexStringToUIColor(hex: "000000")
        fridayLabel_value.font = UIFont(name: "HelveticaNeue", size: 15)
        fridayLabel_value.frame = CGRect(x: view.frame.width/2 - fridayLabel_value.intrinsicContentSize.width - 10, y: 68 + labelHeightWithInterval * 7, width: fridayLabel_value.intrinsicContentSize.width, height: fridayLabel_value.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(fridayLabel_value)
        
        
        let tastyLabel = UILabel()
        tastyLabel.text = "咖啡好喝"
        tastyLabel.textColor = UIColor.hexStringToUIColor(hex: "000000")
        tastyLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        tastyLabel.frame = CGRect(x: view.frame.width/2 + 10, y: 68, width: tastyLabel.intrinsicContentSize.width, height: tastyLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(tastyLabel)
        DrawStarsAfterLabel(bulletinBoard_CoffeeShop,tastyLabel,coffeeAnnotation.tasty)
        
        let cheapLabel = UILabel()
        cheapLabel.text = "價格便宜"
        cheapLabel.textColor = UIColor.hexStringToUIColor(hex: "000000")
        cheapLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        cheapLabel.frame = CGRect(x: view.frame.width/2 + 10, y: 68 + labelHeightWithInterval, width: cheapLabel.intrinsicContentSize.width, height: cheapLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(cheapLabel)
        DrawStarsAfterLabel(bulletinBoard_CoffeeShop,cheapLabel,coffeeAnnotation.cheap)
        
        let musicLabel = UILabel()
        musicLabel.text = "裝潢音樂"
        musicLabel.textColor = UIColor.hexStringToUIColor(hex: "000000")
        musicLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        musicLabel.frame = CGRect(x: view.frame.width/2 + 10, y: 68 + labelHeightWithInterval * 2, width: musicLabel.intrinsicContentSize.width, height: musicLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(musicLabel)
        DrawStarsAfterLabel(bulletinBoard_CoffeeShop,musicLabel,coffeeAnnotation.music)
        
        let saturdayLabel = UILabel()
        saturdayLabel.text = "週六"
        saturdayLabel.textColor = UIColor.hexStringToUIColor(hex: "000000")
        saturdayLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        saturdayLabel.frame = CGRect(x:view.frame.width/2 + 10, y: 68 + labelHeightWithInterval * 3, width: saturdayLabel.intrinsicContentSize.width, height: saturdayLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(saturdayLabel)
        
        let saturdayLabel_value = UILabel()
        saturdayLabel_value.text = "公休"
        if let open = coffeeAnnotation.business_hours?.saturday.open,let close = coffeeAnnotation.business_hours?.saturday.close{
            saturdayLabel_value.text = open + " ~ " + close
        }
        saturdayLabel_value.textColor = UIColor.hexStringToUIColor(hex: "000000")
        saturdayLabel_value.font = UIFont(name: "HelveticaNeue", size: 15)
        saturdayLabel_value.frame = CGRect(x: view.frame.width - saturdayLabel_value.intrinsicContentSize.width - 10, y: 68 + labelHeightWithInterval * 3, width: saturdayLabel_value.intrinsicContentSize.width, height: saturdayLabel_value.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(saturdayLabel_value)
        
        let sundayLabel = UILabel()
        sundayLabel.text = "週日"
        sundayLabel.textColor = UIColor.hexStringToUIColor(hex: "000000")
        sundayLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        sundayLabel.frame = CGRect(x:view.frame.width/2 + 10, y: 68 + labelHeightWithInterval * 4, width: tuesdayLabel.intrinsicContentSize.width, height: tuesdayLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(sundayLabel)
        
        let sundayLabel_value = UILabel()
        sundayLabel_value.text = "公休"
        if let open = coffeeAnnotation.business_hours?.sunday.open,let close = coffeeAnnotation.business_hours?.sunday.close{
            sundayLabel_value.text = open + " ~ " + close
        }
        sundayLabel_value.textColor = UIColor.hexStringToUIColor(hex: "000000")
        sundayLabel_value.font = UIFont(name: "HelveticaNeue", size: 15)
        sundayLabel_value.frame = CGRect(x: view.frame.width - sundayLabel_value.intrinsicContentSize.width - 10, y: 68 + labelHeightWithInterval * 4, width: sundayLabel_value.intrinsicContentSize.width, height: sundayLabel_value.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(sundayLabel_value)
        
        
        //TAG
        var currentTagX = view.frame.width/2 + 10
        var currentTagY = 68 + labelHeightWithInterval * 5
        if coffeeAnnotation.tags.count > 0 {
            for i in 0 ... coffeeAnnotation.tags.count - 1{
                let lbl = createTagLabel(text: coffeeAnnotation.tags[i])
                
                if(currentTagX + lbl.intrinsicContentSize.width + 5  + 10 > view.frame.width){
                    currentTagX = view.frame.width/2 + 10
                    currentTagY += labelHeightWithInterval
                }
                if(currentTagY > 68 + labelHeightWithInterval * 7){
                    continue
                }
                lbl.frame = CGRect(x: currentTagX, y: currentTagY,width:lbl.intrinsicContentSize.width, height: lbl.intrinsicContentSize.height)
                currentTagX += lbl.intrinsicContentSize.width + 5 //5為tag間隔
                bulletinBoard_CoffeeShop.addSubview(lbl)
            }}
        
    }
    
    private func createTagLabel(text: String) -> PaddingLabel {
        let lbl = PaddingLabel()
        lbl.text = text
        lbl.leftInset = 2.0
        lbl.rightInset = 2.0
        lbl.topInset = 2.0
        lbl.bottomInset = 2.0
        lbl.textColor = UIColor.hexStringToUIColor(hex: "#f2f2f2")
        lbl.backgroundColor = UIColor.hexStringToUIColor(hex: "#472411")
        lbl.cornerRadius = 2
        lbl.font = .systemFont(ofSize: 14)
        
        return lbl
    }
    
    fileprivate func updateLocalUserDefaultByRemote() {
        //從遠端讀取資料更新本地端的設定
        let ref = Database.database().reference()
        ref.child("PersonDetail/" + UserSetting.UID).observeSingleEvent(of: .value, with:{(snapshot) in
                                                                            if snapshot.exists(){
                                                                                
                                                                                let userDetail = PersonDetailInfo(snapshot: snapshot)
                                                                                
                                                                                //做出sellItemsID
                                                                                var storeSellItems : [Item] = []
                                                                                if let childSnapshots = snapshot.childSnapshot(forPath: "SellItems").children.allObjects as? [DataSnapshot] {
                                                                                    for childSnapshot in childSnapshots{
                                                                                        let item = Item(snapshot: childSnapshot)
                                                                                        item.itemID = childSnapshot.key
                                                                                        item.thumbnail = UIImage()
                                                                                        storeSellItems.append(item)
                                                                                    }
                                                                                }
                                                                                storeSellItems = Util.quicksort_Item(storeSellItems)
                                                                                var sellItemsID : [String] = []
                                                                                for item in storeSellItems{
                                                                                    sellItemsID.append(item.itemID!)
                                                                                }
                                                                                //做出buyItemsID
                                                                                var storeBuyItems : [Item] = []
                                                                                if let childSnapshots = snapshot.childSnapshot(forPath: "BuyItems").children.allObjects as? [DataSnapshot] {
                                                                                    for childSnapshot in childSnapshots{
                                                                                        let item = Item(snapshot: childSnapshot)
                                                                                        item.itemID = childSnapshot.key
                                                                                        item.thumbnail = UIImage()
                                                                                        storeBuyItems.append(item)
                                                                                    }
                                                                                }
                                                                                storeBuyItems = Util.quicksort_Item(storeBuyItems)
                                                                                var buyItemsID : [String] = []
                                                                                for item in storeBuyItems{
                                                                                    buyItemsID.append(item.itemID!)
                                                                                }
                                                                                
                                                                                //做出isWantSellSomething
                                                                                var isWantSellSomething = false
                                                                                if sellItemsID.count > 0 {
                                                                                    isWantSellSomething = true
                                                                                }
                                                                                
                                                                                //做出isWantBuySomething
                                                                                var isWantBuySomething = false
                                                                                if buyItemsID.count > 0{
                                                                                    isWantBuySomething = true
                                                                                }
                                                                                
                                                                                //做出photoURLs
                                                                                var photoURLs : [String] = []
                                                                                var photoURLsDict : [Int : String] =  [:]
                                                                                if let childSnapshots = snapshot.childSnapshot(forPath: "photos").children.allObjects as? [DataSnapshot] {
                                                                                    for childSnapshot in childSnapshots{
                                                                                        let photoNumber = Int(childSnapshot.key)
                                                                                        photoURLsDict[photoNumber!] = childSnapshot.value as? String ?? ""
                                                                                    }
                                                                                    let sortedByKeyDictionary = photoURLsDict.sorted { firstDictionary, secondDictionary in
                                                                                        return firstDictionary.0 < secondDictionary.0 // 由小到大排序
                                                                                    }
                                                                                    
                                                                                    for data in sortedByKeyDictionary{
                                                                                        photoURLs.append(data.value)
                                                                                    }
                                                                                }
                                                                                
                                                                                let dic = ["alreadyUpdatePersonDetail":true,
                                                                                           "UID":UserSetting.UID,
                                                                                           "userName":userDetail.name,
                                                                                           "userBirthDay":userDetail.birthday,
                                                                                           "userGender":userDetail.gender,
                                                                                           "userSelfIntroduction":userDetail.selfIntroduction,
                                                                                           "isMapShowOpenStore": UserSetting.isMapShowTeamUp,
                                                                                           "isMapShowRequest":UserSetting.isMapShowRequest,
                                                                                           "isMapShowTeamUp":UserSetting.isMapShowTeamUp,
                                                                                           "isMapShowCoffeeShop":UserSetting.isMapShowCoffeeShop,
                                                                                           "isMapShowMakeFriend_Boy":UserSetting.isMapShowMakeFriend_Boy,
                                                                                           "isMapShowMakeFriend_Girl":UserSetting.isMapShowMakeFriend_Girl,
                                                                                           "perferIconStyleToShowInMap":userDetail.perferIconStyleToShowInMap,
                                                                                           "isWantSellSomething":isWantSellSomething,
                                                                                           "isWantBuySomething":isWantBuySomething,
                                                                                           "sellItemsID":sellItemsID,
                                                                                           "buyItemsID":buyItemsID,
                                                                                           "userPhotosUrl":photoURLs,
                                                                                           "currentChatTarget":"",] as [String : Any]
                                                                                for data in dic {
                                                                                    UserDefaults.standard.set(data.value, forKey: data.key)
                                                                                }
                                                                                if let headshot = userDetail.headShot{
                                                                                    UserDefaults.standard.set(headshot, forKey: "userSmallHeadShotURL")
                                                                                }
                                                                                
                                                                                
                                                                            }})
    }
    
    fileprivate func cleanBulletinBoard() {
        for view in bulletinBoardTempContainer.subviews{
            view.removeFromSuperview()
        }
        for view in bulletinBoard_BuySellPart.subviews{
            view.removeFromSuperview()
        }
        for view in bulletinBoard_ProfilePart.subviews{
            view.removeFromSuperview()
        }
        for view in bulletinBoard_TeamUpPart.subviews{
            view.removeFromSuperview()
        }
        for view in bulletinBoard_CoffeeShop.subviews{
            view.removeFromSuperview()
        }
        bulletinBoardTempContainer.addSubview(bulletinBoard_BuySellPart)
        bulletinBoardTempContainer.addSubview(bulletinBoard_ProfilePart)
        bulletinBoardTempContainer.addSubview(bulletinBoard_TeamUpPart)
        bulletinBoardTempContainer.addSubview(bulletinBoard_CoffeeShop)
    }
    
    fileprivate func setBulletinBoard(bookMarks: [String],selectedbookMark: String,snapshot: DataSnapshot,UID:String,distance:Int,storeName:String,openTimeString:String){
        
        
        personInfo = PersonDetailInfo(snapshot: snapshot)
        
        //做出書頁標籤
        for i in 0 ... bookMarks.count - 1{
            let classificationNameLabel = UILabel()
            classificationNameLabel.text = bookMarks[i]
            classificationNameLabel.font = UIFont(name: "HelveticaNeue", size: 15)
            classificationNameLabel.numberOfLines = 0
            classificationNameLabel.textColor = UIColor.hexStringToUIColor(hex: "#414141")
            classificationNameLabel.frame = CGRect(x: (0.5 + CGFloat(i)) * view.frame.width/CGFloat(bookMarks.count) - classificationNameLabel.intrinsicContentSize.width/2,y:19 - classificationNameLabel.intrinsicContentSize.height/2,width: classificationNameLabel.intrinsicContentSize.width + 2, height: classificationNameLabel.intrinsicContentSize.height)
            bulletinBoardTempContainer.addSubview(classificationNameLabel)
            bookMarkClassificationNameLabels.append(classificationNameLabel)
            
            
            let classificationNameButton = UIButton()
            classificationNameButton.isEnabled = true
            
            classificationNameButton.frame = CGRect(x:CGFloat(i) * view.frame.width/CGFloat(bookMarks.count),y:0,width: view.frame.width/CGFloat(bookMarks.count),height: 35)
            
            
            
            if bookMarks[i] == bookMarkName_Sell{
                classificationNameButton.addTarget(self, action: #selector(bookMarkAct_OpenStore), for: .touchUpInside)
            }else if bookMarks[i] == bookMarkName_Buy{
                classificationNameButton.addTarget(self, action: #selector(bookMarkAct_Request), for: .touchUpInside)
            }else if bookMarks[i] == bookMarkName_TeamUp{
                classificationNameButton.addTarget(self, action: #selector(bookMarkAct_TeamUp), for: .touchUpInside)
            }else if bookMarks[i] == bookMarkName_MakeFriend{
                classificationNameButton.addTarget(self, action: #selector(bookMarkAct_Profile), for: .touchUpInside)
            }
            
            bookMarkClassificationNameBtns.append(classificationNameButton)
            bulletinBoardTempContainer.addSubview(classificationNameButton)
            
        }
        
        //做出未滑開時的照片與小itemTableView
        let photoTableViewContainer = UIView()
        photoTableViewContainer.frame = CGRect(x: 0, y: 36 + 4, width: view.frame.width, height: 96)
        let smallItemTableViewContainer = UIView()
        smallItemTableViewContainer.frame = CGRect(x: 0, y: 36 + 96 + 4 + 5.3, width: view.frame.width, height: bulletinBoardTempContainer.frame.height - (36 + 96 - 5.3))
        
        photoTableView = UITableView()
        
        
        photoDelegate.viewDelegate = viewDelegate
        photoDelegate.personDetail = personInfo
        photoDelegate.currentItemType = currentItemType
        photoTableView.frame = CGRect(x: 0, y: 0, width: 96, height: view.frame.width)
        photoTableView.center = CGPoint(x: view.frame.width/2.0, y: 96/2.0)
        photoTableView.transform = CGAffineTransform(rotationAngle: -CGFloat(M_PI)/2)
        photoTableView.delegate = photoDelegate
        photoTableView.dataSource = photoDelegate
        photoTableView.showsVerticalScrollIndicator = false
        photoTableView.register(PhotoTableViewCell.self, forCellReuseIdentifier: "photoTableViewCell")
        photoTableView.rowHeight = 96
        photoTableView.estimatedRowHeight = 0
        photoTableView.backgroundColor = .clear
        photoTableView.separatorColor = .clear
        bulletinBoard_BuySellPart.addSubview(photoTableViewContainer)
        photoTableViewContainer.addSubview(photoTableView)        
        
        
        let separatorForSmallItemTableViewTop = { () -> UIImageView in
            let imageView = UIImageView()
            imageView.image = UIImage(named: "分隔線擦痕")
            imageView.frame = CGRect(x:5, y: photoTableViewContainer.frame.maxY + 2.5, width: UIScreen.main.bounds.size.width - 13, height: 1.3)
            imageView.contentMode = .scaleToFill
            return imageView
        }()
        bulletinBoard_BuySellPart.addSubview(separatorForSmallItemTableViewTop)
        
        smallItemDelegate.personDetail = personInfo
        smallItemDelegate.currentItemType = currentItemType
        smallItemDelegate.viewDelegate = viewDelegate
        bulletinBoard_BuySellPart.addSubview(smallItemTableViewContainer)
        smallItemTableView = UITableView()
        smallItemTableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: bulletinBoardTempContainer.frame.height - (36 + 96))
        smallItemTableView.showsVerticalScrollIndicator = false
        smallItemTableView.rowHeight = 44
        smallItemTableView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        smallItemTableView.delegate = smallItemDelegate
        smallItemTableView.dataSource = smallItemDelegate
        smallItemTableView.register(ItemTableViewCell.self, forCellReuseIdentifier: "itemTableViewCell")
        
        smallItemTableView.isScrollEnabled = false
        smallItemTableView.separatorColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        smallItemTableViewContainer.addSubview(smallItemTableView)
        
        bulletinBoard_BuySellPart.isHidden = true
        
        ////ProfileBoard
        //照片
        let mediumSizeHeadShot = UIImageView()
        mediumSizeHeadShot.frame = CGRect(x: 9, y: 47, width: 120, height: 120)
        mediumSizeHeadShot.layer.cornerRadius = 60
        mediumSizeHeadShot.clipsToBounds = true
        let loadingView = UIImageView(frame: CGRect(x: mediumSizeHeadShot.frame.minX + mediumSizeHeadShot.frame.width * 1/12, y: mediumSizeHeadShot.frame.minY + mediumSizeHeadShot.frame.height * 1/12, width: mediumSizeHeadShot.frame.width * 5/6, height: mediumSizeHeadShot.frame.height * 5/6))
        loadingView.contentMode = .scaleAspectFit
        if personInfo.gender == 0{
            loadingView.image = UIImage(named: "girlIcon")?.withRenderingMode(.alwaysTemplate)
        }else{
            loadingView.image = UIImage(named: "boyIcon")?.withRenderingMode(.alwaysTemplate)
        }
        loadingView.tintColor = UIColor.hexStringToUIColor(hex: "472411")
        bulletinBoard_ProfilePart.addSubview(loadingView)
        bulletinBoard_ProfilePart.addSubview(mediumSizeHeadShot)
        if personInfo.photos != nil{
            mediumSizeHeadShot.contentMode = .scaleAspectFill
            mediumSizeHeadShot.alpha = 0
            AF.request(personInfo.photos![0]).response { (response) in
                guard let data = response.data, let image = UIImage(data: data)
                else { return }
                mediumSizeHeadShot.image = image
                UIView.animate(withDuration: 0.4, animations:{
                    mediumSizeHeadShot.alpha = 1
                    loadingView.alpha = 0
                })
                self.personInfo.headShotContainer = image
            }
        }
        
        //姓名
        let nameLabel = UILabel()
        nameLabel.font = UIFont(name: "HelveticaNeue", size: 18)
        nameLabel.textColor = UIColor.hexStringToUIColor(hex: "000000")
        nameLabel.text = personInfo.name
        nameLabel.frame = CGRect(x: 9 + 120 + 6, y: 47, width: nameLabel.intrinsicContentSize.width, height: nameLabel.intrinsicContentSize.height)
        bulletinBoard_ProfilePart.addSubview(nameLabel)
        
        //年齡
        let ageLabel = UILabel()
        ageLabel.font = UIFont(name: "HelveticaNeue", size: 16)
        ageLabel.textColor = UIColor.hexStringToUIColor(hex: "000000")
        let birthdayFormatter = DateFormatter()
        birthdayFormatter.dateFormat = "yyyy/MM/dd"
        let currentTime = Date()
        let birthDayDate = birthdayFormatter.date(from: personInfo.birthday)
        let age = currentTime.years(sinceDate: birthDayDate!) ?? 0
        if age != 0 {
            ageLabel.text = "\(age)"
        }
        ageLabel.frame = CGRect(x: 9 + 120 + 6 + nameLabel.intrinsicContentSize.width + 4, y: 49, width: nameLabel.intrinsicContentSize.width, height: ageLabel.intrinsicContentSize.height)
        bulletinBoard_ProfilePart.addSubview(ageLabel)
        
        //登入時間與icon
        let signInTimeIconImageView = UIImageView()
        let signInTimeIcon = UIImage(named: "GreenCircle")?.withRenderingMode(.alwaysTemplate)
        signInTimeIconImageView.image = signInTimeIcon
        signInTimeIconImageView.frame = CGRect(x: 9 + 120 + 6, y: 71.5, width: 14, height: 14)
        bulletinBoard_ProfilePart.addSubview(signInTimeIconImageView)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMddHHmmss"
        var currentTimeString = dateFormatter.string(from: currentTime)
        
        let lastSignInTime = dateFormatter.date(from: personInfo.lastSignInTime)!
        
        let green = UIColor.hexStringToUIColor(hex: "#389627")
        let orange = UIColor.hexStringToUIColor(hex: "#FFB034")
        let gray = UIColor.hexStringToUIColor(hex: "#D8D7DC")
        
        let elapsedYear = currentTime.years(sinceDate: lastSignInTime) ?? 0
        var elapsedMonth = currentTime.months(sinceDate: lastSignInTime) ?? 0
        elapsedMonth %= 12
        var elapsedDay = currentTime.days(sinceDate: lastSignInTime) ?? 0
        elapsedDay %= 30
        var elapsedHour = currentTime.hours(sinceDate: lastSignInTime) ?? 0
        elapsedHour %= 24
        var elapsedMinute = currentTime.minutes(sinceDate: lastSignInTime) ?? 0
        elapsedMinute %= 60
        
        var finalTimeString : String = ""
        if elapsedYear > 0 {
            finalTimeString = "3個月以上"
            signInTimeIconImageView.tintColor = gray
        }else if elapsedMonth >= 3{
            finalTimeString = "3個月以上"
            signInTimeIconImageView.tintColor = gray
        }else if elapsedMonth > 0{
            finalTimeString = "3個月以內"
            signInTimeIconImageView.tintColor = gray
        }else if elapsedDay > 21{
            finalTimeString = "1個月以內"
            signInTimeIconImageView.tintColor = gray
        }else if elapsedDay > 14{
            finalTimeString = "3週以內"
            signInTimeIconImageView.tintColor = gray
        }else if elapsedDay > 7{
            finalTimeString = "2週以內"
            signInTimeIconImageView.tintColor = gray
        }else if elapsedDay > 3{
            finalTimeString = "1週以內"
            signInTimeIconImageView.tintColor = orange
        }else if elapsedDay > 0{
            finalTimeString = "3天以內"
            signInTimeIconImageView.tintColor = orange
        }else if elapsedHour > 3{
            finalTimeString = "24小時以內"
            signInTimeIconImageView.tintColor = green
        }else if elapsedHour > 0{
            finalTimeString = "3小時以內"
            signInTimeIconImageView.tintColor = green
        }else if elapsedMinute > 5{
            finalTimeString = "1小時以內"
            signInTimeIconImageView.tintColor = green
        }else{
            finalTimeString = "正在線上"
            signInTimeIconImageView.tintColor = green
        }
        
        
        let signInTimeLabel = UILabel()
        signInTimeLabel.font = UIFont(name: "HelveticaNeue", size: 14)
        signInTimeLabel.textColor = .black
        signInTimeLabel.text = finalTimeString
        signInTimeLabel.frame = CGRect(x: 9 + 120 + 6 + 14 + 4, y: 69.6, width: signInTimeLabel.intrinsicContentSize.width, height: signInTimeLabel.intrinsicContentSize.height)
        bulletinBoard_ProfilePart.addSubview(signInTimeLabel)
        
        
        let selfIntroductionLabel = UILabel()
        selfIntroductionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        selfIntroductionLabel.textColor = .black
        selfIntroductionLabel.text = personInfo.selfIntroduction
        selfIntroductionLabel.numberOfLines = 0
        selfIntroductionLabel.textAlignment = .left
        selfIntroductionLabel.frame = CGRect(x: 135, y: 89.5, width: view.frame.width - 145, height: 66.4)
        bulletinBoard_ProfilePart.addSubview(selfIntroductionLabel)
        selfIntroductionLabel.sizeToFit()
        //66.4是四行的高度 如果超過四行，就縮小
        if selfIntroductionLabel.frame.height > 66.4{
            selfIntroductionLabel.frame = CGRect(x: 135, y: 89.5, width: view.frame.width - 138, height: 66.4)
        }
        
        //點擊照片或是自我介紹，前往PhotoProfileView
        let gotoPhotoProfileViewBtn = { () -> UIButton in
            let btn = UIButton()
            btn.frame = CGRect(x: 0, y: 47, width: view.frame.width, height: 120)
            btn.addTarget(self, action: #selector(gotoPhotoProfileViewBtnAct), for: .touchUpInside)
            return btn
        }()
        bulletinBoard_ProfilePart.addSubview(gotoPhotoProfileViewBtn)
        
        
        if UserSetting.UID != UID{
            let mailBtn = MailButton(personInfo: personInfo)
            mailBtn.setImage(UIImage(named: "飛鴿傳書icon"), for: .normal)
            mailBtn.frame = CGRect(x: bulletinBoard_ProfilePart.frame.width - 50 - 9, y: 45, width: 50, height: 42)
            //            mailBtn.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            mailBtn.isEnabled = true
            bulletinBoard_ProfilePart.addSubview(mailBtn)
        }
        
        //        let tradeEvaluationLabel = UILabel()
        //        tradeEvaluationLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        //        tradeEvaluationLabel.textColor = .black
        //        tradeEvaluationLabel.text = "交易評價"
        //        tradeEvaluationLabel.frame = CGRect(x: bulletinBoard_ProfilePart.frame.width * 1/4 - tradeEvaluationLabel.intrinsicContentSize.width/2, y: 47 + 120 + 9, width: tradeEvaluationLabel.intrinsicContentSize.width, height: tradeEvaluationLabel.intrinsicContentSize.height)
        //        bulletinBoard_ProfilePart.addSubview(tradeEvaluationLabel)
        //        DrawStarsUnderLabel(bulletinBoard_ProfilePart,tradeEvaluationLabel,4.5)
        //
        //        let tradeEvaluationCountLabel = UILabel()
        //        tradeEvaluationCountLabel.font = UIFont(name: "HelveticaNeue", size: 12)
        //        tradeEvaluationCountLabel.textColor = UIColor.hexStringToUIColor(hex: "414141")
        //        tradeEvaluationCountLabel.text =  "("+"\(personInfo.tradeEvaluationCount)" + ")"
        //        tradeEvaluationCountLabel.frame = CGRect(x: bulletinBoard_ProfilePart.frame.width * 1/4 + 44 + 2, y: 47 + 120 + 9 + 22, width: tradeEvaluationCountLabel.intrinsicContentSize.width, height: tradeEvaluationCountLabel.intrinsicContentSize.height)
        //        bulletinBoard_ProfilePart.addSubview(tradeEvaluationCountLabel)
        
        //        if personInfo.tradeEvaluationCommentCount > 0{
        //            let tradeEvaluationCommentLabel = UILabel()
        //            tradeEvaluationCommentLabel.font = UIFont(name: "HelveticaNeue", size: 12)
        //            tradeEvaluationCommentLabel.textColor = UIColor.hexStringToUIColor(hex: "751010")
        //            tradeEvaluationCommentLabel.text = "查看 " + "\(personInfo.tradeEvaluationCommentCount)" + " 則評論"
        //            tradeEvaluationCommentLabel.frame = CGRect(x: bulletinBoard_ProfilePart.frame.width * 1/4 - tradeEvaluationCommentLabel.intrinsicContentSize.width/2, y: 47 + 120 + 9 + 22 + tradeEvaluationCountLabel.intrinsicContentSize.height + 5, width: tradeEvaluationCommentLabel.intrinsicContentSize.width, height: tradeEvaluationCommentLabel.intrinsicContentSize.height)
        //            bulletinBoard_ProfilePart.addSubview(tradeEvaluationCommentLabel)
        //
        //            let tradeEvaluationCommentBtn = UIButton()
        //            tradeEvaluationCommentBtn.frame = CGRect(x: bulletinBoard_ProfilePart.frame.width * 1/4 - 44, y: 47 + 120 + 9, width: 100, height: 60)
        //            bulletinBoard_ProfilePart.addSubview(tradeEvaluationCommentBtn)
        //        }
        
        //        let teamUpEvaluationLabel = UILabel()
        //        teamUpEvaluationLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        //        teamUpEvaluationLabel.textColor = .black
        //        teamUpEvaluationLabel.text = "揪團評價"
        //        teamUpEvaluationLabel.frame = CGRect(x: bulletinBoard_ProfilePart.frame.width * 3/4 - teamUpEvaluationLabel.intrinsicContentSize.width/2, y: 47 + 120 + 9, width: teamUpEvaluationLabel.intrinsicContentSize.width, height: teamUpEvaluationLabel.intrinsicContentSize.height)
        //        bulletinBoard_ProfilePart.addSubview(teamUpEvaluationLabel)
        //        DrawStarsUnderLabel(bulletinBoard_ProfilePart,teamUpEvaluationLabel,3.5)
        
        
        //        let teamupEvaluationCountLabel = UILabel()
        //        teamupEvaluationCountLabel.font = UIFont(name: "HelveticaNeue", size: 12)
        //        teamupEvaluationCountLabel.textColor = UIColor.hexStringToUIColor(hex: "414141")
        //        teamupEvaluationCountLabel.text =  "("+"\(personInfo.teamUpEvaluationCount)" + ")"
        //        teamupEvaluationCountLabel.frame = CGRect(x: bulletinBoard_ProfilePart.frame.width * 3/4 + 44 + 2, y: 47 + 120 + 9 + 22, width: teamupEvaluationCountLabel.intrinsicContentSize.width, height: teamupEvaluationCountLabel.intrinsicContentSize.height)
        //        bulletinBoard_ProfilePart.addSubview(teamupEvaluationCountLabel)
        
        //        if personInfo.teamUpEvaluationCommentCount > 0{
        //            let teamupEvaluationCommentLabel = UILabel()
        //            teamupEvaluationCommentLabel.font = UIFont(name: "HelveticaNeue", size: 12)
        //            teamupEvaluationCommentLabel.textColor = UIColor.hexStringToUIColor(hex: "751010")
        //            teamupEvaluationCommentLabel.text = "查看 " + "\(personInfo.teamUpEvaluationCommentCount)" + " 則評論"
        //            teamupEvaluationCommentLabel.frame = CGRect(x: bulletinBoard_ProfilePart.frame.width * 3/4 - teamupEvaluationCommentLabel.intrinsicContentSize.width/2, y: 47 + 120 + 9 + 22 + tradeEvaluationCountLabel.intrinsicContentSize.height + 5, width: teamupEvaluationCommentLabel.intrinsicContentSize.width, height: teamupEvaluationCommentLabel.intrinsicContentSize.height)
        //            bulletinBoard_ProfilePart.addSubview(teamupEvaluationCommentLabel)
        //
        //            let teamupEvaluationCommentBtn = UIButton()
        //            teamupEvaluationCommentBtn.frame = CGRect(x: bulletinBoard_ProfilePart.frame.width * 3/4 - 44, y: 47 + 120 + 9, width: 100, height: 60)
        //            bulletinBoard_ProfilePart.addSubview(teamupEvaluationCommentBtn)
        //        }
        
        bulletinBoard_ProfilePart_Middle = UIView()
        bulletinBoard_ProfilePart_Middle.frame = CGRect(x: 0, y: 47 + 120 + 9, width: bulletinBoard_ProfilePart.frame.width, height: 100)
        bulletinBoard_ProfilePart.addSubview(bulletinBoard_ProfilePart_Middle)
        
        let remainingTimeLabel = { () -> UILabel in
            let label = UILabel()
            label.text = "刊登剩餘時間  99：99：99"
            label.textColor = UIColor.hexStringToUIColor(hex: "472411")
            label.font = UIFont(name: "HelveticaNeue", size: 14)
            label.frame = CGRect(x: bulletinBoard_ProfilePart_Middle.frame.width - 18 - label.intrinsicContentSize.width, y: 0, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            label.text = ""
            label.textAlignment = .right
            return label
        }()
        bulletinBoard_ProfilePart_Middle.addSubview(remainingTimeLabel)
        startRemainingStoreOpenTimer(lebal: remainingTimeLabel, storeOpenTimeString: openTimeString, durationOfAuction: 60 * 60 * 24 * 3)
        
        let plzSlideUpImageView = {() -> UIImageView in
            let imageView = UIImageView(frame: CGRect(x: self.bulletinBoard_ProfilePart_Middle.frame.width/2 - 19/2, y: remainingTimeLabel.frame.maxY + 21, width: 19, height: 19))
            imageView.image = UIImage(named: "plzSlideUp")
            return imageView
        }()
        bulletinBoard_ProfilePart_Middle.addSubview(plzSlideUpImageView)
        
        
        let plzSlideUpLabel = { () -> UILabel in
            let label = UILabel()
            label.text = "上滑展開攤販詳細資訊"
            label.textColor = UIColor.hexStringToUIColor(hex: "751010")
            label.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
            label.frame = CGRect(x: bulletinBoard_ProfilePart_Middle.frame.width/2 - label.intrinsicContentSize.width/2, y: plzSlideUpImageView.frame.maxY + 6, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            return label
        }()
        bulletinBoard_ProfilePart_Middle.addSubview(plzSlideUpLabel)
        
        UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .autoreverse], animations: {
            plzSlideUpImageView.frame.origin.y -= 8
        }, completion: nil)
        
        
        
        
        
        
        
        bulletinBoard_ProfilePart_Bottom = UIView()
        bulletinBoard_ProfilePart_Bottom.frame = CGRect(x: 0, y: 0, width: bulletinBoard_ProfilePart.frame.width, height: bulletinBoard_ProfilePart.frame.height)
        bulletinBoard_ProfilePart.addSubview(bulletinBoard_ProfilePart_Bottom)
        
        //點擊照片或是自我介紹，前往PhotoProfileView
        let gotoPhotoProfileViewBtn_Bottom = { () -> UIButton in
            let btn = UIButton()
            btn.frame = CGRect(x: 0, y: 47, width: view.frame.width, height: 120)
            btn.addTarget(self, action: #selector(gotoPhotoProfileViewBtnAct), for: .touchUpInside)
            return btn
        }()
        bulletinBoard_ProfilePart_Bottom.addSubview(gotoPhotoProfileViewBtn_Bottom)
        
        if UserSetting.UID != UID{
            let mailBtn_Bottom = MailButton(personInfo: personInfo)
            mailBtn_Bottom.setImage(UIImage(named: "飛鴿傳書icon"), for: .normal)
            mailBtn_Bottom.frame = CGRect(x: bulletinBoard_ProfilePart_Bottom.frame.width - 50 - 9, y: 45, width: 50, height: 42)
            mailBtn_Bottom.isEnabled = true
            bulletinBoard_ProfilePart_Bottom.addSubview(mailBtn_Bottom)
        }
        
        let storeNameAndDistanceLabel = {() -> UILabel in
            let label = UILabel()
            label.font = UIFont(name: "HelveticaNeue-light", size: 14)
            var distanceDouble = Double(distance)
            if distanceDouble >= 1000{
                distanceDouble = distanceDouble/1000
                distanceDouble = Double(Int(distanceDouble * 10))/10
                label.text = storeName + " " + "\(distanceDouble)" + "km"
            }else{
                label.text =  storeName + " " + "\(Int(distanceDouble))" + "m"
            }
            label.textColor = UIColor.hexStringToUIColor(hex: "414141")
            label.textAlignment = .right
            label.frame = CGRect(x: bulletinBoard_ProfilePart_Bottom.frame.width - label.intrinsicContentSize.width - 6, y: 10, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            
            return label
        }()
        bulletinBoard_ProfilePart_Bottom.addSubview(storeNameAndDistanceLabel)
        
        
        let separator = { () -> UIImageView in
            let imageView = UIImageView()
            imageView.image = UIImage(named: "分隔線擦痕")
            imageView.frame = CGRect(x:40, y:240 - 60, width: bulletinBoard_ProfilePart_Bottom.frame.width - 70, height: 1.3)
            imageView.contentMode = .scaleToFill
            return imageView
        }()
        bulletinBoard_ProfilePart_Bottom.addSubview(separator)
        
        let separator2 = { () -> UIImageView in
            let imageView = UIImageView()
            imageView.image = UIImage(named: "分隔線擦痕")
            imageView.frame = CGRect(x:40, y:43 + 240 - 60, width: UIScreen.main.bounds.size.width - 70, height: 1.3)
            imageView.contentMode = .scaleToFill
            return imageView
        }()
        separator2.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        bulletinBoard_ProfilePart_Bottom.addSubview(separator2)
        
        
        var bookMarks_temp = bookMarks
        bookMarks_temp.remove(at: 0)
        
        if bookMarks_temp.count > 0 {
            for i in 0 ... bookMarks_temp.count - 1{
                let classificationNameLabel = UILabel()
                classificationNameLabel.text = bookMarks_temp[i]
                classificationNameLabel.font = UIFont(name: "HelveticaNeue", size: 15)
                classificationNameLabel.numberOfLines = 0
                classificationNameLabel.textColor = UIColor.hexStringToUIColor(hex: "#414141")
                classificationNameLabel.frame = CGRect(x: (0.5 + CGFloat(i)) * view.frame.width/CGFloat(bookMarks_temp.count) - classificationNameLabel.intrinsicContentSize.width/2,y:22 - classificationNameLabel.intrinsicContentSize.height/2 + 240 - 60,width: classificationNameLabel.intrinsicContentSize.width + 2, height: classificationNameLabel.intrinsicContentSize.height)
                bulletinBoard_ProfilePart_Bottom.addSubview(classificationNameLabel)
                bookMarkClassificationNameLabels_ProfileBoard.append(classificationNameLabel)
                
                let classificationNameButton = UIButton()
                classificationNameButton.isEnabled = true
                classificationNameButton.frame = CGRect(x:CGFloat(i) * view.frame.width/CGFloat(bookMarks_temp.count),y:240 - 60,width: view.frame.width/CGFloat(bookMarks_temp.count),height: 44)
                if bookMarks_temp[i] == bookMarkName_Sell{
                    classificationNameButton.addTarget(self, action: #selector(ProfileBoard_bookMarkAct_OpenStore), for: .touchUpInside)
                }else if bookMarks_temp[i] == bookMarkName_Buy{
                    classificationNameButton.addTarget(self, action: #selector(ProfileBoard_bookMarkAct_Request), for: .touchUpInside)
                }else if bookMarks_temp[i] == bookMarkName_TeamUp{
                    classificationNameButton.addTarget(self, action: #selector(ProfileBoard_bookMarkAct_TeamUp), for: .touchUpInside)
                }
                bulletinBoard_ProfilePart_Bottom.addSubview(classificationNameButton)
                
            }
            
            changeBookMark(text: bookMarks_temp[0],labels: bookMarkClassificationNameLabels_ProfileBoard)
        }
        
        
        
        let bigItemTableViewContainer = UIView()
        bigItemTableViewContainer.frame = CGRect(x: 0, y: 44 + 240 - 60, width: view.frame.width, height: bulletinBoard_ProfilePart_Bottom.frame.height - 44 - 240 + 60)
        
        bigItemDelegate.personDetail = personInfo
        bigItemDelegate.currentItemType = currentItemType
        bigItemDelegate.mapViewDelegate = viewDelegate
        bigItemTableView = UITableView()
        bigItemTableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: bigItemTableViewContainer.frame.height)
        bigItemTableView.delegate = bigItemDelegate
        bigItemTableView.dataSource = bigItemDelegate
        bigItemTableView.showsVerticalScrollIndicator = false
        bigItemTableView.register(BigItemTableViewCell.self, forCellReuseIdentifier: "bigItemTableViewCell")
        bigItemTableView.rowHeight = 110
        bigItemTableView.estimatedRowHeight = 0
        bigItemTableView.backgroundColor = .clear
        bigItemTableView.separatorColor = .clear
        bigItemTableView.separatorInset = .zero
        bigItemTableViewContainer.addSubview(bigItemTableView)
        bulletinBoard_ProfilePart_Bottom.addSubview(bigItemTableViewContainer)
        
        bigItemTableViewRefreshControl = UIRefreshControl()
        bigItemTableView.addSubview(bigItemTableViewRefreshControl)
        bigItemTableViewRefreshControl.addTarget(self, action: #selector(useRefreshControlToSwipeDown), for: .valueChanged)
        bigItemTableViewRefreshControl.tintColor = .clear
        
        bulletinBoard_ProfilePart_Bottom.isHidden = true
        bulletinBoard_ProfilePart.isHidden = true
        
        
        changeBookMark(text: selectedbookMark,labels: bookMarkClassificationNameLabels)
        if selectedbookMark == bookMarkName_Sell{
            bookMarkAct_OpenStore()
        }else if selectedbookMark == bookMarkName_Buy{
            bookMarkAct_Request()
        }else if selectedbookMark == bookMarkName_TeamUp{
            bookMarkAct_TeamUp()
        }else if selectedbookMark == bookMarkName_MakeFriend{
            bookMarkAct_Profile()
            //            if bookMarks_temp.count > 0{
            //                if bookMarks_temp[0] == bookMarkName_Sell{
            //                    currentItemType = .Sell
            //
            //                    photoTableView.reloadData()
            //                    bigItemTableView.reloadData()
            //                }else if bookMarks_temp[0] == bookMarkName_Buy{
            //                    currentItemType = .Buy
            //                    photoTableView.reloadData()
            //                    bigItemTableView.reloadData()
            //                }else if bookMarks_temp[0] == bookMarkName_TeamUp{
            //                    print("bookMarks_temp[0] == bookMarkName_TeamUp")
            //                }
            //            }
        }
        
        
        
    }
    func startRemainingStoreOpenTimer(lebal:UILabel,storeOpenTimeString:String,durationOfAuction:Int){
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYYMMddHHmmss"
        
        storeRemainingTimeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in
            
            if formatter.date(from: storeOpenTimeString) != nil{
                let seconds = Date().seconds(sinceDate: formatter.date(from: storeOpenTimeString)!)
                let remainingHour = (durationOfAuction - seconds!) / (60 * 60)
                let remainingMin = ((durationOfAuction - seconds!) % (60 * 60)) / 60
                let remainingSecond = ((durationOfAuction - seconds!) % (60 * 60)) % 60
                let remainingTime = "刊登剩餘時間  " + "\(remainingHour)" + " : " + "\(remainingMin)" + " : " + "\(remainingSecond)"
                
                if remainingHour >= 0 && remainingMin >= 0 && remainingSecond >= 0{
                    lebal.text = remainingTime
                }else{
                    lebal.text = "即將下架"
                }
            }else{
                lebal.text = ""
            }
            
        })
        
    }
    
    @objc func useRefreshControlToSwipeDown(){
        bigItemTableViewRefreshControl.endRefreshing()
        
        smallItemTableView.reloadData()
        
        let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        animateBulletinBoard(targetPosition: view.frame.height - 274 - bottomPadding) { (_) in
            self.bulletinBoardExpansionState = .PartiallyExpanded
        }
        
        
        switch currentBulletinBoard {
        case .Profile:
            break
        case .Buy:
            fadeInBuySellBoard()
            break
        case .Sell:
            fadeInBuySellBoard()
            break
        case .TeamUp:
            fadeInTeamUpBoard()
            break
        }
        
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            for label in self.bookMarkClassificationNameLabels{
                label.alpha = 1
                self.bulletinBoard_ProfilePart_Bottom.alpha = 0
                self.bulletinBoard_ProfilePart_Middle.alpha = 1
            }
        }, completion: { _ in
            for btn in self.bookMarkClassificationNameBtns{
                btn.isEnabled = true
            }
            self.bulletinBoard_ProfilePart_Bottom.isHidden = true
        })
        
    }
    
    enum BulletinBoardExpansionState {
        case NotExpanded  //0
        case PartiallyExpanded //274
        case FullyExpanded //view.frame.height - 40
    }
    
    
    enum ActionSheetExpansionState{
        case NotExpanded //0
        case Expanded //283
    }
    
    enum CurrentBulletinBoard{
        case Profile
        case Buy
        case Sell
        case TeamUp
    }
    
    fileprivate func configureExclamationBtnPopUp() {
        
        exclamationPopUpBGButton.isHidden = true
        exclamationPopUpBGButton.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        exclamationPopUpBGButton.backgroundColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 0.56)
        view.addSubview(exclamationPopUpBGButton)
        
        exclamationPopUpContainerView.frame = CGRect(x: view.frame.width - 50 - 277.5, y: 35 + 37 + statusHeight, width:277.5, height: 123)
        exclamationPopUpBGButton.addSubview(exclamationPopUpContainerView)
        exclamationPopUpBGButton.addTarget(self, action: #selector(exclamationPopUpBGBtnAct), for: .touchUpInside)
        
        let exclamationPopUpImage = UIImage(named: "驚嘆號彈出方框")
        let exclamationPopUpImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: exclamationPopUpContainerView.frame.width, height: exclamationPopUpContainerView.frame.height))
        exclamationPopUpImageView.image = exclamationPopUpImage
        exclamationPopUpContainerView.addSubview(exclamationPopUpImageView)
        
        showOpenStoreButton.frame = CGRect(x: 6, y: 25, width: 44, height: 44)
        let openStoreImage = UIImage(named: "天秤小icon")
        let openStoreImage_tintedImage = openStoreImage?.withRenderingMode(.alwaysTemplate)
        
        if UserSetting.isMapShowOpenStore{
            showOpenStoreButton.tintColor = UIColor.hexStringToUIColor(hex: "#472411")
        }else{
            showOpenStoreButton.tintColor = smallIconUnactiveColor
        }
        showOpenStoreButton.setImage(openStoreImage_tintedImage, for: .normal)
        showOpenStoreButton.isEnabled = true
        showOpenStoreButton.addTarget(self, action: #selector(showOpenStoreBtnAct), for: .touchUpInside)
        
        exclamationPopUpContainerView.addSubview(showOpenStoreButton)
        
        showRequestButton.frame = CGRect(x: 65, y: 25, width: 44, height: 44)
        let requestImage = UIImage(named: "捲軸小icon")
        let requestImage_tintedImage = requestImage?.withRenderingMode(.alwaysTemplate)
        if UserSetting.isMapShowRequest{
            showRequestButton.tintColor = UIColor.hexStringToUIColor(hex: "#472411")
        }else{
            showRequestButton.tintColor = smallIconUnactiveColor
        }
        
        showRequestButton.setImage(requestImage_tintedImage, for: .normal)
        showRequestButton.isEnabled = true
        showRequestButton.addTarget(self, action: #selector(showRequestBtnAct), for: .touchUpInside)
        exclamationPopUpContainerView.addSubview(showRequestButton)
        
        showTeamUpButton.frame = CGRect(x: 130, y: 25, width: 44, height: 44)
        let teamUpImage = UIImage(named: "旗子小icon")
        let teamUpImage_tintedImage = teamUpImage?.withRenderingMode(.alwaysTemplate)
        if UserSetting.isMapShowTeamUp{
            showTeamUpButton.tintColor = UIColor.hexStringToUIColor(hex: "#472411")
        }else{
            showTeamUpButton.tintColor = smallIconUnactiveColor
        }
        showTeamUpButton.setImage(teamUpImage_tintedImage, for: .normal)
        showTeamUpButton.isEnabled = true
        showTeamUpButton.addTarget(self, action: #selector(showTeamUpBtnAct), for: .touchUpInside)
        //        exclamationPopUpContainerView.addSubview(showTeamUpButton)
        
        showCoffeeShopButton.frame = CGRect(x: 188, y: 25, width: 44, height: 44)
        let coffeeShopImage = UIImage(named: "咖啡小icon")
        let coffeeShopImage_tintedImage = coffeeShopImage?.withRenderingMode(.alwaysTemplate)
        if UserSetting.isMapShowCoffeeShop{
            showCoffeeShopButton.tintColor = UIColor.hexStringToUIColor(hex: "#472411")
        }else{
            showCoffeeShopButton.tintColor = smallIconUnactiveColor
        }
        showCoffeeShopButton.setImage(coffeeShopImage_tintedImage, for: .normal)
        showCoffeeShopButton.isEnabled = true
        showCoffeeShopButton.addTarget(self, action: #selector(showCoffeeShopBtnAct), for: .touchUpInside)
        exclamationPopUpContainerView.addSubview(showCoffeeShopButton)
        
        showBoyButton.frame = CGRect(x: 6, y: 25 + 44 + 6, width: 44, height: 44)
        let showBoyImage = UIImage(named: "boyIcon")
        let showBoyImage_tintImage = showBoyImage?.withRenderingMode(.alwaysTemplate)
        if UserSetting.isMapShowMakeFriend_Boy{
            showBoyButton.tintColor = UIColor.hexStringToUIColor(hex: "#472411")
        }else{
            showBoyButton.tintColor = smallIconUnactiveColor
        }
        showBoyButton.setImage(showBoyImage_tintImage, for: .normal)
        showBoyButton.isEnabled = true
        showBoyButton.addTarget(self, action: #selector(showBoyBtnAct), for: .touchUpInside)
        exclamationPopUpContainerView.addSubview(showBoyButton)
        
        showGirlButton.frame = CGRect(x: 65, y: 25 + 44 + 6, width: 44, height: 44)
        let showGirlImage = UIImage(named: "girlIcon")
        let showGirlImage_tintImage = showGirlImage?.withRenderingMode(.alwaysTemplate)
        if UserSetting.isMapShowMakeFriend_Girl{
            showGirlButton.tintColor = UIColor.hexStringToUIColor(hex: "#472411")
        }else{
            showGirlButton.tintColor = smallIconUnactiveColor
        }
        showGirlButton.setImage(showGirlImage_tintImage, for: .normal)
        showGirlButton.isEnabled = true
        showGirlButton.addTarget(self, action: #selector(showGirlBtnAct), for: .touchUpInside)
        exclamationPopUpContainerView.addSubview(showGirlButton)
        
    }
    
    fileprivate func configMapButtons() {
        
        let window = UIApplication.shared.keyWindow
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0
        
        let circleButton_exclamation = UIButton(frame:CGRect(x: view.frame.width - 11 - 37, y: statusHeight + 11 + 37, width: 37, height: 37))
        let exclamationImage = UIImage(named: "驚嘆號button")
        circleButton_exclamation.setImage(exclamationImage, for: [])
        circleButton_exclamation.isEnabled = true
        view.addSubview(circleButton_exclamation)
        circleButton_exclamation.addTarget(self, action: #selector(exclamationBtnAct), for: .touchUpInside)
        
        let circleButton_add: UIButton = UIButton()
        circleButton_add.setImage(UIImage(named: "icons24PlusFilledWt24"), for: .normal)
        circleButton_add.backgroundColor = UIColor(red: 0, green: 202 / 255, blue: 199 / 255, alpha: 1)
        circleButton_add.addTarget(self, action: #selector(addBtnAct), for: .touchUpInside)
        circleButton_add.layer.cornerRadius = 26
        view.addSubview(circleButton_add)
        circleButton_add.snp.makeConstraints { make in
            make.height.width.equalTo(52)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.snp.bottomMargin).offset(-36)
        }
        
        let acccountButton = UIButton()
        acccountButton.setImage(UIImage(named: "icons24AccountFilledGrey24"), for: .normal)
        acccountButton.backgroundColor = UIColor(red: 250 / 255, green: 250 / 255, blue: 250 / 255, alpha: 0.75)
//        acccountButton.addTarget(self, action: #selector(addBtnAct), for: .touchUpInside)
        acccountButton.layer.cornerRadius = 20
        view.addSubview(acccountButton)
        acccountButton.snp.makeConstraints { make in
            make.height.width.equalTo(40)
            make.centerY.equalTo(circleButton_add)
            make.right.equalTo(circleButton_add.snp.left).offset(-48)
        }
        
        let messageButton = UIButton()
        messageButton.setImage(UIImage(named: "icons24MessageFilledGrey24"), for: .normal)
        messageButton.backgroundColor = UIColor(red: 250 / 255, green: 250 / 255, blue: 250 / 255, alpha: 0.75)
        //        messageButton.addTarget(self, action: #selector(addBtnAct), for: .touchUpInside)
        messageButton.layer.cornerRadius = 20
        view.addSubview(messageButton)
        messageButton.snp.makeConstraints { make in
            make.height.width.equalTo(40)
            make.centerY.equalTo(circleButton_add)
            make.left.equalTo(circleButton_add.snp.right).offset(48)
        }
        
        
        let circleButton_reposition = UIButton(frame:CGRect(x: view.frame.width - 53 - 14, y: view.frame.height - 53 - 63 - bottomPadding, width: 53, height: 53))
        let repositionImage = UIImage(named: "再定位button")
        circleButton_reposition.setImage(repositionImage, for: [])
        circleButton_reposition.isEnabled = true
        view.addSubview(circleButton_reposition)
        circleButton_reposition.addTarget(self, action: #selector(repositionBtnAct), for: .touchUpInside)
        
    }
    
    
    
    fileprivate func configureMapView() {
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.userTrackingMode = .follow
        mapView.showsPointsOfInterest = false
        mapView.tintColor = UIColor.hexStringToUIColor(hex: "F5A623") //這裡決定的是user那個點的顏色
        
        
        view.addSubview(mapView)
        mapView.addConstraintsToFillView(view: view)
    }
    
    @objc private func repositionBtnAct(){
        Analytics.logEvent("地圖_再定位按鈕", parameters:nil)
        enableLocationServices()
        centerMapOnUserLocation(shouldLoadAnnotations: false)
    }
    
    @objc private func exclamationBtnAct(){
        Analytics.logEvent("地圖_驚嘆號按鈕", parameters:nil)
        exclamationPopUpBGButton.isHidden = false
    }
    
    @objc private func addBtnAct(){
        Analytics.logEvent("地圖_加號按鈕", parameters:nil)
        enableLocationServices()
        mapView.selectAnnotation(mapView.userLocation, animated: true)
    }
    
    @objc private func iWantActionSheetBGBtnAct(){
        if storeNameTextField.isEditing{
            storeNameTextField.endEditing(true)
        }else{
            mapView.deselectAnnotation(mapView.userLocation, animated: true)
        }
        
    }
    
    @objc private func showOpenStoreBtnAct(){
        if UserSetting.isMapShowOpenStore{
            UserSetting.isMapShowOpenStore = false
            showOpenStoreButton.tintColor = smallIconUnactiveColor
        }else{
            UserSetting.isMapShowOpenStore = true
            showOpenStoreButton.tintColor = UIColor.hexStringToUIColor(hex: "#472411")
        }
        mapView.removeAnnotations(presonAnnotationGetter.openShopAnnotations)
        mapView.addAnnotations(presonAnnotationGetter.decideCanShowOrNotAndWhichIcon(presonAnnotationGetter.openShopAnnotations))
    }
    @objc private func showRequestBtnAct(){
        if UserSetting.isMapShowRequest{
            UserSetting.isMapShowRequest = false
            showRequestButton.tintColor = smallIconUnactiveColor
        }else{
            UserSetting.isMapShowRequest = true
            showRequestButton.tintColor = UIColor.hexStringToUIColor(hex: "#472411")
        }
        mapView.removeAnnotations(presonAnnotationGetter.requestAnnotations)
        mapView.addAnnotations(presonAnnotationGetter.decideCanShowOrNotAndWhichIcon(presonAnnotationGetter.requestAnnotations))
    }
    @objc private func showTeamUpBtnAct(){
        if UserSetting.isMapShowTeamUp{
            UserSetting.isMapShowTeamUp = false
            showTeamUpButton.tintColor = smallIconUnactiveColor
        }else{
            UserSetting.isMapShowTeamUp = true
            showTeamUpButton.tintColor = UIColor.hexStringToUIColor(hex: "#472411")
        }
        mapView.removeAnnotations(presonAnnotationGetter.teamUpAnnotations)
        mapView.addAnnotations(presonAnnotationGetter.decideCanShowOrNotAndWhichIcon(presonAnnotationGetter.teamUpAnnotations))
    }
    @objc private func showCoffeeShopBtnAct(){
        if UserSetting.isMapShowCoffeeShop{
            UserSetting.isMapShowCoffeeShop = false
            showCoffeeShopButton.tintColor = smallIconUnactiveColor
            mapView.removeAnnotations(coffeeAnnotationGetter.coffeeAnnotations)
        }else{
            UserSetting.isMapShowCoffeeShop = true
            showCoffeeShopButton.tintColor = UIColor.hexStringToUIColor(hex: "#472411")
            mapView.addAnnotations(coffeeAnnotationGetter.coffeeAnnotations)
        }
    }
    @objc private func showBoyBtnAct(){
        if UserSetting.isMapShowMakeFriend_Boy{
            UserSetting.isMapShowMakeFriend_Boy = false
            showBoyButton.tintColor = smallIconUnactiveColor
        }else{
            UserSetting.isMapShowMakeFriend_Boy = true
            showBoyButton.tintColor = UIColor.hexStringToUIColor(hex: "#472411")
        }
        mapView.removeAnnotations(presonAnnotationGetter.boySayHiAnnotations)
        mapView.addAnnotations(presonAnnotationGetter.decideCanShowOrNotAndWhichIcon(presonAnnotationGetter.boySayHiAnnotations))
        
    }
    @objc private func showGirlBtnAct(){
        if UserSetting.isMapShowMakeFriend_Girl{
            UserSetting.isMapShowMakeFriend_Girl = false
            showGirlButton.tintColor = smallIconUnactiveColor
        }else{
            UserSetting.isMapShowMakeFriend_Girl = true
            showGirlButton.tintColor = UIColor.hexStringToUIColor(hex: "#472411")
        }
        mapView.removeAnnotations(presonAnnotationGetter.girlSayHiAnnotations)
        mapView.addAnnotations(presonAnnotationGetter.decideCanShowOrNotAndWhichIcon(presonAnnotationGetter.girlSayHiAnnotations))
    }
    
    @objc private func exclamationPopUpBGBtnAct(){
        exclamationPopUpBGButton.isHidden = true
    }
    
    @objc private func bookMarkAct_OpenStore(){
        refreshTableViewsContent(.Sell)
        changeBookMark(text:bookMarkName_Sell,labels: bookMarkClassificationNameLabels)
        changeBookMark(text:bookMarkName_Sell,labels: bookMarkClassificationNameLabels_ProfileBoard)
        fadeInBuySellBoard()
    }
    
    fileprivate func fadeInBuySellBoard() {
        if (bulletinBoard_BuySellPart.isHidden == true){
            bulletinBoard_BuySellPart.isHidden = false
            bulletinBoard_BuySellPart.alpha = 0
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.bulletinBoard_BuySellPart.alpha = 1
                self.bulletinBoard_ProfilePart.alpha = 0
                self.bulletinBoard_TeamUpPart.alpha = 0
                self.bulletinBoard_CoffeeShop.alpha = 0
            }, completion:  { _ in
                self.bulletinBoard_ProfilePart.isHidden = true
                self.bulletinBoard_TeamUpPart.isHidden = true
                self.bulletinBoard_CoffeeShop.isHidden = true
                self.bulletinBoard_ProfilePart.alpha = 1
                self.bulletinBoard_TeamUpPart.alpha = 1
                self.bulletinBoard_CoffeeShop.alpha = 1
            })
        }
    }
    
    @objc private func bookMarkAct_Request(){
        refreshTableViewsContent(.Buy)
        changeBookMark(text:bookMarkName_Buy,labels: bookMarkClassificationNameLabels)
        changeBookMark(text:bookMarkName_Buy,labels: bookMarkClassificationNameLabels_ProfileBoard)
        fadeInBuySellBoard()
    }
    
    fileprivate func fadeInTeamUpBoard() {
        if bulletinBoard_TeamUpPart.isHidden == true{
            bulletinBoard_TeamUpPart.isHidden = false
            bulletinBoard_TeamUpPart.alpha = 0
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.bulletinBoard_TeamUpPart.alpha = 1
                self.bulletinBoard_ProfilePart.alpha = 0
                self.bulletinBoard_BuySellPart.alpha = 0
                self.bulletinBoard_CoffeeShop.alpha = 0
            }, completion:  { _ in
                self.bulletinBoard_ProfilePart.isHidden = true
                self.bulletinBoard_BuySellPart.isHidden = true
                self.bulletinBoard_CoffeeShop.isHidden = true
                self.bulletinBoard_ProfilePart.alpha = 1
                self.bulletinBoard_BuySellPart.alpha = 1
                self.bulletinBoard_CoffeeShop.alpha = 1
            })
        }
    }
    
    @objc private func bookMarkAct_TeamUp(){
        changeBookMark(text:bookMarkName_TeamUp,labels: bookMarkClassificationNameLabels)
        changeBookMark(text:bookMarkName_TeamUp,labels: bookMarkClassificationNameLabels_ProfileBoard)
        fadeInTeamUpBoard()
    }
    fileprivate func fadeInProfileBoard() {
        if bulletinBoard_ProfilePart.isHidden == true{
            bulletinBoard_ProfilePart.isHidden = false
            bulletinBoard_ProfilePart.alpha = 0
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.bulletinBoard_ProfilePart.alpha = 1
                self.bulletinBoard_TeamUpPart.alpha = 0
                self.bulletinBoard_BuySellPart.alpha = 0
                self.bulletinBoard_CoffeeShop.alpha = 0
            }, completion:  { _ in
                self.bulletinBoard_TeamUpPart.isHidden = true
                self.bulletinBoard_BuySellPart.isHidden = true
                self.bulletinBoard_CoffeeShop.isHidden = true
                self.bulletinBoard_TeamUpPart.alpha = 1
                self.bulletinBoard_BuySellPart.alpha = 1
                self.bulletinBoard_CoffeeShop.alpha = 1
            })
        }
    }
    
    @objc private func bookMarkAct_Profile(){
        changeBookMark(text:bookMarkName_MakeFriend,labels: bookMarkClassificationNameLabels)
        fadeInProfileBoard()
    }
    
    @objc private func gotoPhotoProfileViewBtnAct(){
        viewDelegate?.gotoProfileViewController_mapView(personDetail: personInfo)
    }
    
    fileprivate func refreshTableViewsContent(_ currentBoard : CurrentBulletinBoard) {
        
        switch currentBoard {
        case .Profile:
            
            break
        case .Buy:
            currentItemType = .Buy
            smallItemDelegate.currentItemType = currentItemType
            bigItemDelegate.currentItemType = currentItemType
            photoDelegate.currentItemType = currentItemType
            photoTableView.reloadData()
            smallItemTableView.reloadData()
            bigItemTableView.reloadData()
            break
        case .Sell:
            currentItemType = .Sell
            smallItemDelegate.currentItemType = currentItemType
            bigItemDelegate.currentItemType = currentItemType
            photoDelegate.currentItemType = currentItemType
            photoTableView.reloadData()
            smallItemTableView.reloadData()
            bigItemTableView.reloadData()
            break
        case .TeamUp:
            break
        }
        
    }
    
    @objc private func ProfileBoard_bookMarkAct_OpenStore(){
        
        refreshTableViewsContent(.Sell)
        changeBookMark(text:bookMarkName_Sell,labels: bookMarkClassificationNameLabels_ProfileBoard)
        changeBookMark(text:bookMarkName_Sell,labels: bookMarkClassificationNameLabels)
    }
    @objc private func ProfileBoard_bookMarkAct_Request(){
        
        refreshTableViewsContent(.Buy)
        changeBookMark(text:bookMarkName_Buy,labels: bookMarkClassificationNameLabels_ProfileBoard)
        changeBookMark(text:bookMarkName_Buy,labels: bookMarkClassificationNameLabels)
        
    }
    @objc private func ProfileBoard_bookMarkAct_TeamUp(){
        print("ProfileBoard_bookMarkAct_TeamUp")
        changeBookMark(text:bookMarkName_TeamUp,labels: bookMarkClassificationNameLabels_ProfileBoard)
        changeBookMark(text:bookMarkName_TeamUp,labels: bookMarkClassificationNameLabels)
        
    }
    
    
    
    @objc private func fbBtnAct(){
        Analytics.logEvent("地圖_咖啡_前往FB", parameters:nil)
        UIApplication.shared.open(URL(string:coffeeShop_url)!, completionHandler: nil)
    }
    
    @objc private func iWantConcealBtnAct(){
        Analytics.logEvent("地圖_加號按鈕_取消", parameters:nil)
        mapView.deselectAnnotation(mapView.userLocation, animated: true)
        view.endEditing(true)
    }
    
    @objc private func iWantActionSheetContainerAct(){
        mapView.deselectAnnotation(mapView.userLocation, animated: true)
        actionSheetKit.allBtnSlideOut()
        view.endEditing(true)
    }
    
    @objc private func iWantSayHiBtnAct(){
        
        Analytics.logEvent("地圖_加號按鈕_SayHi", parameters:nil)
        
        let loadingView = UIView(frame: CGRect(x: view.frame.width/2 - 40, y: view.frame.height/2 - 40, width: 80, height: 80))
        view.addSubview(loadingView)
        loadingView.setupToLoadingView()
        
        iWantSayHiBtn.isEnabled = false
        
        if UserSetting.storeName == ""{
            UserSetting.storeName = "Hi!"
        }
        
        //上傳TradeAnnotation
        let currentTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMddHHmmss"
        let currentTimeString = dateFormatter.string(from: currentTime)
        if UserSetting.storeName == ""{
            UserSetting.storeName = bookMarkName_MakeFriend
        }
        UserSetting.isWantMakeFriend = true
        let myAnnotation = TradeAnnotationData(openTime: currentTimeString, title: UserSetting.storeName, gender: UserSetting.userGender, isOpenStore: UserSetting.isWantSellSomething, isRequest: UserSetting.isWantBuySomething, latitude: UserSetting.userLatitude, longitude: UserSetting.userLongitude)
        
        let ref = Database.database().reference()
        let pradeAnnotationWithIDRef = ref.child("PersonAnnotation/" +  UserSetting.UID)
        pradeAnnotationWithIDRef.setValue(myAnnotation.toAnyObject()){ (error, ref) -> Void in
            
            self.mapView.deselectAnnotation(self.mapView.userLocation, animated: true)
            loadingView.removeFromSuperview()
            self.iWantSayHiBtn.isEnabled = true
            self.presonAnnotationGetter.reFreshUserAnnotation()
            
            if error != nil{
                print(error ?? "上傳TradeAnnotation失敗")
            }
            
        }
    }
    
    @objc private func iWantOpenStoreBtnAct(){
        
        Analytics.logEvent("地圖_加號按鈕_擺攤", parameters:nil)
        
        viewDelegate?.gotoWantSellViewController_mapView(defaultItem:nil)
        mapView.deselectAnnotation(mapView.userLocation, animated: true)
    }
    
    @objc private func iWantRequestBtnAct(){
        
        Analytics.logEvent("地圖_加號按鈕_發布任務", parameters:nil)
        
        viewDelegate?.gotoWantBuyViewController_mapView(defaultItem:nil)
        mapView.deselectAnnotation(mapView.userLocation, animated: true)
    }
    
    @objc private func iWantTeamUpBtnAct(){
        print("iWantTeamUpBtnAct")
    }
    
    
    
    
    fileprivate func changeBookMark(text:String,labels:[UILabel]) {
        for label in labels{
            if label.text == text{
                label.textColor = UIColor.hexStringToUIColor(hex: "#751010")
                label.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
            }else{
                label.textColor = UIColor.hexStringToUIColor(hex: "#414141")
                label.font = UIFont(name: "HelveticaNeue", size: 15)
            }
        }
        
        //記錄當前哪頁
        if text == bookMarkName_Sell{
            currentBulletinBoard = .Sell
        }else if text == bookMarkName_Buy{
            currentBulletinBoard = .Buy
        }else if text == bookMarkName_TeamUp{
            currentBulletinBoard = .TeamUp
        }else if text == bookMarkName_MakeFriend{
            currentBulletinBoard = .Profile
        }
    }
    
    
    
}


// MARK: - MapKit Helper Func

extension MapViewController{
    
    func centerMapOnUserLocation(shouldLoadAnnotations: Bool) {
        guard let coordinates = locationManager.location?.coordinate else { return }
        
        let zoomWidth = mapView.visibleMapRect.size.width
        var meter : Double = 500
        if zoomWidth < 3694{
            meter = zoomWidth * 500/3694
        }
        let coordinateRegion = MKCoordinateRegion(center: coordinates, latitudinalMeters: meter, longitudinalMeters: meter)
        mapView.setRegion(coordinateRegion, animated: true)
        
        //
        //        if shouldLoadAnnotations {
        //            loadAnnotations(withSearchQuery: "Coffee Shops")
        //        }
    }
    
    
    
}




// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        //        if let route = self.route {
        //            let polyline = route.polyline
        //            let lineRenderer = MKPolylineRenderer(overlay: polyline)
        //            lineRenderer.strokeColor = .mainBlue()
        //            lineRenderer.lineWidth = 3
        //            return lineRenderer
        //        }
        //
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView){
        if view.annotation is CustomPointAnnotation{
            view.subviews[0].alpha = 0
        }
        
        ////如果有imageView（小頭像）存在，就用動畫將它下移還原位置
        if let view = view.viewWithTag(1){
            let imageView = (view as! UIImageView)
            UIView.animate(withDuration: 0.3, animations: {
                imageView.frame = CGRect(x: imageView.frame.origin.x, y: imageView.frame.origin.y + 15, width: imageView.frame.width, height: imageView.frame.height)
            })
        }
        
        cleanBulletinBoard()
        
        self.bulletinBoardExpansionState = .NotExpanded
        animateBulletinBoard(targetPosition: self.view.frame.height) { (_) in }
        
        self.actionSheetExpansionState = .NotExpanded
        animateActionSheet(targetAlpha:0,targetPosition: self.view.frame.height){ (_) in }
        
        storeRemainingTimeTimer.invalidate()
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let zoomWidth = mapView.visibleMapRect.size.width
        var meter : Double = 500
        if zoomWidth < 3694{
            meter = zoomWidth * 500/3694
        }
        let coordinateRegion = MKCoordinateRegion(center: view.annotation!.coordinate, latitudinalMeters: meter, longitudinalMeters: meter)
        mapView.setRegion(coordinateRegion, animated: true)
        
        
        
        if view.annotation is MKUserLocation{
            if actionSheetExpansionState == .NotExpanded {
                actionSheetKit.allBtnSlideIn()
                animateActionSheet(targetAlpha: 1,targetPosition: 0) { (_) in
                    self.actionSheetExpansionState = .Expanded
                }
            }
            UserSetting.userLatitude = String(format: "%f", (mapView.userLocation.coordinate.latitude))
            UserSetting.userLongitude = String(format: "%f", (mapView.userLocation.coordinate.longitude))
            return
        }
        
        if bulletinBoardExpansionState == .NotExpanded {
            let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            animateBulletinBoard(targetPosition: self.view.frame.height - 274 - bottomPadding) { (_) in
                self.bulletinBoardExpansionState = .PartiallyExpanded
            }
        }
        
        ////如果有imageView（小頭像）存在，就用動畫將它上移，才不會擋到距離標籤
        if let view = view.viewWithTag(1){
            let imageView = (view as! UIImageView)
            UIView.animate(withDuration: 0.3, animations: {
                imageView.frame = CGRect(x: imageView.frame.origin.x, y: imageView.frame.origin.y - 15, width: imageView.frame.width, height: imageView.frame.height)
            })
        }
        
        
        ////設置距離label
        let userloc = CLLocation(latitude: mapView.userLocation.coordinate.latitude, longitude: mapView.userLocation.coordinate.longitude)
        let loc = CLLocation(latitude: view.annotation!.coordinate.latitude, longitude: view.annotation!.coordinate.longitude)
        var distance = userloc.distance(from: loc)
        
        let distanceLabel =  (view.subviews[0] as! UILabel)
        distanceLabel.font = UIFont(name: "HelveticaNeue", size: 12)
        
        if Int(distance) >= 1000{
            distance = distance/1000
            distance = Double(Int(distance * 10))/10
            distanceLabel.text = "\(distance)" + "km"
        }else{
            distanceLabel.text = "\(Int(distance))" + "m"
        }
        distanceLabel.frame = CGRect(x: view.frame.width/2 - distanceLabel.intrinsicContentSize.width/2, y:  view.frame.height - distanceLabel.intrinsicContentSize.height, width: distanceLabel.intrinsicContentSize.width, height: distanceLabel.intrinsicContentSize.height)
        
        view.subviews[0].alpha = 1
        
        if view.annotation is CoffeeAnnotation{
            
            Analytics.logEvent("地圖_點擊地標_咖啡", parameters:nil)
            setBulletinBoard_coffeeData(coffeeAnnotation: view.annotation as! CoffeeAnnotation)
            return
        }
        if view.annotation is TradeAnnotation {
            
            Analytics.logEvent("地圖_點擊地標_人物", parameters:nil)
            
            var bookMarks : [String] = []
            bookMarks.append(bookMarkName_MakeFriend)
            if (view.annotation as! TradeAnnotation).isOpenStore{
                bookMarks.append(bookMarkName_Sell)
            }
            if (view.annotation as! TradeAnnotation).isRequest{
                bookMarks.append(bookMarkName_Buy)
            }
           
            
            var selectedBookMark = ""
            
            switch  (view.annotation as! TradeAnnotation).markTypeToShow {
            
            case .makeFriend:
                selectedBookMark = bookMarkName_MakeFriend
            case .openStore:
                selectedBookMark = bookMarkName_Sell
            case .request:
                selectedBookMark = bookMarkName_Buy
            case .teamUp:
                selectedBookMark = bookMarkName_TeamUp
            case .none:
                selectedBookMark = bookMarkName_MakeFriend
            }
            
            //get personDetail
            let ref =  Database.database().reference(withPath: "PersonDetail")
            let loadingView = UIView(frame: CGRect(x: view.frame.width/2 - 40, y: view.frame.height/2 - 40, width: 80, height: 80))
            loadingView.setupToLoadingView()
            view.addSubview(loadingView)
            ref.child((view.annotation as! TradeAnnotation).UID).observeSingleEvent(of: .value, with: { (snapshot) in
                loadingView.removeFromSuperview()
                self.setBulletinBoard(bookMarks: bookMarks,selectedbookMark:selectedBookMark,snapshot: snapshot,UID: (view.annotation as! TradeAnnotation).UID,distance:Int(distance),storeName: (view.annotation?.title!)!,openTimeString: (view.annotation as! TradeAnnotation).openTime)
            }) { (error) in
                loadingView.removeFromSuperview()
                print(error.localizedDescription)
            }
            
            return
        }
        
    }
    
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // 創建一個重複使用的 AnnotationView
        var mkMarker = mapView.dequeueReusableAnnotationView(withIdentifier: "Markers") as? MKMarkerAnnotationView
        
        
        if mkMarker == nil {
            mkMarker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Markers")
        }
        
        
        let markColor = UIColor(red: 34/255, green: 113/255, blue: 234/255, alpha: 1)
        
        if annotation is CoffeeAnnotation{
            
            mkMarker?.tintColor = .clear
            
            let userloc = CLLocation(latitude: mapView.userLocation.coordinate.latitude, longitude: mapView.userLocation.coordinate.longitude)
            let loc = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            var distance = userloc.distance(from: loc)
            
            let distanceLabel = UILabel()
            distanceLabel.font = UIFont(name: "HelveticaNeue", size: 12)
            
            if Int(distance) >= 1000{
                distance = distance/1000
                distance = Double(Int(distance * 10))/10
                distanceLabel.text = "\(distance)" + "km"
            }else{
                distanceLabel.text = "\(Int(distance))" + "m"
            }
            distanceLabel.frame = CGRect(x: mkMarker!.frame.width/2 - distanceLabel.intrinsicContentSize.width/2, y:  mkMarker!.frame.height - distanceLabel.intrinsicContentSize.height, width: distanceLabel.intrinsicContentSize.width, height: distanceLabel.intrinsicContentSize.height)
            distanceLabel.alpha = 0
            mkMarker?.addSubview(distanceLabel)
            
            
            mkMarker?.glyphTintColor = markColor
            mkMarker?.glyphImage = UIImage(named: "咖啡小icon_紫")
        }
        
        if annotation is TradeAnnotation{
            var decideWhichIcon = false
            mkMarker?.titleVisibility = .adaptive
            mkMarker?.displayPriority = .required
            mkMarker?.tintColor = .clear
            
            //加上距離標籤
            let userloc = CLLocation(latitude: mapView.userLocation.coordinate.latitude, longitude: mapView.userLocation.coordinate.longitude)
            let loc = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            var distance = userloc.distance(from: loc)
            
            let distanceLabel = UILabel()
            distanceLabel.font = UIFont(name: "HelveticaNeue", size: 12)
            
            if Int(distance) >= 1000{
                distance = distance/1000
                distance = Double(Int(distance * 10))/10
                distanceLabel.text = "\(distance)" + "km"
            }else{
                distanceLabel.text = "\(Int(distance))" + "m"
            }
            distanceLabel.frame = CGRect(x: mkMarker!.frame.width/2 - distanceLabel.intrinsicContentSize.width/2, y:  mkMarker!.frame.height - distanceLabel.intrinsicContentSize.height, width: distanceLabel.intrinsicContentSize.width, height: distanceLabel.intrinsicContentSize.height)
            distanceLabel.alpha = 0
            mkMarker?.addSubview(distanceLabel)
            
            mkMarker?.glyphTintColor = markColor
            mkMarker?.titleVisibility = .adaptive
            mkMarker?.displayPriority = .required
            mkMarker?.viewWithTag(1)?.removeFromSuperview() //如果有加imageView，就刪除
            switch (annotation as! TradeAnnotation).markTypeToShow {
            case .openStore:
                mkMarker?.glyphImage = UIImage(named: "天秤小icon_紫")
                break
            case .request:
                mkMarker?.glyphImage = UIImage(named: "捲軸小icon_紫")
                break
            case .teamUp:
                mkMarker?.glyphImage = UIImage(named: "旗子小icon_紫")
                break
            case .makeFriend:
                if let headShot = (annotation as! TradeAnnotation).smallHeadShot{
                    mkMarker?.glyphTintColor = .clear
                    let imageView = UIImageView(frame: CGRect(x: 2, y: 0, width: 25, height: 25))
                    imageView.tag = 1
                    imageView.image = headShot
                    imageView.contentMode = .scaleAspectFill
                    imageView.layer.cornerRadius = 12
                    imageView.clipsToBounds = true
                    mkMarker?.addSubview(imageView)
                }else{
                    if (annotation as! TradeAnnotation).gender == .Girl{
                        mkMarker?.glyphImage = UIImage(named: "girlIcon")
                    }else{
                        mkMarker?.glyphImage = UIImage(named: "boyIcon")
                    }
                }
                break
            case .none:
                let imageView = UIImageView(frame: CGRect(x: 2, y: 0, width: 25, height: 25))
                mkMarker?.markerTintColor = .clear
                mkMarker?.tintColor = .clear
                mkMarker?.glyphTintColor = .clear
                if let headShot = (annotation as! TradeAnnotation).smallHeadShot{
                    let imageView = UIImageView(frame: CGRect(x: 2, y: 0, width: 25, height: 25))
                    imageView.tag = 1
                    imageView.contentMode = .scaleAspectFill
                    imageView.image = headShot
                    imageView.layer.cornerRadius = 12
                    imageView.clipsToBounds = true
                    mkMarker?.addSubview(imageView)
                }else{
                    if (annotation as! TradeAnnotation).gender == .Girl{
                        mkMarker?.glyphImage = UIImage(named: "girlIcon")
                    }else{
                        mkMarker?.glyphImage = UIImage(named: "boyIcon")
                    }
                }
            }
        }
        
        mkMarker?.markerTintColor = .clear
        
        // 判斷標記點是否與使用者相同，若為 true 就回傳 nil
        if annotation is MKUserLocation {
            (annotation as! MKUserLocation).title = "我想在這⋯⋯"
            //            var mkPin = mapView.dequeueReusableAnnotationView(withIdentifier: "userPin") as? MKPinAnnotationView
            //
            //            if mkPin == nil{
            //                mkPin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "userPin")
            //                mkPin!.canShowCallout = true
            //                mkPin!.image = UIImage(named: "魔法羽毛(紫)")
            //            }
            return nil
        }else{
            return mkMarker
        }
        
        
    }
    
    //    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
    //        if let annotation = views.first(where: { $0.reuseIdentifier == "Studio" })?.annotation {
    //            mapView.selectAnnotation(annotation, animated: true)
    //        }
    //    }
    
    
    
    
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate{
    
    
    func enableLocationServices(){
        
        switch CLLocationManager.authorizationStatus() {
        
        case .notDetermined:
            print("MapViewController:Location auth status is NOT DETERMINED")
            
            DispatchQueue.main.async {
                let controller = UIStoryboard(name: "CheckLocationAccessViewController", bundle: nil).instantiateViewController(withIdentifier: "CheckLocationAccessViewController") as! CheckLocationAccessViewController
                controller.modalPresentationStyle = .fullScreen
                controller.mapViewController = self
                self.present(controller, animated: true, completion: nil)
            }
            
        case .restricted:
            print("MapViewController:Location auth status is RESTRICTED")
        case .denied:
            print("MapViewController:Location auth status is DENIED")
            DispatchQueue.main.async {
                if let bundleID = Bundle.main.bundleIdentifier,let url = URL(string:UIApplication.openSettingsURLString + bundleID) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        case .authorizedAlways:
            print("MapViewController:Location auth status is AUTHORIZED ALWAYS")
        case .authorizedWhenInUse:
            print("MapViewController:Location auth status is AUTHORIZED WHEN IN USE")
        }
        
    }
}

// MARK: - WordLimitForTypeDelegate 自製

extension MapViewController : WordLimitForTypeDelegate{
    func whenEndEditDoSomeThing() {
        Analytics.logEvent("地圖_編輯顯示名稱", parameters:nil)
        if storeNameTextField.text != ""{
            UserSetting.storeName = storeNameTextField.text!
        }else{
            UserSetting.storeName = "Hi!"
        }
        let ref = Database.database().reference().child("PersonAnnotation/" + UserSetting.UID + "/title")
        presonAnnotationGetter.userAnnotation?.title = UserSetting.storeName
        ref.setValue(UserSetting.storeName)
        
    }
    
    
    func whenEditDoSomeThing(){
        
    }
    
}

