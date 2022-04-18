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
import MessageUI

protocol MapViewControllerViewDelegate: class {
    func gotoItemViewController_mapView(item:Item,personDetail:PersonDetailInfo)
    func gotoProfileViewController_mapView(personDetail:PersonDetailInfo)
    func gotoWantSellViewController_mapView(defaultItem:Item?)
    func gotoWantBuyViewController_mapView(defaultItem:Item?)
    func gotoHoldSharedSeatController_mapView()
    func gotoScoreCoffeeController_mapView(annotation:CoffeeAnnotation)
    func gotoRegistrationList(sharedSeatAnnotation:SharedSeatAnnotation)
    
    func showListLocationViewController(sharedSeatAnnotations:[SharedSeatAnnotation])
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
    let showSharedSeat2Button = UIButton()
    let showSharedSeat4Button = UIButton()
    let bulletinBoardContainer = UIView() //for 背景
    let bulletinBoardTempContainer = UIView() //for 可替換的內部東西
    let bulletinBoard_BuySellPart = UIView() //bulletinBoardTempContainer的子view
    let bulletinBoard_ProfilePart = UIView() //bulletinBoardTempContainer的子view
    var bulletinBoard_ProfilePart_plzSlideUp = UIView() //bulletinBoard_ProfilePart的子view
    var bulletinBoard_ProfilePart_Bottom = UIView() //bulletinBoard_ProfilePart的子view
    let bulletinBoard_TeamUpPart = UIView() //bulletinBoardTempContainer的子view
    let bulletinBoard_CoffeeShop = UIView() //bulletinBoardTempContainer的子view
    let bulletinBoard_SharedSeat = UIView() //bulletinBoardTempContainer的子view
    let iWantActionSheetContainer = UIButton() //我想⋯⋯開店、徵求、揪團btn的容器
    
    
    let smallIconActiveColor = UIColor.primary()
    let smallIconUnactiveColor = UIColor.primary().withAlphaComponent(0.2)
    var bulletinBoardExpansionState: BulletinBoardExpansionState = .NotExpanded
    var actionSheetExpansionState: ActionSheetExpansionState = .NotExpanded
    
    var coffeeAnnotationGetter : CoffeeAnnotationGetter!
    var presonAnnotationGetter : PresonAnnotationGetter!
    var sharedSeatAnnotationGetter : SharedSeatAnnotationGetter!
    
    var coffeeShop_url : String = "" //為了開啟瀏覽器去
    
    var photoTableView = UITableView()
    var smallItemTableView = UITableView()
    var bigItemTableView = UITableView()
    var photoDelegate = PhotoTableViewDelegate()
    var smallItemDelegate = ItemTableViewDelegate()
    var bigItemDelegate = BigItemTableViewDelegate()
    var tableViewRefreshControl : UIRefreshControl!
    
    var currentBulletinBoard : CurrentBulletinBoard = .Profile
    
    let bookMarkName_Sell = "擺攤"
    let bookMarkName_Buy = "徵求"
    let bookMarkName_TeamUp = "號召"
    let bookMarkName_MakeFriend = "Hi！"
    var currentItemType : Item.ItemType = .Sell
    var personInfo : PersonDetailInfo! //現在要show的個人資訊
    
    let storeNameWordLimit = 12
    let storeNameTextFieldDelegate = WordLimitUITextFieldDelegate()
    var storeNameTextFieldCountLabel = UILabel()
    var storeNameTextField = UITextField()
    
    let iWantSayHiBtn = UIButton()
    
    var hiddeningTapBar = false
    
    private var storeRemainingTimeTimer = Timer()
    
    private let iWantActionSheetKit = ActionSheetKit()
    
    var bookMarks_full: [String] = []
    var bookMarks_half: [String] = []
    
    var bookMarks_segmented_forHalfStatus = SSSegmentedControl(items: [],type: .pure)
    var bookMarks_segmented_forFullStatus = SSSegmentedControl(items: [],type: .pure)
    
    
    var firebaseCoffeeScoreDatas : [CoffeeScoreData] = []
    var coffeeComments : [Comment] = []
    var coffeeCommentObserverRef : DatabaseReference!
    
    //以下是關注咖啡店用的
    var loveShopLabel = UILabel()
    var currentCoffeeAnnotation : CoffeeAnnotation? = nil
    
    //以下是相席用的
    var currentSharedSeatAnnotation : SharedSeatAnnotation? = nil
    var circleButton_mySharedSeat = UIButton()
    var unreadMySharedSeatNotifcationCount = 0
    var unreadMySharedSeatNotiCountCircle = UIButton()
    var signUpBtn = SSButton()
    var invitationCodeLabel = UILabel()
    var signUpCountCircle = UIButton()
    
    //未讀通知數量
    var unreadNotifcationCount = 0
    var unreadNotiCountCircle = UIButton()
    
    //未讀訊息數量
    var unreadMsgCount = 0
    var unreadMsgCountCircle = UIButton()
    
    
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
        sharedSeatAnnotationGetter = SharedSeatAnnotationGetter(mapView: mapView)
        coffeeAnnotationGetter = CoffeeAnnotationGetter(mapView: mapView)
        
#if FACETRADER
        presonAnnotationGetter.fetchPersonData()
#elseif VERYINCORRECT
        sharedSeatAnnotationGetter.fetchSharedSeatData()
        if(!UserSetting.isShowedExplain){
            explainBtnAct()
        }
#endif
        
        coffeeAnnotationGetter.fetchCoffeeData()
        
        
        configureActionSheet()
        
        AppStoreRating.share.listener()
        
        updatePersonAnnotation()
        
        centerMapOnUserLocation(shouldLoadAnnotations: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        bigItemTableView.reloadData()
        smallItemTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hiddenTabBarOrNot()
    }
    
    fileprivate func hiddenTabBarOrNot(){
        //        if hiddeningTapBar{
        CoordinatorAndControllerInstanceHelper.rootCoordinator.hiddenTabBar()
        //        }else{
        //            CoordinatorAndControllerInstanceHelper.rootCoordinator.showTabBar()
        //        }
    }
    
    //更新firebase上的經緯度
    fileprivate func  updatePersonAnnotation() {
        let ref = Database.database().reference()
        let personAnnotationWithIDRef = ref.child("PersonAnnotation/" +  UserSetting.UID)
        personAnnotationWithIDRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists(){
                FirebaseHelper.updatePersonAnnotation()
            }
        })
    }
    
    fileprivate func configureActionSheet() {
        
        
        iWantActionSheetContainer.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: view.frame.height)
        
        
#if FACETRADER
        let actionSheetText = ["取消","新增咖啡店","徵求某東西","擺攤賣東西","向周遭Say Hi交朋友"]
        iWantActionSheetKit.creatActionSheet(containerView: view, actionSheetText: actionSheetText)
        iWantActionSheetKit.getActionSheetBtn(i: 0)?.addTarget(self, action: #selector(iWantConcealBtnAct), for: .touchUpInside)
        iWantActionSheetKit.getActionSheetBtn(i: 1)?.addTarget(self, action: #selector(addCoffeeBtnAct), for: .touchUpInside)
        iWantActionSheetKit.getActionSheetBtn(i: 2)?.addTarget(self, action: #selector(iWantRequestBtnAct), for: .touchUpInside)
        iWantActionSheetKit.getActionSheetBtn(i: 3)?.addTarget(self, action: #selector(iWantOpenStoreBtnAct), for: .touchUpInside)
        iWantActionSheetKit.getActionSheetBtn(i: 4)?.addTarget(self, action: #selector(iWantSayHiBtnAct), for: .touchUpInside)
        print("if FACETRADER if FACETRADER")
#elseif VERYINCORRECT
        let actionSheetText = ["取消","新增咖啡店","使用邀請碼參加聚會或一同報名","發起相席"]
        iWantActionSheetKit.creatActionSheet(containerView: view, actionSheetText: actionSheetText)
        iWantActionSheetKit.getActionSheetBtn(i: 0)?.addTarget(self, action: #selector(iWantConcealBtnAct), for: .touchUpInside)
        iWantActionSheetKit.getActionSheetBtn(i: 1)?.addTarget(self, action: #selector(addCoffeeBtnAct), for: .touchUpInside)
        iWantActionSheetKit.getActionSheetBtn(i: 2)?.addTarget(self, action: #selector(iWantUseInvitationCode), for: .touchUpInside)
        iWantActionSheetKit.getActionSheetBtn(i: 3)?.addTarget(self, action: #selector(iWantSharedSeatBtnAct), for: .touchUpInside)
        print("elseif VERYINCORRECTelseif VERYINCORRECT")
#endif
        
        iWantActionSheetKit.getbgBtn().addTarget(self, action: #selector(iWantActionSheetBGBtnAct), for: .touchUpInside)
        iWantActionSheetKit.getbgBtn().addSubview(iWantActionSheetContainer)
        iWantActionSheetContainer.addTarget(self, action: #selector(iWantActionSheetContainerAct), for: .touchUpInside)
        
        
        
        let storeNameTextFieldContainer = {() -> UIView in
            let view = UIView(frame: CGRect(x: self.view.frame.width/2 - 110, y: self.view.frame.height/2 - 144, width: 220, height: 80))
            view.backgroundColor = .on().withAlphaComponent(0.6)
            view.layer.cornerRadius = 4
            return view
        }()
        iWantActionSheetContainer.addSubview(storeNameTextFieldContainer)
        
        let storeNameTextFieldInnerContainer = {() -> UIView in
            let view = UIView(frame: CGRect(x: self.view.frame.width/2 - 94, y: self.view.frame.height/2 - 119, width: 188, height: 30))
            view.backgroundColor = .baseBackground().withAlphaComponent(0.2)
            view.layer.cornerRadius = 2
            return view
        }()
        iWantActionSheetContainer.addSubview(storeNameTextFieldInnerContainer)
        
        
        let explainLabel  = { () -> UILabel in
            let label = UILabel()
            label.text = "在這裡寫下店名或大聲想說的話"
            label.textColor = .baseBackground().withAlphaComponent(0.7)
            label.font = UIFont(name: "HelveticaNeue", size: 12)
            label.textAlignment = .center
            label.frame = CGRect(x:view.frame.width/2 - 120, y:self.view.frame.height/2 - 140, width: 240, height: label.intrinsicContentSize.height)
            return label
        }()
        iWantActionSheetContainer.addSubview(explainLabel)
        
        
        storeNameTextFieldCountLabel  = { () -> UILabel in
            let label = UILabel()
            label.text = "\(storeNameWordLimit - UserSetting.storeName.count)"
            label.textColor = .baseBackground().withAlphaComponent(0.7)
            label.font = UIFont(name: "HelveticaNeue", size: 12)
            label.textAlignment = .left
            label.frame = CGRect(x:view.frame.width/2 + 84, y:self.view.frame.height/2 - 83, width: 26, height: label.intrinsicContentSize.height)
            return label
        }()
        iWantActionSheetContainer.addSubview(storeNameTextFieldCountLabel)
        
        storeNameTextField = {() -> UITextField in
            let textField = UITextField()
            textField.tintColor = .baseBackground()
            textField.frame = CGRect(x:self.view.frame.width/2 - 150, y: view.frame.height/2 - 135, width: 300, height: 60)
            textField.attributedPlaceholder = NSAttributedString(string:
                                                                    " ", attributes:
                                                                    [NSAttributedString.Key.foregroundColor:UIColor.hexStringToUIColor(hex: "B7B7B7")])
            textField.text = UserSetting.storeName
            textField.clearButtonMode = .whileEditing
            textField.textAlignment = .center
            textField.returnKeyType = .done
            textField.textColor = .baseBackground()
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
        
        bulletinBoardContainer.layer.masksToBounds = false
        bulletinBoardContainer.backgroundColor = .surface()
        bulletinBoardContainer.layer.cornerRadius = 10
        bulletinBoardContainer.layer.shadowOffset = CGSize(width: 0, height:-2)
        bulletinBoardContainer.layer.shadowOpacity = 0.3
        
        let stick = UIView()
        stick.frame = CGRect(x: view.frame.width/2 - 33, y: 7, width: 66, height: 4)
        stick.layer.cornerRadius = 3
        stick.backgroundColor = .lightGray
        
        
        view.addSubview(bulletinBoardContainer)
        bulletinBoardContainer.addSubview(stick)
        bulletinBoardContainer.addSubview(bulletinBoardTempContainer)
        
        bulletinBoard_BuySellPart.frame = CGRect(x: 0, y: 0 , width: bulletinBoardTempContainer.frame.width, height: bulletinBoardTempContainer.frame.height)
        bulletinBoardTempContainer.addSubview(bulletinBoard_BuySellPart)
        
        bulletinBoard_TeamUpPart.frame = CGRect(x: 0, y: 0 , width: bulletinBoardTempContainer.frame.width, height: bulletinBoardTempContainer.frame.height)
        bulletinBoardTempContainer.addSubview(bulletinBoard_TeamUpPart)
        
        bulletinBoard_ProfilePart.frame = CGRect(x: 0, y: 0, width: bulletinBoardTempContainer.frame.width, height: bulletinBoardTempContainer.frame.height)
        bulletinBoardTempContainer.addSubview(bulletinBoard_ProfilePart)
        
        bulletinBoard_CoffeeShop.frame = CGRect(x: 0, y: 0 , width: bulletinBoardTempContainer.frame.width, height: bulletinBoardTempContainer.frame.height)
        bulletinBoardTempContainer.addSubview(bulletinBoard_CoffeeShop)
        
        
        bulletinBoard_SharedSeat.frame = CGRect(x: 0, y: 0 , width: bulletinBoardTempContainer.frame.width, height: bulletinBoardTempContainer.frame.height)
        bulletinBoardTempContainer.addSubview(bulletinBoard_SharedSeat)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeUp.direction = .up
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeDown.direction = .down
        bulletinBoardTempContainer.addGestureRecognizer(swipeUp)
        bulletinBoardTempContainer.addGestureRecognizer(swipeDown)
        
    }
    
    @objc func handleSwipeGesture(sender: UISwipeGestureRecognizer) {
        
        if sender.direction == .up {
            //如果是在SharedSeat頁，不能上滑
            if bulletinBoard_SharedSeat.subviews.count > 0{
                return
            }
            
            if bulletinBoardExpansionState == .NotExpanded {
                let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
                animateBulletinBoard(targetPosition: view.frame.height - 300 - bottomPadding) { (_) in
                    self.bulletinBoardExpansionState = .PartiallyExpanded
                }
            }
            if bulletinBoardExpansionState == .PartiallyExpanded {
                print("bulletinBoardExpansionState == .PartiallyExpanded")
                bigItemTableView.reloadData()
                animateBulletinBoard(targetPosition: 40) { (_) in
                    self.bulletinBoardExpansionState = .FullyExpanded
                }
                
                bulletinBoard_ProfilePart.isHidden = false
                bulletinBoard_ProfilePart.alpha = 0
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                    self.bulletinBoard_ProfilePart.alpha = 1
                    self.bulletinBoard_TeamUpPart.alpha = 0
                    self.bulletinBoard_BuySellPart.alpha = 0
                    self.bookMarks_segmented_forHalfStatus.alpha = 0
                }, completion:  { _ in
                    self.bulletinBoard_TeamUpPart.isHidden = true
                    self.bulletinBoard_BuySellPart.isHidden = true
                    self.bookMarks_segmented_forHalfStatus.isHidden = true
                    self.bulletinBoard_TeamUpPart.alpha = 1
                    self.bulletinBoard_BuySellPart.alpha = 1
                })
                
                
                
                //準備好profile面板的下方
                bulletinBoard_ProfilePart_Bottom.isHidden = false
                bulletinBoard_ProfilePart_Bottom.alpha = 0
                
                
                //標籤fadeOut profile面板下方fadeIn
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                    self.bulletinBoard_ProfilePart_plzSlideUp.alpha = 0
                    self.bulletinBoard_ProfilePart_Bottom.alpha = 1
                }, completion: nil)
                
                
                
                var bookMarks_temp = bookMarks_half
                if(bookMarks_temp.count > 0){
                    bookMarks_temp.remove(at: 0)
                }
                switch currentBulletinBoard {
                case .Profile:
                    break
                case .Buy:
                    bookMarks_segmented_forFullStatus.selectedSegmentIndex = bookMarks_temp.firstIndex(of: bookMarkName_Buy) ?? 0
                    break
                case .Sell:
                    bookMarks_segmented_forFullStatus.selectedSegmentIndex = bookMarks_temp.firstIndex(of: bookMarkName_Sell) ?? 0
                    break
                case .TeamUp:
                    bookMarks_segmented_forFullStatus.selectedSegmentIndex = bookMarks_temp.firstIndex(of: bookMarkName_TeamUp) ?? 0
                    break
                }
            }
        } else {
            
            print("sender.direction == .down")
            bulletinBoard_ProfilePart_plzSlideUp.alpha = 1
            
            if bulletinBoardExpansionState == .FullyExpanded {
                print("半縮小")
                //                animateBulletinBoard(targetPosition: view.frame.height - 274) { (_) in
                //                    self.bulletinBoardExpansionState = .PartiallyExpanded
                //                }
                //
                //
                
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
                
                //                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                //                    switch currentBulletinBoard {
                //                        case .Profile:
                //                        self.bulletinBoard_ProfilePart_plzSlideUp.alpha = 1
                //                            break
                //                    //                case .Buy:
                //                    //                    fadeInBuySellBoard()
                //                    //                    break
                //                    //                case .Sell:
                //                    //                    fadeInBuySellBoard()
                //                    //                    break
                //                    //                case .TeamUp:
                //                    //                    fadeInTeamUpBoard()
                //                    //                    break
                //                    //                }
                //                    }
                //
                //                }, completion: { _ in
                //
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
    
    fileprivate func drawStarsAfterLabel(_ board: UIView,_ label: UILabel,_ point:CGFloat) {
        
        
        let interval : CGFloat = 2
        let wifiStar_1 = UIImageView(frame: CGRect(x: label.frame.origin.x - 100 + view.frame.width/2 - interval * 4, y: label.frame.origin.y + 1, width: 16, height: 14.4))
        if point == 0{
            wifiStar_1.image = UIImage(named: "EmptyStar")?.withRenderingMode(.alwaysTemplate)
        }else if point == 0.5{
            wifiStar_1.image = UIImage(named: "HalfStar")?.withRenderingMode(.alwaysTemplate)
        }else {
            wifiStar_1.image = UIImage(named: "FullStar")?.withRenderingMode(.alwaysTemplate)
        }
        wifiStar_1.tintColor = .sksIndigo()
        board.addSubview(wifiStar_1)
        let wifiStar_2 = UIImageView(frame: CGRect(x: label.frame.origin.x - 84 + view.frame.width/2 - interval * 3, y: label.frame.origin.y + 1, width: 16, height: 14.4))
        if point <= 1{
            wifiStar_2.image = UIImage(named: "EmptyStar")?.withRenderingMode(.alwaysTemplate)
        }else if point == 1.5{
            wifiStar_2.image = UIImage(named: "HalfStar")?.withRenderingMode(.alwaysTemplate)
        }else {
            wifiStar_2.image = UIImage(named: "FullStar")?.withRenderingMode(.alwaysTemplate)
        }
        wifiStar_2.tintColor = .sksIndigo()
        board.addSubview(wifiStar_2)
        let wifiStar_3 = UIImageView(frame: CGRect(x: label.frame.origin.x - 68 + view.frame.width/2 - interval * 2, y: label.frame.origin.y + 1, width: 16, height: 14.4))
        if point <= 2{
            wifiStar_3.image = UIImage(named: "EmptyStar")?.withRenderingMode(.alwaysTemplate)
        }else if point == 2.5{
            wifiStar_3.image = UIImage(named: "HalfStar")?.withRenderingMode(.alwaysTemplate)
        }else {
            wifiStar_3.image = UIImage(named: "FullStar")?.withRenderingMode(.alwaysTemplate)
        }
        wifiStar_3.tintColor = .sksIndigo()
        board.addSubview(wifiStar_3)
        let wifiStar_4 = UIImageView(frame: CGRect(x: label.frame.origin.x - 52 + view.frame.width/2 - interval, y: label.frame.origin.y + 1, width: 16, height: 14.4))
        if point <= 3{
            wifiStar_4.image = UIImage(named: "EmptyStar")?.withRenderingMode(.alwaysTemplate)
        }else if point == 3.5{
            wifiStar_4.image = UIImage(named: "HalfStar")?.withRenderingMode(.alwaysTemplate)
        }else {
            wifiStar_4.image = UIImage(named: "FullStar")?.withRenderingMode(.alwaysTemplate)
        }
        wifiStar_4.tintColor = .sksIndigo()
        board.addSubview(wifiStar_4)
        let wifiStar_5 = UIImageView(frame: CGRect(x: label.frame.origin.x - 36 + view.frame.width/2, y: label.frame.origin.y + 1, width: 16, height: 14.4))
        if point <= 4{
            wifiStar_5.image = UIImage(named: "EmptyStar")?.withRenderingMode(.alwaysTemplate)
        }else if point == 4.5{
            wifiStar_5.image = UIImage(named: "HalfStar")?.withRenderingMode(.alwaysTemplate)
        }else {
            wifiStar_5.image = UIImage(named: "FullStar")?.withRenderingMode(.alwaysTemplate)
        }
        wifiStar_5.tintColor = .sksIndigo()
        board.addSubview(wifiStar_5)
    }
    
    
    func refresh_bulletinBoard_CoffeeShop(){
        bulletinBoard_CoffeeShop.removeAllSubviews()
        setBulletinBoard_coffeeData(coffeeAnnotation: currentCoffeeAnnotation!)
    }
    
    fileprivate func setCoffeeDataAfterFetch(_ coffeeAnnotation: CoffeeAnnotation) {
        
        bulletinBoard_CoffeeShop.isHidden = false
        bulletinBoard_TeamUpPart.isHidden = true
        bulletinBoard_BuySellPart.isHidden = true
        bulletinBoard_ProfilePart.isHidden = true
        bulletinBoard_SharedSeat.isHidden = true
        
        let shopNameLabel = UILabel()
        shopNameLabel.font = UIFont(name: "HelveticaNeue", size: 16)
        shopNameLabel.text = coffeeAnnotation.name
        shopNameLabel.frame = CGRect(x: 10, y: 19, width: shopNameLabel.intrinsicContentSize.width, height: shopNameLabel.intrinsicContentSize.height)
        shopNameLabel.textColor = .on()
        bulletinBoard_CoffeeShop.addSubview(shopNameLabel)
        
        let userloc = CLLocation(latitude: mapView.userLocation.coordinate.latitude, longitude: mapView.userLocation.coordinate.longitude)
        let coffeeloc = CLLocation(latitude: coffeeAnnotation.coordinate.latitude, longitude: coffeeAnnotation.coordinate.longitude)
        var distance = userloc.distance(from: coffeeloc)
        
        let addressLabel = UILabel()
        addressLabel.font = UIFont(name: "HelveticaNeue", size: 12)
        addressLabel.text = coffeeAnnotation.address
        addressLabel.frame = CGRect(x: 10, y: 39, width: addressLabel.intrinsicContentSize.width, height: addressLabel.intrinsicContentSize.height)
        addressLabel.textColor = .on().withAlphaComponent(0.7)
        bulletinBoard_CoffeeShop.addSubview(addressLabel)
        
        
        if verifyUrl(urlString: coffeeAnnotation.url){
            coffeeShop_url = coffeeAnnotation.url
            let fbBtn = UIButton()
            fbBtn.frame = CGRect(x: 10 + shopNameLabel.intrinsicContentSize.width + 4, y: 18.5, width: 20, height: 20)
            let fbIcon = UIImage(named: "facebookIcon")?.withRenderingMode(.alwaysTemplate)
            fbBtn.setImage(fbIcon, for: .normal)
            fbBtn.tintColor = .primary()
            fbBtn.isEnabled = true
            fbBtn.addTarget(self, action: #selector(fbBtnAct), for: .touchUpInside)
            bulletinBoard_CoffeeShop.addSubview(fbBtn)
        }
        
        let attentionBtn = UIButton()
        attentionBtn.frame = CGRect(x: view.frame.width - 24 - 12, y: 22, width: 24, height: 24)
        var attentionIcon = UIImage(named: "loveIcon")?.withRenderingMode(.alwaysTemplate)
        if(UserSetting.attentionCafe.contains(coffeeAnnotation.address)){
            attentionIcon = UIImage(named: "實愛心")?.withRenderingMode(.alwaysTemplate)
        }
        attentionBtn.setImage(attentionIcon, for: .normal)
        attentionBtn.tintColor = .primary()
        attentionBtn.isEnabled = true
        attentionBtn.addTarget(self, action: #selector(attentionBtnAct), for: .touchUpInside)
        bulletinBoard_CoffeeShop.addSubview(attentionBtn)
        
        
        let scoreBtn = UIButton()
        scoreBtn.frame = CGRect(x: view.frame.width - 48 - 24, y: 22, width: 24, height: 24)
        var scoreImg = UIImage(named: "commitIcon")?.withRenderingMode(.alwaysTemplate)
        scoreBtn.setImage(scoreImg, for: .normal)
        scoreBtn.tintColor = .primary()
        scoreBtn.isEnabled = true
        scoreBtn.addTarget(self, action: #selector(scoreBtnAct), for: .touchUpInside)
        bulletinBoard_CoffeeShop.addSubview(scoreBtn)
        
        
        let commitIcon = UIImageView(frame: CGRect(x: 9, y: 58, width: 20, height: 18))
        commitIcon.image = UIImage(named: "commitIcon")?.withRenderingMode(.alwaysTemplate)
        commitIcon.tintColor = .sksIndigo()
        bulletinBoard_CoffeeShop.addSubview(commitIcon)
        let commitLabel = UILabel()
        commitLabel.text = "評分：" + "\(coffeeAnnotation.reviews + firebaseCoffeeScoreDatas.count)" + "人"
        commitLabel.textColor = .on()
        commitLabel.font = UIFont(name: "HelveticaNeue", size: 13)
        commitLabel.frame = CGRect(x: 9 + 20 + 2, y: 61, width: commitLabel.intrinsicContentSize.width, height: commitLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(commitLabel)
        
        
        let loveShopIcon = UIImageView(frame: CGRect(x: 9 + 20 + 2 + commitLabel.intrinsicContentSize.width + 4, y: 58, width: 18, height: 16))
        loveShopIcon.image = UIImage(named: "loveIcon")?.withRenderingMode(.alwaysTemplate)
        loveShopIcon.tintColor = .sksIndigo()
        bulletinBoard_CoffeeShop.addSubview(loveShopIcon)
        loveShopLabel = UILabel()
        loveShopLabel.text = "愛店：" + "\(coffeeAnnotation.favorites)" + "人"
        if(UserSetting.attentionCafe.contains(coffeeAnnotation.address)){
            loveShopLabel.text = "愛店：" + "\(coffeeAnnotation.favorites + 1)" + "人"
        }
        loveShopLabel.textColor = .on()
        loveShopLabel.font = UIFont(name: "HelveticaNeue", size: 13)
        loveShopLabel.frame = CGRect(x: 9 + 20 + 2 + commitLabel.intrinsicContentSize.width + 4 + 18 + 3, y: 61, width: loveShopLabel.intrinsicContentSize.width, height: loveShopLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(loveShopLabel)
        
        let checkInIcon = UIImageView(frame: CGRect(x:9 + 20 + 2 + commitLabel.intrinsicContentSize.width + 4 + 18 + 3 + loveShopLabel.intrinsicContentSize.width + 4, y: 58, width: 15, height: 19))
        checkInIcon.image = UIImage(named: "chechInIcon")?.withRenderingMode(.alwaysTemplate)
        checkInIcon.tintColor = .sksIndigo()
        bulletinBoard_CoffeeShop.addSubview(checkInIcon)
        let checkInLabel = UILabel()
        checkInLabel.text = "打卡：" + "\(coffeeAnnotation.checkins)" + "人"
        checkInLabel.textColor = .on()
        checkInLabel.font = UIFont(name: "HelveticaNeue", size: 13)
        checkInLabel.frame = CGRect(x: 9 + 20 + 2 + commitLabel.intrinsicContentSize.width + 4 + 18 + 3 + loveShopLabel.intrinsicContentSize.width + 4 + 15 + 3, y: 61, width: checkInLabel.intrinsicContentSize.width, height: checkInLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(checkInLabel)
        
        
        //平均firebase上的評分跟原先的評分
        var wifiScore : CGFloat = 0
        var quietScore : CGFloat = 0
        var seatScore : CGFloat = 0
        var tastyScore : CGFloat = 0
        var cheapScore : CGFloat = 0
        var musicScore : CGFloat = 0
        
        for firebaseCoffeeScoreData in firebaseCoffeeScoreDatas{
            wifiScore += CGFloat(firebaseCoffeeScoreData.wifiScore)
            quietScore += CGFloat(firebaseCoffeeScoreData.quietScore)
            seatScore += CGFloat(firebaseCoffeeScoreData.seatScore)
            tastyScore += CGFloat(firebaseCoffeeScoreData.tastyScore)
            cheapScore += CGFloat(firebaseCoffeeScoreData.cheapScore)
            musicScore += CGFloat(firebaseCoffeeScoreData.musicScore)
        }
        wifiScore += coffeeAnnotation.wifi * CGFloat(coffeeAnnotation.reviews)
        quietScore += coffeeAnnotation.quiet * CGFloat(coffeeAnnotation.reviews)
        seatScore += coffeeAnnotation.seat * CGFloat(coffeeAnnotation.reviews)
        tastyScore += coffeeAnnotation.tasty * CGFloat(coffeeAnnotation.reviews)
        cheapScore += coffeeAnnotation.cheap * CGFloat(coffeeAnnotation.reviews)
        musicScore += coffeeAnnotation.music * CGFloat(coffeeAnnotation.reviews)
        
        if(!(firebaseCoffeeScoreDatas.count == 0 && coffeeAnnotation.reviews == 0)){
            wifiScore = wifiScore/(CGFloat(firebaseCoffeeScoreDatas.count) + CGFloat(coffeeAnnotation.reviews))
            quietScore = quietScore/(CGFloat(firebaseCoffeeScoreDatas.count) + CGFloat(coffeeAnnotation.reviews))
            seatScore = seatScore/(CGFloat(firebaseCoffeeScoreDatas.count) + CGFloat(coffeeAnnotation.reviews))
            tastyScore = tastyScore/(CGFloat(firebaseCoffeeScoreDatas.count) + CGFloat(coffeeAnnotation.reviews))
            cheapScore = cheapScore/(CGFloat(firebaseCoffeeScoreDatas.count) + CGFloat(coffeeAnnotation.reviews))
            musicScore = musicScore/(CGFloat(firebaseCoffeeScoreDatas.count) + CGFloat(coffeeAnnotation.reviews))
        }
        
        let wifiLabel = UILabel()
        wifiLabel.text = "WIFI穩定"
        wifiLabel.textColor = .on()
        wifiLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        wifiLabel.frame = CGRect(x: 10, y: 83, width: wifiLabel.intrinsicContentSize.width, height: wifiLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(wifiLabel)
        let labelHeightWithInterval = wifiLabel.intrinsicContentSize.height + 8
        
        drawStarsAfterLabel(bulletinBoard_CoffeeShop,wifiLabel,wifiScore)
        
        
        let quietLabel = UILabel()
        quietLabel.text = "安靜程度"
        quietLabel.textColor = .on()
        quietLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        quietLabel.frame = CGRect(x: 10, y: 83 + labelHeightWithInterval, width: quietLabel.intrinsicContentSize.width, height: quietLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(quietLabel)
        drawStarsAfterLabel(bulletinBoard_CoffeeShop,quietLabel,quietScore)
        
        let seatLabel = UILabel()
        seatLabel.text = "通常有位"
        seatLabel.textColor = .on()
        seatLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        seatLabel.frame = CGRect(x: 10, y: 83 + labelHeightWithInterval * 2, width: seatLabel.intrinsicContentSize.width, height: seatLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(seatLabel)
        drawStarsAfterLabel(bulletinBoard_CoffeeShop,seatLabel,seatScore)
        
        let mondayLabel = UILabel()
        mondayLabel.text = "週一"
        mondayLabel.textColor = .on()
        mondayLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        mondayLabel.frame = CGRect(x: 10, y: 83 + labelHeightWithInterval * 3, width: mondayLabel.intrinsicContentSize.width, height: mondayLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(mondayLabel)
        
        let mondayLabel_value = UILabel()
        mondayLabel_value.text = "公休"
        if let open = coffeeAnnotation.business_hours?.monday.open,let close = coffeeAnnotation.business_hours?.monday.close{
            mondayLabel_value.text = open + " ~ " + close
        }
        mondayLabel_value.textColor = .on()
        mondayLabel_value.font = UIFont(name: "HelveticaNeue", size: 15)
        mondayLabel_value.frame = CGRect(x: view.frame.width/2 - mondayLabel_value.intrinsicContentSize.width - 10, y: 83 + labelHeightWithInterval * 3, width: mondayLabel_value.intrinsicContentSize.width, height: mondayLabel_value.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(mondayLabel_value)
        
        let tuesdayLabel = UILabel()
        tuesdayLabel.text = "週二"
        tuesdayLabel.textColor = .on()
        tuesdayLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        tuesdayLabel.frame = CGRect(x: 10, y: 83 + labelHeightWithInterval * 4, width: tuesdayLabel.intrinsicContentSize.width, height: tuesdayLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(tuesdayLabel)
        
        let tuesdayLabel_value = UILabel()
        tuesdayLabel_value.text = "公休"
        if let open = coffeeAnnotation.business_hours?.tuesday.open,let close = coffeeAnnotation.business_hours?.tuesday.close{
            tuesdayLabel_value.text = open + " ~ " + close
        }
        tuesdayLabel_value.textColor = .on()
        tuesdayLabel_value.font = UIFont(name: "HelveticaNeue", size: 15)
        tuesdayLabel_value.frame = CGRect(x: view.frame.width/2 - tuesdayLabel_value.intrinsicContentSize.width - 10, y: 83 + labelHeightWithInterval * 4, width: tuesdayLabel_value.intrinsicContentSize.width, height: tuesdayLabel_value.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(tuesdayLabel_value)
        
        let wednesdayLabel = UILabel()
        wednesdayLabel.text = "週三"
        wednesdayLabel.textColor = .on()
        wednesdayLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        wednesdayLabel.frame = CGRect(x: 10, y: 83 + labelHeightWithInterval * 5, width: wednesdayLabel.intrinsicContentSize.width, height: wednesdayLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(wednesdayLabel)
        
        let wednesdayLabel_value = UILabel()
        wednesdayLabel_value.text = "公休"
        if let open = coffeeAnnotation.business_hours?.wednesday.open,let close = coffeeAnnotation.business_hours?.wednesday.close{
            wednesdayLabel_value.text = open + " ~ " + close
        }
        wednesdayLabel_value.textColor = .on()
        wednesdayLabel_value.font = UIFont(name: "HelveticaNeue", size: 15)
        wednesdayLabel_value.frame = CGRect(x: view.frame.width/2 - wednesdayLabel_value.intrinsicContentSize.width - 10, y: 83 + labelHeightWithInterval * 5, width: wednesdayLabel_value.intrinsicContentSize.width, height: wednesdayLabel_value.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(wednesdayLabel_value)
        
        let thursdayLabel = UILabel()
        thursdayLabel.text = "週四"
        thursdayLabel.textColor = .on()
        thursdayLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        thursdayLabel.frame = CGRect(x: 10, y: 83 + labelHeightWithInterval * 6, width: thursdayLabel.intrinsicContentSize.width, height: thursdayLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(thursdayLabel)
        
        let thursdayLabel_value = UILabel()
        thursdayLabel_value.text = "公休"
        if let open = coffeeAnnotation.business_hours?.thursday.open,let close = coffeeAnnotation.business_hours?.thursday.close{
            thursdayLabel_value.text = open + " ~ " + close
        }
        thursdayLabel_value.textColor = .on()
        thursdayLabel_value.font = UIFont(name: "HelveticaNeue", size: 15)
        thursdayLabel_value.frame = CGRect(x: view.frame.width/2 - thursdayLabel_value.intrinsicContentSize.width - 10, y: 83 + labelHeightWithInterval * 6, width: thursdayLabel_value.intrinsicContentSize.width, height: thursdayLabel_value.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(thursdayLabel_value)
        
        let fridayLabel = UILabel()
        fridayLabel.text = "週五"
        fridayLabel.textColor = .on()
        fridayLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        fridayLabel.frame = CGRect(x: 10, y: 83 + labelHeightWithInterval * 7, width: fridayLabel.intrinsicContentSize.width, height: fridayLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(fridayLabel)
        
        let fridayLabel_value = UILabel()
        fridayLabel_value.text = "公休"
        if let open = coffeeAnnotation.business_hours?.friday.open,let close = coffeeAnnotation.business_hours?.friday.close{
            fridayLabel_value.text = open + " ~ " + close
        }
        fridayLabel_value.textColor = .on()
        fridayLabel_value.font = UIFont(name: "HelveticaNeue", size: 15)
        fridayLabel_value.frame = CGRect(x: view.frame.width/2 - fridayLabel_value.intrinsicContentSize.width - 10, y: 83 + labelHeightWithInterval * 7, width: fridayLabel_value.intrinsicContentSize.width, height: fridayLabel_value.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(fridayLabel_value)
        
        
        let tastyLabel = UILabel()
        tastyLabel.text = "咖啡好喝"
        tastyLabel.textColor = .on()
        tastyLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        tastyLabel.frame = CGRect(x: view.frame.width/2 + 10, y: 83, width: tastyLabel.intrinsicContentSize.width, height: tastyLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(tastyLabel)
        drawStarsAfterLabel(bulletinBoard_CoffeeShop,tastyLabel,tastyScore)
        
        let cheapLabel = UILabel()
        cheapLabel.text = "價格便宜"
        cheapLabel.textColor = .on()
        cheapLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        cheapLabel.frame = CGRect(x: view.frame.width/2 + 10, y: 83 + labelHeightWithInterval, width: cheapLabel.intrinsicContentSize.width, height: cheapLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(cheapLabel)
        drawStarsAfterLabel(bulletinBoard_CoffeeShop,cheapLabel,cheapScore)
        
        let musicLabel = UILabel()
        musicLabel.text = "裝潢音樂"
        musicLabel.textColor = .on()
        musicLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        musicLabel.frame = CGRect(x: view.frame.width/2 + 10, y: 83 + labelHeightWithInterval * 2, width: musicLabel.intrinsicContentSize.width, height: musicLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(musicLabel)
        drawStarsAfterLabel(bulletinBoard_CoffeeShop,musicLabel,musicScore)
        
        let saturdayLabel = UILabel()
        saturdayLabel.text = "週六"
        saturdayLabel.textColor = .on()
        saturdayLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        saturdayLabel.frame = CGRect(x:view.frame.width/2 + 10, y: 83 + labelHeightWithInterval * 3, width: saturdayLabel.intrinsicContentSize.width, height: saturdayLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(saturdayLabel)
        
        let saturdayLabel_value = UILabel()
        saturdayLabel_value.text = "公休"
        if let open = coffeeAnnotation.business_hours?.saturday.open,let close = coffeeAnnotation.business_hours?.saturday.close{
            saturdayLabel_value.text = open + " ~ " + close
        }
        saturdayLabel_value.textColor = .on()
        saturdayLabel_value.font = UIFont(name: "HelveticaNeue", size: 15)
        saturdayLabel_value.frame = CGRect(x: view.frame.width - saturdayLabel_value.intrinsicContentSize.width - 10, y: 83 + labelHeightWithInterval * 3, width: saturdayLabel_value.intrinsicContentSize.width, height: saturdayLabel_value.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(saturdayLabel_value)
        
        let sundayLabel = UILabel()
        sundayLabel.text = "週日"
        sundayLabel.textColor = .on()
        sundayLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        sundayLabel.frame = CGRect(x:view.frame.width/2 + 10, y: 83 + labelHeightWithInterval * 4, width: tuesdayLabel.intrinsicContentSize.width, height: tuesdayLabel.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(sundayLabel)
        
        let sundayLabel_value = UILabel()
        sundayLabel_value.text = "公休"
        if let open = coffeeAnnotation.business_hours?.sunday.open,let close = coffeeAnnotation.business_hours?.sunday.close{
            sundayLabel_value.text = open + " ~ " + close
        }
        sundayLabel_value.textColor = .on()
        sundayLabel_value.font = UIFont(name: "HelveticaNeue", size: 15)
        sundayLabel_value.frame = CGRect(x: view.frame.width - sundayLabel_value.intrinsicContentSize.width - 10, y: 83 + labelHeightWithInterval * 4, width: sundayLabel_value.intrinsicContentSize.width, height: sundayLabel_value.intrinsicContentSize.height)
        bulletinBoard_CoffeeShop.addSubview(sundayLabel_value)
        
        
        //TAG
        var currentTagX = view.frame.width/2 + 10
        var currentTagY = 83 + labelHeightWithInterval * 5
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
        
        
        //留言
        let commentTableView  =  UITableView()
        
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 300 + 8, width: view.frame.width, height: bulletinBoard_CoffeeShop.frame.height - 300 - 8))
        scrollView.contentSize = CGSize(width: view.frame.width,height: commentTableView.contentSize.height)
        bulletinBoard_CoffeeShop.addSubview(scrollView)
        scrollView.isScrollEnabled = true
        scrollView.bounces = true
        
        commentTableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: commentTableView.contentSize.height)
        scrollView.addSubview(commentTableView)
        
        
        commentTableView.delegate = self
        commentTableView.dataSource = self
        commentTableView.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "commentTableViewCell")
        commentTableView.backgroundColor = .clear
        commentTableView.separatorColor = .clear
        commentTableView.allowsSelection = false
        commentTableView.bounces = false
        commentTableView.isScrollEnabled = false
        commentTableView.rowHeight = UITableView.automaticDimension
        commentTableView.estimatedRowHeight = 54.0
        
        self.coffeeComments = []
        
        var commenterHeadShotDict = [String:UIImage]()
        coffeeCommentObserverRef = Database.database().reference(withPath: "CoffeeComment/" + coffeeAnnotation.address)
        
        coffeeCommentObserverRef.queryOrdered(byChild: "time").observeSingleEvent(of: .value, with: { (snapshot) in
            
            
            for user_child in (snapshot.children){
                var comment = Comment(snapshot: user_child as! DataSnapshot)
                
                if(comment.UID == "錯誤"){
                    continue
                }
                
                comment.commentID = snapshot.key
                
                if let childSnapshots = snapshot.childSnapshot(forPath: "likeUIDs").children.allObjects as? [DataSnapshot]{
                    comment.likeUIDs = []
                    for childSnapshot in childSnapshots{
                        comment.likeUIDs!.append(childSnapshot.key as String)
                    }
                }
                
                commentTableView.beginUpdates()
                self.coffeeComments.insert(comment, at: 0)
                let index = self.coffeeComments.count - 1
                //插入新的comment時，先確認是否smallHeadshot已經下載了
                if commenterHeadShotDict[self.coffeeComments[index].UID] != nil && commenterHeadShotDict[self.coffeeComments[index].UID] != UIImage(named: "Thumbnail"){
                    self.coffeeComments[index].smallHeadshot = commenterHeadShotDict[self.coffeeComments[index].UID]
                }
                let indexPath = IndexPath(row: index, section: 0)
                commentTableView.insertRows(at: [indexPath], with: .automatic)
                print("coffeeComments:" + "\(self.coffeeComments.count)")
                print("index:" + "\(index)")
                commentTableView.endUpdates()
                
                for i in 0 ... self.coffeeComments.count - 1 {
                    let indexPathForSameIDComment = IndexPath(row: i, section: 0)
                    commentTableView.reloadRows(at: [indexPathForSameIDComment], with: .none)
                }
                
                //調整tableView跟scrollView高度
                commentTableView.invalidateIntrinsicContentSize()
                commentTableView.layoutIfNeeded()
                commentTableView.frame = CGRect(x: 0, y: commentTableView.frame.origin.y, width: self.view.frame.width, height: commentTableView.contentSize.height + 10)
                scrollView.contentSize = CGSize(width: self.view.frame.width, height: commentTableView.contentSize.height + 10)
                
                //確認是否commenterHeadShot已經抓過圖了
                if commenterHeadShotDict[self.coffeeComments[index].UID] == nil{
                    commenterHeadShotDict[self.coffeeComments[index].UID] = UIImage(named: "Thumbnail") //這只是隨便一張圖，來確認是否下載過了
                    //去storage那邊找到URL
                    let smallHeadshotRef = Storage.storage().reference().child("userSmallHeadShot/" + self.coffeeComments[index].UID)
                    smallHeadshotRef.downloadURL(completion: { (url, error) in
                        guard let downloadURL = url else {
                            return
                        }
                        //下載URL的圖
                        AF.request(downloadURL).response { (response) in
                            guard let data = response.data, let image = UIImage(data: data)
                            else { return }
                            //裝進commenterHeadShotDict
                            
                            if(index > self.coffeeComments.count - 1) { return }
                            commenterHeadShotDict[self.coffeeComments[index].UID] = image
                            
                            //替換掉所有有相同ID的Comment的headShot
                            for i in 0 ... self.coffeeComments.count - 1 {
                                if self.coffeeComments[i].UID == self.coffeeComments[index].UID{
                                    let indexPathForSameIDComment = IndexPath(row: i, section: 0)
                                    self.coffeeComments[i].smallHeadshot = image
                                    commentTableView.reloadRows(at: [indexPathForSameIDComment], with: .none)
                                    let cell = commentTableView.cellForRow(at: indexPathForSameIDComment) as! CommentTableViewCell
                                    cell.photo.alpha = 0
                                    UIView.animate(withDuration: 0.3, animations: {
                                        cell.photo.alpha = 1
                                        cell.genderIcon.alpha = 0
                                    })
                                    
                                }
                            }
                        }
                    })
                }
            }
        })
        
    }
    
    fileprivate func setBulletinBoard_sharedSeat(sharedSeatAnnotation:SharedSeatAnnotation){
        
        currentSharedSeatAnnotation = sharedSeatAnnotation
        
        bulletinBoard_CoffeeShop.isHidden = true
        bulletinBoard_TeamUpPart.isHidden = true
        bulletinBoard_BuySellPart.isHidden = true
        bulletinBoard_ProfilePart.isHidden = true
        bulletinBoard_SharedSeat.isHidden = false
        
        let dateTimeLabel = UILabel()
        dateTimeLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        dateTimeLabel.text = "聚會時間"
        dateTimeLabel.frame = CGRect(x: view.frame.width - 10 - 120, y: 19, width: 120, height: dateTimeLabel.intrinsicContentSize.height)
        dateTimeLabel.textAlignment = .center
        dateTimeLabel.textColor = .on().withAlphaComponent(0.5)
        bulletinBoard_SharedSeat.addSubview(dateTimeLabel)
        
        
        let firebaseDateFormatter = DateFormatter()
        firebaseDateFormatter.dateFormat = "YYYYMMddHHmmss"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd EEEE HH:mm"
        
        let dateTimeValueLabel = UILabel()
        dateTimeValueLabel.font = UIFont(name: "HelveticaNeue", size: 14)
        
        var dateTimeStr = formatter.string(from: firebaseDateFormatter.date(from: sharedSeatAnnotation.dateTime)!)
        dateTimeStr = dateTimeStr.replace(target: "Monday", withString: "週一")
            .replace(target: "Tuesday", withString: "週二")
            .replace(target: "Wednesday", withString: "週三")
            .replace(target: "Thursday", withString: "週四")
            .replace(target: "Friday", withString: "週五")
            .replace(target: "Saturday", withString: "週六")
            .replace(target: "Sunday", withString: "週日")
        dateTimeValueLabel.text = dateTimeStr
        
        dateTimeValueLabel.textAlignment = .center
        dateTimeValueLabel.frame = CGRect(x: view.frame.width - 10 - 120, y: 37, width: 120, height: dateTimeValueLabel.intrinsicContentSize.height)
        dateTimeValueLabel.textColor = .on()
        bulletinBoard_SharedSeat.addSubview(dateTimeValueLabel)
        
        let reviewTimeLabel = UILabel()
        reviewTimeLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        reviewTimeLabel.text = "抽卡期限"
        reviewTimeLabel.frame = CGRect(x: view.frame.width - 10 - 120, y: 58, width: 120, height: reviewTimeLabel.intrinsicContentSize.height)
        reviewTimeLabel.textAlignment = .center
        reviewTimeLabel.textColor = .on().withAlphaComponent(0.5)
        bulletinBoard_SharedSeat.addSubview(reviewTimeLabel)
        
        let reviewTimeValueLabel = UILabel()
        reviewTimeValueLabel.font = UIFont(name: "HelveticaNeue", size: 14)
        var reviewTimeStr = formatter.string(from: firebaseDateFormatter.date(from: sharedSeatAnnotation.reviewTime)!)
        
        reviewTimeStr = reviewTimeStr.replace(target: "Monday", withString: "週一")
            .replace(target: "Tuesday", withString: "週二")
            .replace(target: "Wednesday", withString: "週三")
            .replace(target: "Thursday", withString: "週四")
            .replace(target: "Friday", withString: "週五")
            .replace(target: "Saturday", withString: "週六")
            .replace(target: "Sunday", withString: "週日")
        reviewTimeValueLabel.text = reviewTimeStr
        reviewTimeValueLabel.textAlignment = .center
        reviewTimeValueLabel.frame = CGRect(x: view.frame.width - 10 - 120, y: 76, width: 120, height: reviewTimeValueLabel.intrinsicContentSize.height)
        reviewTimeValueLabel.textColor = .on()
        bulletinBoard_SharedSeat.addSubview(reviewTimeValueLabel)
        
        let participantLabel = UILabel()
        participantLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        participantLabel.text = "參加者"
        participantLabel.frame = CGRect(x: view.frame.width - 10 - 120, y: 97, width: 120, height: participantLabel.intrinsicContentSize.height)
        participantLabel.textAlignment = .center
        participantLabel.textColor = .on().withAlphaComponent(0.5)
        bulletinBoard_SharedSeat.addSubview(participantLabel)
        
        
        var restaurantPhotoWidth = 0
        if(view.frame.width - 10 - 120 - 20 > 279){
            restaurantPhotoWidth = 279
        }else{
            restaurantPhotoWidth = Int(view.frame.width - 10 - 120 - 20)
        }
        
        var restaurantPhotoX = 0
        restaurantPhotoX = (Int(view.frame.width) - 10 - 120 - restaurantPhotoWidth)/2
        
        let restaurantPhoto = UIImageView()
        restaurantPhoto.frame = CGRect(x: restaurantPhotoX, y: 19, width: restaurantPhotoWidth, height: restaurantPhotoWidth)
        restaurantPhoto.layer.cornerRadius = 20
        restaurantPhoto.clipsToBounds = true
        
        let loadingView = UIView()
        loadingView.frame = CGRect(x: restaurantPhoto.frame.origin.x + restaurantPhoto.frame.width/4, y: restaurantPhoto.frame.origin.y + restaurantPhoto.frame.width/4, width: restaurantPhoto.frame.width/2, height: restaurantPhoto.frame.width/2)
        loadingView.setupToLoadingView()
        bulletinBoard_SharedSeat.addSubview(loadingView)
        bulletinBoard_SharedSeat.addSubview(restaurantPhoto)
        
        if sharedSeatAnnotation.photosUrl != nil && sharedSeatAnnotation.photosUrl!.count > 0{
            restaurantPhoto.contentMode = .scaleAspectFill
            restaurantPhoto.alpha = 0
            AF.request(sharedSeatAnnotation.photosUrl![0]).response { (response) in
                guard let data = response.data, let image = UIImage(data: data)
                else { return }
                restaurantPhoto.image = image
                UIView.animate(withDuration: 0.4, animations:{
                    restaurantPhoto.alpha = 1
                    loadingView.alpha = 0
                })
            }
        }
        
        let addressBtn = UIButton()
        addressBtn.setTitle(sharedSeatAnnotation.address, for: .normal)
        addressBtn.setTitleColor(.sksBlue(), for: .normal)
        addressBtn.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 14)
        let attributedString = NSMutableAttributedString(string: sharedSeatAnnotation.address)
        attributedString.addAttribute(.underlineStyle, value: 1, range: NSMakeRange(0, attributedString.length))
        attributedString.addAttribute(.underlineColor, value: UIColor.sksBlue(), range: NSMakeRange(0, attributedString.length))
        addressBtn.titleLabel?.attributedText = attributedString
        addressBtn.titleLabel?.textAlignment = .center
        addressBtn.backgroundColor = .clear
        addressBtn.frame = CGRect(x: restaurantPhoto.frame.origin.x, y: restaurantPhoto.frame.origin.y + restaurantPhoto.frame.width + 10, width: restaurantPhoto.frame.width, height: 30)
        addressBtn.addTarget(self, action: #selector(addressBtnAct), for: .touchUpInside)
        bulletinBoard_SharedSeat.addSubview(addressBtn)
        
        var boyPhoto1TintColor = UIColor.sksBlue().withAlphaComponent(0.2)
        var girlPhoto1TintColor = UIColor.sksPink().withAlphaComponent(0.2)
        if(sharedSeatAnnotation.boysID != nil && sharedSeatAnnotation.boysID!.count > 0){
            boyPhoto1TintColor = .sksBlue()
        }
        if(sharedSeatAnnotation.girlsID != nil && sharedSeatAnnotation.girlsID!.count > 0){
            girlPhoto1TintColor = .sksPink()
        }
        let boyPhoto1 = ProfilePhoto(frame: CGRect(x: participantLabel.frame.origin.x, y: participantLabel.frame.origin.y + 21, width: (participantLabel.frame.width - 10)/2, height: (participantLabel.frame.width - 10)/2), gender: .Boy, tintColor: boyPhoto1TintColor)
        bulletinBoard_SharedSeat.addSubview(boyPhoto1)
        if(sharedSeatAnnotation.boysID != nil && sharedSeatAnnotation.boysID!.count > 0){
            var i = 0
            for(UID,internalNumber) in sharedSeatAnnotation.boysID!{
                if(i == 0){
                    boyPhoto1.setUID(UID: UID)
                }
                i += 1
            }
        }
        
        let girlPhoto1 = ProfilePhoto(frame: CGRect(x: boyPhoto1.frame.origin.x + boyPhoto1.frame.width + 10, y: boyPhoto1.frame.origin.y, width: (participantLabel.frame.width - 10)/2, height: (participantLabel.frame.width - 10)/2), gender: .Girl, tintColor: girlPhoto1TintColor)
        bulletinBoard_SharedSeat.addSubview(girlPhoto1)
        if(sharedSeatAnnotation.girlsID != nil && sharedSeatAnnotation.girlsID!.count > 0){
            var i = 0
            for(UID,internalNumber) in sharedSeatAnnotation.girlsID!{
                if(i == 0){
                    girlPhoto1.setUID(UID: UID)
                }
                i += 1
            }
        }
        
        
        signUpBtn = SSButton()
        signUpBtn.frame = CGRect(x: boyPhoto1.frame.origin.x, y: boyPhoto1.frame.origin.y + boyPhoto1.frame.height + 7, width: 120, height: 36)
        signUpBtn.type = .filled
        if(sharedSeatAnnotation.holderUID == UserSetting.UID){
            
            if(UserSetting.userGender == 0 && sharedSeatAnnotation.boysID != nil && sharedSeatAnnotation.boysID!.count > 0){
                signUpBtn.setTitle("去聊天室", for: .normal)
                signUpBtn.addTarget(self, action: #selector(goSharedSeatChatroomAct), for: .touchUpInside)
            }else if (UserSetting.userGender == 1 && sharedSeatAnnotation.girlsID != nil && sharedSeatAnnotation.girlsID!.count > 0){
                signUpBtn.setTitle("去聊天室", for: .normal)
                signUpBtn.addTarget(self, action: #selector(goSharedSeatChatroomAct), for: .touchUpInside)
            }else{
                signUpBtn.setTitle("抽出參加者", for: .normal)
                signUpBtn.addTarget(self, action: #selector(signUpBtnAct), for: .touchUpInside)
                let cancelBtn = UIButton()
                cancelBtn.frame = CGRect(x: restaurantPhoto.frame.origin.x + restaurantPhoto.frame.width/2 - 40, y: restaurantPhoto.frame.origin.y + restaurantPhoto.frame.height/2 - 12, width: 80, height: 24)
                cancelBtn.setTitle("取消聚會", for: .normal)
                cancelBtn.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 12)
                cancelBtn.setTitleColor(.white, for: .normal)
                cancelBtn.backgroundColor = .error
                cancelBtn.layer.cornerRadius = 4
                cancelBtn.addTarget(self, action: #selector(cancelSharedSeatBtnAct), for: .touchUpInside)
                bulletinBoard_SharedSeat.addSubview(cancelBtn)
            }
        }else{
            
            if(sharedSeatAnnotation.signUpBoysID != nil && sharedSeatAnnotation.signUpBoysID![UserSetting.UID] != nil){
                signUpBtn.setTitle("取消報名", for: .normal)
                signUpBtn.addTarget(self, action: #selector(cancelSignUpBtnAct), for: .touchUpInside)
                
            }else if(sharedSeatAnnotation.signUpGirlsID != nil && sharedSeatAnnotation.signUpGirlsID![UserSetting.UID] != nil){
                signUpBtn.setTitle("取消報名", for: .normal)
                signUpBtn.addTarget(self, action: #selector(cancelSignUpBtnAct), for: .touchUpInside)
            }else{
                signUpBtn.setTitle("報名", for: .normal)
                signUpBtn.addTarget(self, action: #selector(signUpBtnAct), for: .touchUpInside)
                if (UserSetting.userGender == 0){
                    if(sharedSeatAnnotation.girlsID != nil && sharedSeatAnnotation.girlsID!.count > 0){
                        signUpBtn.setTitle("已滿額", for: .normal)
                        signUpBtn.removeTarget(self, action: #selector(signUpBtnAct), for: .touchUpInside)
                    }
                }else {
                    if(sharedSeatAnnotation.boysID != nil && sharedSeatAnnotation.boysID!.count > 0){
                        signUpBtn.setTitle("已滿額", for: .normal)
                        signUpBtn.removeTarget(self, action: #selector(signUpBtnAct), for: .touchUpInside)
                    }
                }
            }
        }
        signUpBtn.layer.cornerRadius = 8
        bulletinBoard_SharedSeat.addSubview(signUpBtn)
        
        if (sharedSeatAnnotation.mode == 2){
            
            invitationCodeLabel = UILabel()
            invitationCodeLabel.textColor = .error
            invitationCodeLabel.textAlignment = .center
            invitationCodeLabel.font = invitationCodeLabel.font.withSize(14)
            bulletinBoard_SharedSeat.addSubview(invitationCodeLabel)
            
            
            var boyPhoto2TintColor = UIColor.sksBlue().withAlphaComponent(0.2)
            var girlPhoto2TintColor = UIColor.sksPink().withAlphaComponent(0.2)
            if(sharedSeatAnnotation.boysID != nil && sharedSeatAnnotation.boysID!.count > 1){
                boyPhoto2TintColor = .sksBlue()
            }
            if(sharedSeatAnnotation.girlsID != nil && sharedSeatAnnotation.girlsID!.count > 1){
                girlPhoto2TintColor = .sksPink()
            }
            
            let boyPhoto2 = ProfilePhoto(frame: CGRect(x: boyPhoto1.frame.origin.x, y: boyPhoto1.frame.origin.y + boyPhoto1.frame.height + 10, width: (participantLabel.frame.width - 10)/2, height: (participantLabel.frame.width - 10)/2), gender: .Boy, tintColor: boyPhoto2TintColor)
            bulletinBoard_SharedSeat.addSubview(boyPhoto2)
            if(sharedSeatAnnotation.boysID != nil && sharedSeatAnnotation.boysID!.count > 1){
                var i = 0
                for(UID,InvitationCode) in sharedSeatAnnotation.boysID!{
                    if(i == 1){
                        boyPhoto2.setUID(UID: UID)
                    }
                    i += 1
                }
            }else if (sharedSeatAnnotation.boysID != nil && sharedSeatAnnotation.boysID!.count == 1){
                var i = 0
                for(UID,InvitationCode) in sharedSeatAnnotation.boysID!{
                    if(i == 0){
                        if(InvitationCode != "-"){
                            if sharedSeatAnnotation.holderUID == UserSetting.UID{
                                boyPhoto2.isAccompany("邀請碼\n" + InvitationCode)
                            }else{
                                boyPhoto2.isAccompany("同行\n友人")
                            }
                        }
                    }
                    i += 1
                }
            }
            
            let girlPhoto2 = ProfilePhoto(frame: CGRect(x: boyPhoto2.frame.origin.x + boyPhoto2.frame.width + 10, y: boyPhoto2.frame.origin.y, width: (participantLabel.frame.width - 10)/2, height: (participantLabel.frame.width - 10)/2), gender: .Girl, tintColor: girlPhoto2TintColor)
            bulletinBoard_SharedSeat.addSubview(girlPhoto2)
            if(sharedSeatAnnotation.girlsID != nil && sharedSeatAnnotation.girlsID!.count > 1){
                var i = 0
                for(UID,InvitationCode) in sharedSeatAnnotation.girlsID!{
                    if(i == 1){
                        girlPhoto2.setUID(UID: UID)
                    }
                    i += 1
                }
            }else if (sharedSeatAnnotation.girlsID != nil && sharedSeatAnnotation.girlsID!.count == 1){
                var i = 0
                for(UID,InvitationCode) in sharedSeatAnnotation.girlsID!{
                    if(i == 0){
                        if(InvitationCode != "-"){
                            if sharedSeatAnnotation.holderUID == UserSetting.UID{
                                girlPhoto2.isAccompany("邀請碼\n" + InvitationCode)
                            }else{
                                girlPhoto2.isAccompany("同行\n友人")
                            }
                        }
                    }
                    i += 1
                }
            }
            
            signUpBtn.frame = CGRect(x: boyPhoto2.frame.origin.x, y: boyPhoto2.frame.origin.y + boyPhoto2.frame.height + 7, width: 120, height: 36)
            
            if(sharedSeatAnnotation.signUpBoysID != nil && sharedSeatAnnotation.signUpBoysID![UserSetting.UID] != nil){
                for(UID,InvitationCode) in sharedSeatAnnotation.signUpBoysID!{
                    if(UID == UserSetting.UID && InvitationCode != "-" && !InvitationCode.contains("#")){
                        invitationCodeLabel.text = "邀請碼：" + InvitationCode
                    }
                }
            }else if(sharedSeatAnnotation.signUpGirlsID != nil && sharedSeatAnnotation.signUpGirlsID![UserSetting.UID] != nil){
                for(UID,InvitationCode) in sharedSeatAnnotation.signUpGirlsID!{
                    if(UID == UserSetting.UID && InvitationCode != "-" && !InvitationCode.contains("#")){
                        invitationCodeLabel.text = "邀請碼：" + InvitationCode
                    }
                }
            }
            
            invitationCodeLabel.frame = CGRect(x: boyPhoto2.frame.origin.x, y: boyPhoto2.frame.origin.y + 7 + boyPhoto2.frame.height + 7 + 36, width: 120, height: 12)
            
            
        }
        
        if(UserSetting.userGender == 0 && sharedSeatAnnotation.boysID != nil && sharedSeatAnnotation.boysID!.count > 0){
            return
        }else if(UserSetting.userGender == 1 && sharedSeatAnnotation.girlsID != nil && sharedSeatAnnotation.girlsID!.count > 0){
            return
        }
        
        if(sharedSeatAnnotation.holderUID == UserSetting.UID){
            var signUpCount = 0
            signUpCount += sharedSeatAnnotation.signUpBoysID?.count ?? 0
            signUpCount += sharedSeatAnnotation.signUpGirlsID?.count ?? 0
            if(signUpCount != 0){
                signUpCountCircle = UIButton(frame:CGRect(x: signUpBtn.frame.origin.x + signUpBtn.frame.width - 10, y: signUpBtn.frame.origin.y - 4, width: 14, height: 14))
                signUpCountCircle.titleLabel?.font = signUpCountCircle.titleLabel?.font.withSize(12)
                signUpCountCircle.backgroundColor = .sksPink()
                signUpCountCircle.layer.cornerRadius = 7
                
                if(sharedSeatAnnotation.mode == 2){
                    signUpCount = Int(signUpCount/2)
                }
                
                signUpCountCircle.setTitle("\(signUpCount)", for: .normal)
                bulletinBoard_SharedSeat.addSubview(signUpCountCircle)
            }
        }
        
        
    }
    
    fileprivate func setBulletinBoard_coffeeData(coffeeAnnotation : CoffeeAnnotation){
        
        currentCoffeeAnnotation = coffeeAnnotation
        //取得firebase部分的評分
        let ref =  Database.database().reference().child("CoffeeScore/" +  coffeeAnnotation.address)
        firebaseCoffeeScoreDatas = []
        ref.observeSingleEvent(of: .value, with: { [self] (snapshot) in
            for user_child in (snapshot.children){
                let user_snap = user_child as! DataSnapshot
                let coffeeScoreData = CoffeeScoreData(snapshot: user_snap)
                self.firebaseCoffeeScoreDatas.append(coffeeScoreData)
            }
            setCoffeeDataAfterFetch(coffeeAnnotation)
        })
        
        
    }
    
    private func createTagLabel(text: String) -> PaddingLabel {
        let lbl = PaddingLabel()
        lbl.text = text
        lbl.leftInset = 2.0
        lbl.rightInset = 2.0
        lbl.topInset = 2.0
        lbl.bottomInset = 2.0
        lbl.textColor = UIColor.hexStringToUIColor(hex: "#f2f2f2")
        lbl.backgroundColor = .sksIndigo()
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
                
                
                let dic = ["isWantSellSomething":isWantSellSomething,
                           "isWantBuySomething":isWantBuySomething,
                           "sellItemsID":sellItemsID,
                           "buyItemsID":buyItemsID,
                           "userPhotosUrl":photoURLs,] as [String : Any]
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
        for view in bulletinBoard_SharedSeat.subviews{
            view.removeFromSuperview()
        }
        
        bulletinBoardTempContainer.addSubview(bulletinBoard_BuySellPart)
        bulletinBoardTempContainer.addSubview(bulletinBoard_ProfilePart)
        bulletinBoardTempContainer.addSubview(bulletinBoard_TeamUpPart)
        bulletinBoardTempContainer.addSubview(bulletinBoard_CoffeeShop)
        bulletinBoardTempContainer.addSubview(bulletinBoard_SharedSeat)
    }
    
    fileprivate func setBulletinBoard(bookMarks: [String],selectedbookMark: String,snapshot: DataSnapshot,UID:String,distance:Int,storeName:String,openTimeString:String){
        
        
        personInfo = PersonDetailInfo(snapshot: snapshot)
        
        //做出未滑開時的書頁標籤
        bookMarks_half = bookMarks
        bookMarks_segmented_forHalfStatus = SSSegmentedControl(items: bookMarks,type: .pure)
        bookMarks_segmented_forHalfStatus.translatesAutoresizingMaskIntoConstraints = false
        bookMarks_segmented_forHalfStatus.selectedSegmentIndex = 0
        bulletinBoardTempContainer.addSubview(bookMarks_segmented_forHalfStatus)
        bookMarks_segmented_forHalfStatus.centerXAnchor.constraint(equalTo: bulletinBoardTempContainer.centerXAnchor).isActive = true
        bookMarks_segmented_forHalfStatus.topAnchor.constraint(equalTo: bulletinBoardTempContainer.topAnchor, constant: 26).isActive = true
        bookMarks_segmented_forHalfStatus.widthAnchor.constraint(equalToConstant: CGFloat(80 * bookMarks.count)).isActive = true
        bookMarks_segmented_forHalfStatus.heightAnchor.constraint(equalToConstant: 30).isActive = true
        bookMarks_segmented_forHalfStatus.addTarget(self, action: #selector(segmentedOnValueChanged_half), for: .valueChanged)
        
        //做出未滑開時的照片與小itemTableView
        let photoTableViewContainer = UIView()
        photoTableViewContainer.frame = CGRect(x: 0, y: 64, width: view.frame.width, height: 96)
        let smallItemTableViewContainer = UIView()
        smallItemTableViewContainer.frame = CGRect(x: 0, y: 160, width: view.frame.width, height: bulletinBoardTempContainer.frame.height - (36 + 96 - 5.3))
        
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
        mediumSizeHeadShot.frame = CGRect(x: 17, y: 70, width: 60, height: 60)
        mediumSizeHeadShot.layer.cornerRadius = 30
        mediumSizeHeadShot.clipsToBounds = true
        let loadingView = UIImageView(frame: CGRect(x: mediumSizeHeadShot.frame.minX + mediumSizeHeadShot.frame.width * 1/12, y: mediumSizeHeadShot.frame.minY + mediumSizeHeadShot.frame.height * 1/12, width: mediumSizeHeadShot.frame.width * 5/6, height: mediumSizeHeadShot.frame.height * 5/6))
        loadingView.contentMode = .scaleAspectFit
        if personInfo.gender == 0{
            loadingView.image = UIImage(named: "girlIcon")?.withRenderingMode(.alwaysTemplate)
        }else{
            loadingView.image = UIImage(named: "boyIcon")?.withRenderingMode(.alwaysTemplate)
        }
        loadingView.tintColor = UIColor.lightGray
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
        nameLabel.textColor = .on()
        nameLabel.text = personInfo.name
        nameLabel.frame = CGRect(x: 92, y: 75, width: nameLabel.intrinsicContentSize.width, height: nameLabel.intrinsicContentSize.height)
        bulletinBoard_ProfilePart.addSubview(nameLabel)
        
        //年齡
        let ageLabel = UILabel()
        ageLabel.font = UIFont(name: "HelveticaNeue", size: 18)
        ageLabel.textColor = .on()
        let birthdayFormatter = DateFormatter()
        birthdayFormatter.dateFormat = "yyyy/MM/dd"
        let currentTime = Date()
        let birthDayDate = birthdayFormatter.date(from: personInfo.birthday)
        let age = currentTime.years(sinceDate: birthDayDate!) ?? 0
        if age != 0 {
            ageLabel.text = "\(age)"
        }
        ageLabel.frame = CGRect(x: 92 + nameLabel.intrinsicContentSize.width + 4, y: 75, width: nameLabel.intrinsicContentSize.width, height: ageLabel.intrinsicContentSize.height)
        bulletinBoard_ProfilePart.addSubview(ageLabel)
        
        //登入時間與icon
        let signInTimeIconImageView = UIImageView()
        let signInTimeIcon = UIImage(named: "GreenCircle")?.withRenderingMode(.alwaysTemplate)
        signInTimeIconImageView.image = signInTimeIcon
        signInTimeIconImageView.frame = CGRect(x: 92, y: 106.5, width: 14, height: 14)
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
        signInTimeLabel.font = UIFont(name: "HelveticaNeue", size: 12)
        signInTimeLabel.textColor = .on()
        signInTimeLabel.text = finalTimeString
        signInTimeLabel.frame = CGRect(x: 113, y: 107, width: signInTimeLabel.intrinsicContentSize.width, height: signInTimeLabel.intrinsicContentSize.height)
        bulletinBoard_ProfilePart.addSubview(signInTimeLabel)
        
        
        let selfIntroductionLabel = UILabel()
        selfIntroductionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        selfIntroductionLabel.textColor = .on()
        selfIntroductionLabel.text = personInfo.selfIntroduction
        selfIntroductionLabel.numberOfLines = 0
        selfIntroductionLabel.textAlignment = .left
        selfIntroductionLabel.frame = CGRect(x: 16, y: 138, width: view.frame.width - 32, height: 82)
        bulletinBoard_ProfilePart.addSubview(selfIntroductionLabel)
        selfIntroductionLabel.sizeToFit()
        //66.4是四行的高度 如果超過四行，就縮小
        if selfIntroductionLabel.frame.height > 82{
            selfIntroductionLabel.frame = CGRect(x: 16, y: 138, width: view.frame.width - 32, height: 82)
        }
        
        //點擊照片或是自我介紹，前往PhotoProfileView
        let gotoPhotoProfileViewBtn = { () -> UIButton in
            let btn = UIButton()
            btn.frame = CGRect(x: 0, y: 70, width: view.frame.width - 28 - 21, height: 150)
            btn.addTarget(self, action: #selector(gotoPhotoProfileViewBtnAct), for: .touchUpInside)
            return btn
        }()
        bulletinBoard_ProfilePart.addSubview(gotoPhotoProfileViewBtn)
        
        
        bulletinBoard_ProfilePart_plzSlideUp = UIView()
        bulletinBoard_ProfilePart_plzSlideUp.frame = CGRect(x: 0, y: 0, width: bulletinBoard_ProfilePart.frame.width, height: 100)
        bulletinBoard_ProfilePart.addSubview(bulletinBoard_ProfilePart_plzSlideUp)
        
        let remainingTimeLabel = { () -> UILabel in
            let label = UILabel()
            label.text = "距離下架時間  99：99：99"
            label.textColor = .on().withAlphaComponent(0.7)
            label.font = UIFont(name: "HelveticaNeue", size: 13)
            label.frame = CGRect(x: bulletinBoard_ProfilePart_plzSlideUp.frame.width - 18 - label.intrinsicContentSize.width - 10, y: 106, width: label.intrinsicContentSize.width + 10, height: label.intrinsicContentSize.height)
            label.text = ""
            label.textAlignment = .right
            return label
        }()
        bulletinBoard_ProfilePart.addSubview(remainingTimeLabel)
        startRemainingStoreOpenTimer(lebal: remainingTimeLabel, storeOpenTimeString: openTimeString, durationOfAuction: 60 * 60 * 24 * 7)
        
        let plzSlideUpImageView = {() -> UIImageView in
            let imageView = UIImageView(frame: CGRect(x: self.bulletinBoard_ProfilePart_plzSlideUp.frame.width/2 - 19/2, y: 245, width: 19, height: 19))
            imageView.image = UIImage(named: "plzSlideUp")?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = .primary()
            return imageView
        }()
        bulletinBoard_ProfilePart_plzSlideUp.addSubview(plzSlideUpImageView)
        
        
        let plzSlideUpLabel = { () -> UILabel in
            let label = UILabel()
            label.text = "上滑展開攤販詳細資訊"
            label.textColor = .primary()
            label.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
            label.frame = CGRect(x: bulletinBoard_ProfilePart_plzSlideUp.frame.width/2 - label.intrinsicContentSize.width/2, y: plzSlideUpImageView.frame.maxY + 6, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            return label
        }()
        bulletinBoard_ProfilePart_plzSlideUp.addSubview(plzSlideUpLabel)
        
        UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .autoreverse], animations: {
            plzSlideUpImageView.frame.origin.y -= 8
        }, completion: nil)
        
        bulletinBoard_ProfilePart_Bottom = UIView()
        bulletinBoard_ProfilePart_Bottom.frame = CGRect(x: 0, y: 0, width: bulletinBoard_ProfilePart.frame.width, height: bulletinBoard_ProfilePart.frame.height)
        bulletinBoard_ProfilePart.addSubview(bulletinBoard_ProfilePart_Bottom)
        
        //點擊照片或是自我介紹，前往PhotoProfileView
        let gotoPhotoProfileViewBtn_Bottom = { () -> UIButton in
            let btn = UIButton()
            btn.frame = CGRect(x: 0, y: 47, width: view.frame.width - 21 - 28, height: 120)
            btn.addTarget(self, action: #selector(gotoPhotoProfileViewBtnAct), for: .touchUpInside)
            return btn
        }()
        bulletinBoard_ProfilePart_Bottom.addSubview(gotoPhotoProfileViewBtn_Bottom)
        
        let storeNameLabel = {() -> UILabel in
            let label = UILabel()
            label.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
            label.text = storeName
            label.textColor = .on().withAlphaComponent(0.7)
            label.frame = CGRect(x: 17, y: 28, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            
            return label
        }()
        bulletinBoard_ProfilePart_Bottom.addSubview(storeNameLabel)
        
        let dot = {() -> UIView in
            let view = UIView()
            view.frame = CGRect(x: storeNameLabel.frame.maxX + 8, y: storeNameLabel.frame.minY + 5, width: 4, height: 4)
            view.layer.cornerRadius = 2
            view.backgroundColor = .on().withAlphaComponent(0.7)
            return view
        }()
        bulletinBoard_ProfilePart_Bottom.addSubview(dot)
        
        let distanceLabel = {() -> UILabel in
            let label = UILabel()
            label.font = UIFont(name: "HelveticaNeue", size: 14)
            var distanceDouble = Double(distance)
            if distanceDouble >= 1000{
                distanceDouble = distanceDouble/1000
                distanceDouble = Double(Int(distanceDouble * 10))/10
                label.text = "\(distanceDouble)" + "km"
            }else{
                label.text = "\(Int(distanceDouble))" + "m"
            }
            label.textColor = .on().withAlphaComponent(0.7)
            label.frame = CGRect(x: dot.frame.maxX + 8, y: storeNameLabel.frame.minY, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            return label
        }()
        bulletinBoard_ProfilePart_Bottom.addSubview(distanceLabel)
        
        if UserSetting.UID != UID{
            let mailBtn = MailButton(personInfo: personInfo)
            mailBtn.frame = CGRect(x: bulletinBoard_ProfilePart.frame.width - 21 - 28, y: 72, width: 28, height: 28)
            //            mailBtn.addTarget(self, action: #selector(gotoPhotoProfileViewBtnAct), for: .touchUpInside)
            bulletinBoard_ProfilePart.addSubview(mailBtn)
        }
        
        
        var bookMarks_temp = bookMarks
        bookMarks_temp.remove(at: 0)
        
        //做出書頁標籤
        bookMarks_segmented_forFullStatus = SSSegmentedControl(items: bookMarks_temp,type: .pure)
        bookMarks_segmented_forFullStatus.translatesAutoresizingMaskIntoConstraints = false
        bookMarks_segmented_forFullStatus.selectedSegmentIndex = 0
        bulletinBoard_ProfilePart_Bottom.addSubview(        bookMarks_segmented_forFullStatus)
        bookMarks_segmented_forFullStatus.centerXAnchor.constraint(equalTo: bulletinBoardTempContainer.centerXAnchor).isActive = true
        bookMarks_segmented_forFullStatus.topAnchor.constraint(equalTo: bulletinBoardTempContainer.topAnchor, constant: 220).isActive = true
        bookMarks_segmented_forFullStatus.widthAnchor.constraint(equalToConstant: CGFloat(80 * bookMarks_temp.count)).isActive = true
        bookMarks_segmented_forFullStatus.heightAnchor.constraint(equalToConstant: 30).isActive = true
        bookMarks_segmented_forFullStatus.addTarget(self, action: #selector(segmentedOnValueChanged_half), for: .valueChanged)
        
        
        let bigItemTableViewContainer = UIView()
        bigItemTableViewContainer.frame = CGRect(x: 0, y: 44 + 240 - 30, width: view.frame.width, height: bulletinBoard_ProfilePart_Bottom.frame.height - 44 - 240 + 30)
        
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
        
        tableViewRefreshControl = UIRefreshControl()
        bigItemTableView.addSubview(tableViewRefreshControl)
        tableViewRefreshControl.addTarget(self, action: #selector(useRefreshControlToSwipeDown), for: .valueChanged)
        tableViewRefreshControl.tintColor = .clear
        
        bulletinBoard_ProfilePart_Bottom.isHidden = true
        bulletinBoard_ProfilePart.isHidden = true
        
        
        bookMarks_segmented_forFullStatus.selectedSegmentIndex = bookMarks_temp.index(of: selectedbookMark) ?? 0
        bookMarks_segmented_forHalfStatus.selectedSegmentIndex = bookMarks.index(of: selectedbookMark) ?? 0
        
        if selectedbookMark == bookMarkName_Sell{
            bookMarkAct_OpenStore()
        }else if selectedbookMark == bookMarkName_Buy{
            bookMarkAct_Request()
        }else if selectedbookMark == bookMarkName_TeamUp{
            bookMarkAct_TeamUp()
        }else if selectedbookMark == bookMarkName_MakeFriend{
            bookMarkAct_Profile()
        }
        
        
        
    }
    func startRemainingStoreOpenTimer(lebal:UILabel,storeOpenTimeString:String,durationOfAuction:Int){
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYYMMddHHmmss"
        
        print("storeOpenTimeString:" + "\(storeOpenTimeString)")
        
        storeRemainingTimeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in
            
            if formatter.date(from: storeOpenTimeString) != nil{
                let seconds = Date().seconds(sinceDate: formatter.date(from: storeOpenTimeString)!)
                
                
                let remainingHour = (durationOfAuction - seconds!) / (60 * 60)
                let remainingMin = ((durationOfAuction - seconds!) % (60 * 60)) / 60
                let remainingSecond = ((durationOfAuction - seconds!) % (60 * 60)) % 60
                let remainingTime = "距離下架時間  " + "\(remainingHour)" + " : " + "\(remainingMin)" + " : " + "\(remainingSecond)"
                
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
        tableViewRefreshControl.endRefreshing()
        
        smallItemTableView.reloadData()
        
        let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        animateBulletinBoard(targetPosition: view.frame.height - 300 - bottomPadding) { (_) in
            self.bulletinBoardExpansionState = .PartiallyExpanded
        }
        
        
        switch currentBulletinBoard {
        case .Profile:
            bookMarks_segmented_forHalfStatus.selectedSegmentIndex = bookMarks_half.firstIndex(of: bookMarkName_MakeFriend) ?? 0
            fadeInProfileBoard()
            break
        case .Buy:
            bookMarks_segmented_forHalfStatus.selectedSegmentIndex = bookMarks_half.firstIndex(of: bookMarkName_Buy) ?? 0
            fadeInBuySellBoard()
            break
        case .Sell:
            bookMarks_segmented_forHalfStatus.selectedSegmentIndex = bookMarks_half.firstIndex(of: bookMarkName_Sell) ?? 0
            fadeInBuySellBoard()
            break
        case .TeamUp:
            bookMarks_segmented_forHalfStatus.selectedSegmentIndex = bookMarks_half.firstIndex(of: bookMarkName_TeamUp) ?? 0
            fadeInTeamUpBoard()
            break
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.bulletinBoard_ProfilePart_plzSlideUp.alpha = 1
            self.bulletinBoard_ProfilePart_Bottom.alpha = 0
            self.bookMarks_segmented_forHalfStatus.isHidden = false
            self.bookMarks_segmented_forHalfStatus.alpha = 1
        }, completion: { _ in
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
        
        exclamationPopUpContainerView.frame = CGRect(x: view.frame.width - 50 - 277.5, y: 104 + statusHeight, width:277.5, height: 123)
        exclamationPopUpBGButton.addSubview(exclamationPopUpContainerView)
        exclamationPopUpBGButton.addTarget(self, action: #selector(exclamationPopUpBGBtnAct), for: .touchUpInside)
        
        let exclamationPopUpImage = UIImage(named: "驚嘆號彈出方框")?.withRenderingMode(.alwaysTemplate)
        let exclamationPopUpImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: exclamationPopUpContainerView.frame.width, height: exclamationPopUpContainerView.frame.height))
        exclamationPopUpImageView.image = exclamationPopUpImage
        exclamationPopUpImageView.tintColor = .white
        exclamationPopUpContainerView.addSubview(exclamationPopUpImageView)
        
        showOpenStoreButton.frame = CGRect(x: 6, y: 25, width: 44, height: 44)
        let openStoreImage = UIImage(named: "icons24ShopLocateFilledBk24")
        let openStoreImage_tintedImage = openStoreImage?.withRenderingMode(.alwaysTemplate)
        
        if UserSetting.isMapShowOpenStore{
            showOpenStoreButton.tintColor = smallIconActiveColor
        }else{
            showOpenStoreButton.tintColor = smallIconUnactiveColor
        }
        showOpenStoreButton.setImage(openStoreImage_tintedImage, for: .normal)
        showOpenStoreButton.isEnabled = true
        showOpenStoreButton.addTarget(self, action: #selector(showOpenStoreBtnAct), for: .touchUpInside)
        
        exclamationPopUpContainerView.addSubview(showOpenStoreButton)
        
        showRequestButton.frame = CGRect(x: 65, y: 25, width: 44, height: 44)
        let requestImage = UIImage(named: "icons24ShopNeedWt24")
        let requestImage_tintedImage = requestImage?.withRenderingMode(.alwaysTemplate)
        if UserSetting.isMapShowRequest{
            showRequestButton.tintColor = smallIconActiveColor
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
            showTeamUpButton.tintColor = smallIconActiveColor
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
            showCoffeeShopButton.tintColor = smallIconActiveColor
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
            showBoyButton.tintColor = smallIconActiveColor
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
            showGirlButton.tintColor = smallIconActiveColor
        }else{
            showGirlButton.tintColor = smallIconUnactiveColor
        }
        showGirlButton.setImage(showGirlImage_tintImage, for: .normal)
        showGirlButton.isEnabled = true
        showGirlButton.addTarget(self, action: #selector(showGirlBtnAct), for: .touchUpInside)
        exclamationPopUpContainerView.addSubview(showGirlButton)
        
        
        showSharedSeat2Button.frame = CGRect(x: 124, y: 25 + 44 + 6, width: 44, height: 44)
        let showSharedSeat2ButtonImg = UIImage(named: "兩人相席")
        let showSharedSeat2ButtonImg_tint = showSharedSeat2ButtonImg?.withRenderingMode(.alwaysTemplate)
        if UserSetting.isMapShowSharedSeat2{
            showSharedSeat2Button.tintColor = smallIconActiveColor
        }else{
            showSharedSeat2Button.tintColor = smallIconUnactiveColor
        }
        showSharedSeat2Button.setImage(showSharedSeat2ButtonImg_tint, for: .normal)
        showSharedSeat2Button.isEnabled = true
        showSharedSeat2Button.addTarget(self, action: #selector(showSharedSeat2BtnAct), for: .touchUpInside)
        exclamationPopUpContainerView.addSubview(showSharedSeat2Button)
        
        showSharedSeat4Button.frame = CGRect(x: 183, y: 25 + 44 + 6, width: 44, height: 44)
        let showSharedSeat4ButtonImg = UIImage(named: "四人相席")
        let showSharedSeat4ButtonImg_tint = showSharedSeat4ButtonImg?.withRenderingMode(.alwaysTemplate)
        if UserSetting.isMapShowSharedSeat4{
            showSharedSeat4Button.tintColor = smallIconActiveColor
        }else{
            showSharedSeat4Button.tintColor = smallIconUnactiveColor
        }
        showSharedSeat4Button.setImage(showSharedSeat4ButtonImg_tint, for: .normal)
        showSharedSeat4Button.isEnabled = true
        showSharedSeat4Button.addTarget(self, action: #selector(showSharedSeat4BtnAct), for: .touchUpInside)
        exclamationPopUpContainerView.addSubview(showSharedSeat4Button)
        
        
    }
    
    fileprivate func configMapButtons() {
        
        let window = UIApplication.shared.keyWindow
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0
        
        let circleButton_add: UIButton = UIButton()
        circleButton_add.setImage(UIImage(named: "icons24PlusFilledWt24"), for: .normal)
        circleButton_add.backgroundColor = .addColor(.black * 0.15, with: .primary() * 0.85)
        circleButton_add.addTarget(self, action: #selector(addBtnAct), for: .touchUpInside)
        circleButton_add.layer.cornerRadius = 26
        circleButton_add.layer.shadowRadius = 2
        circleButton_add.layer.shadowOffset = CGSize(width: 2, height: 2)
        circleButton_add.layer.shadowOpacity = 0.3
        view.addSubview(circleButton_add)
        circleButton_add.snp.makeConstraints { make in
            make.height.width.equalTo(52)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.snp.bottomMargin).offset(-36)
        }
        
        let accountButton = UIButton()
        accountButton.setImage(UIImage(named: "icons24AccountFilledGrey24"), for: .normal)
        accountButton.backgroundColor = .sksWhite()
        accountButton.layer.shadowRadius = 2
        accountButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        accountButton.layer.shadowOpacity = 0.3
        accountButton.layer.cornerRadius = 20
        view.addSubview(accountButton)
        accountButton.snp.makeConstraints { make in
            make.height.width.equalTo(40)
            make.centerY.equalTo(circleButton_add)
            make.right.equalTo(circleButton_add.snp.left).offset(-48)
        }
        accountButton.addTarget(self, action: #selector(accountBtnAct), for: .touchUpInside)
        
        let messageButton = UIButton()
        messageButton.setImage(UIImage(named: "icons24MessageFilledGrey24"), for: .normal)
        messageButton.backgroundColor = .sksWhite()
        messageButton.layer.shadowRadius = 2
        messageButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        messageButton.layer.shadowOpacity = 0.3
        messageButton.layer.cornerRadius = 20
        view.addSubview(messageButton)
        messageButton.snp.makeConstraints { make in
            make.height.width.equalTo(40)
            make.centerY.equalTo(circleButton_add)
            make.left.equalTo(circleButton_add.snp.right).offset(48)
        }
        messageButton.addTarget(self, action: #selector(messageBtnAct), for: .touchUpInside)
        
        
        unreadMsgCountCircle = UIButton()
        view.addSubview(unreadMsgCountCircle)
        unreadMsgCountCircle.snp.makeConstraints { make in
            make.height.width.equalTo(14)
            make.top.equalTo(messageButton)
            make.right.equalTo(messageButton.snp.right)
        }
        unreadMsgCountCircle.titleLabel?.font = unreadNotiCountCircle.titleLabel?.font.withSize(12)
        unreadMsgCountCircle.backgroundColor = .sksPink()
        unreadMsgCountCircle.layer.cornerRadius = 7
        unreadMsgCountCircle.setTitle("", for: .normal)
        unreadMsgCountCircle.isHidden = true
        unreadMsgCountCircle.isEnabled = false
        
        
#if VERYINCORRECT
        //相席遊戲規則說明按鈕
        let circleButton_explain = UIButton(frame:CGRect(x: 16, y: statusHeight + 50, width: 32, height: 32))
        circleButton_explain.backgroundColor = .sksWhite()
        let infoImage = UIImage(named: "bk_icon_info_20_n")?.withRenderingMode(.alwaysTemplate)
        circleButton_explain.tintColor = UIColor.hexStringToUIColor(hex: "#6D6D6D")
        circleButton_explain.layer.cornerRadius = 16
        circleButton_explain.layer.shadowRadius = 2
        circleButton_explain.layer.shadowOffset = CGSize(width: 2, height: 2)
        circleButton_explain.layer.shadowOpacity = 0.3
        circleButton_explain.setImage(infoImage, for: [])
        circleButton_explain.isEnabled = true
        view.addSubview(circleButton_explain)
        circleButton_explain.addTarget(self, action: #selector(explainBtnAct), for: .touchUpInside)
#endif
        
        
        
        let circleButton_exclamation = UIButton(frame:CGRect(x: view.frame.width - 16 - 32, y: statusHeight + 90, width: 32, height: 32))
        circleButton_exclamation.backgroundColor = .sksWhite()
        let exclamationImage = UIImage(named: "icons24FilterListBlack24Dp")
        circleButton_exclamation.layer.cornerRadius = 16
        circleButton_exclamation.layer.shadowRadius = 2
        circleButton_exclamation.layer.shadowOffset = CGSize(width: 2, height: 2)
        circleButton_exclamation.layer.shadowOpacity = 0.3
        circleButton_exclamation.setImage(exclamationImage, for: [])
        circleButton_exclamation.isEnabled = true
        view.addSubview(circleButton_exclamation)
        circleButton_exclamation.addTarget(self, action: #selector(exclamationBtnAct), for: .touchUpInside)
        
        
        let circleButton_reposition = UIButton(frame:CGRect(x: view.frame.width - 16 - 32, y: statusHeight + 90 + 32 + 16, width: 32, height: 32))
        circleButton_reposition.backgroundColor = .sksWhite()
        let repositionImage = UIImage(named: "icons24LocationGrey24")
        circleButton_reposition.layer.cornerRadius = 16
        circleButton_reposition.layer.shadowRadius = 2
        circleButton_reposition.layer.shadowOffset = CGSize(width: 2, height: 2)
        circleButton_reposition.layer.shadowOpacity = 0.3
        circleButton_reposition.setImage(repositionImage, for: [])
        circleButton_reposition.isEnabled = true
        view.addSubview(circleButton_reposition)
        circleButton_reposition.addTarget(self, action: #selector(repositionBtnAct), for: .touchUpInside)
        
        let circleButton_notification = UIButton(frame:CGRect(x: view.frame.width - 16 - 32, y: statusHeight + 90 + 64 + 32, width: 32, height: 32))
        circleButton_notification.backgroundColor = .sksWhite()
        let notificationImage = UIImage(named: "icons24NotificationFilledGrey24")
        circleButton_notification.layer.cornerRadius = 16
        circleButton_notification.layer.shadowRadius = 2
        circleButton_notification.layer.shadowOffset = CGSize(width: 2, height: 2)
        circleButton_notification.layer.shadowOpacity = 0.3
        circleButton_notification.setImage(notificationImage, for: [])
        circleButton_notification.isEnabled = true
        view.addSubview(circleButton_notification)
        circleButton_notification.addTarget(self, action: #selector(notificationBtnAct), for: .touchUpInside)
        
        unreadNotiCountCircle = UIButton(frame:CGRect(x: view.frame.width - 16 - 8, y: statusHeight + 90 + 64 + 32, width: 14, height: 14))
        unreadNotiCountCircle.titleLabel?.font = unreadNotiCountCircle.titleLabel?.font.withSize(12)
        unreadNotiCountCircle.backgroundColor = .sksPink()
        unreadNotiCountCircle.layer.cornerRadius = 7
        unreadNotiCountCircle.setTitle("", for: .normal)
        unreadNotiCountCircle.isHidden = true
        unreadNotiCountCircle.isEnabled = false
        view.addSubview(unreadNotiCountCircle)
        
        circleButton_mySharedSeat = UIButton(frame:CGRect(x: view.frame.width - 16 - 32, y: statusHeight + 90 + 96 + 48, width: 32, height: 32))
        circleButton_mySharedSeat.backgroundColor = .primary()
        let mySharedSeatImage = UIImage(named: "兩人相席")?.withRenderingMode(.alwaysTemplate)
        circleButton_mySharedSeat.layer.cornerRadius = 16
        circleButton_mySharedSeat.layer.shadowRadius = 2
        circleButton_mySharedSeat.layer.shadowOffset = CGSize(width: 2, height: 2)
        circleButton_mySharedSeat.layer.shadowOpacity = 0.3
        circleButton_mySharedSeat.setImage(mySharedSeatImage, for: [])
        circleButton_mySharedSeat.tintColor = .sksWhite()
        circleButton_mySharedSeat.isEnabled = true
        circleButton_mySharedSeat.isHidden = true
        view.addSubview(circleButton_mySharedSeat)
        circleButton_mySharedSeat.addTarget(self, action: #selector(mySharedSeatBtnAct), for: .touchUpInside)
        
        unreadMySharedSeatNotiCountCircle = UIButton(frame:CGRect(x: view.frame.width - 16 - 8, y: statusHeight + 90 + 96 + 48, width: 14, height: 14))
        unreadMySharedSeatNotiCountCircle.titleLabel?.font = unreadMySharedSeatNotiCountCircle.titleLabel?.font.withSize(12)
        unreadMySharedSeatNotiCountCircle.backgroundColor = .sksPink()
        unreadMySharedSeatNotiCountCircle.layer.cornerRadius = 7
        unreadMySharedSeatNotiCountCircle.setTitle("", for: .normal)
        unreadMySharedSeatNotiCountCircle.isHidden = true
        unreadMySharedSeatNotiCountCircle.isEnabled = false
        view.addSubview(unreadMySharedSeatNotiCountCircle)
        
    }
    
    func checkIsOpenTimeOrNot(business_hours:Business_hours?) -> Bool{
        
        let calendar:Calendar = Calendar(identifier: .gregorian)
        var comps:DateComponents = DateComponents()
        comps = calendar.dateComponents([.weekday,.hour,.minute], from: Date())
        let currentHour = comps.hour!
        let currentMinute = comps.minute!
        let weekDay = comps.weekday! - 1
        
        var open : String?
        var close : String?
        if(weekDay == 0){
            open = business_hours?.sunday.open
            close = business_hours?.sunday.close
        }else if(weekDay == 1){
            open = business_hours?.monday.open
            close = business_hours?.monday.close
        }else if(weekDay == 2){
            open = business_hours?.tuesday.open
            close = business_hours?.tuesday.close
        }else if(weekDay == 3){
            open = business_hours?.wednesday.open
            close = business_hours?.wednesday.close
        }else if(weekDay == 4){
            open = business_hours?.thursday.open
            close = business_hours?.thursday.close
        }else if(weekDay == 5){
            open = business_hours?.friday.open
            close = business_hours?.friday.close
        }else if(weekDay == 6){
            open = business_hours?.saturday.open
            close = business_hours?.saturday.close
        }
        if(open == nil || close == nil){
            return false
        }
        if(open == "00:00" && close == "00:00"){
            return true
        }
        var open_hour  = Int(open!.components(separatedBy: ":").first ?? "0") ?? 0
        var close_hour = Int(close!.components(separatedBy: ":").first ?? "0") ?? 0
        
        if(close_hour < 6){
            close_hour += 24
        }
        
        if(currentHour < open_hour){
            return false
        }else if(currentHour == open_hour){
            var open_min  = Int(open!.components(separatedBy: ":").last ?? "0") ?? 0
            if(currentMinute < open_min){
                return false
            }
        }
        
        if(currentHour > close_hour){
            return false
        }else if(currentHour == close_hour){
            var close_min = Int(close!.components(separatedBy: ":").last ?? "0") ?? 0
            if(currentMinute > close_min){
                return false
            }
        }
        
        return true
    }
    
    fileprivate func configureMapView() {
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.userTrackingMode = .follow
        mapView.showsPointsOfInterest = false
        mapView.tintColor = .primary() //這裡決定的是user那個點的顏色
        
        view.addSubview(mapView)
        mapView.addConstraintsToFillView(view: view)
    }
    
    func setUnreadMsgCount(_ count:Int){
        unreadMsgCount = count
        print("unreadMsgCount:" + "\(unreadMsgCount)")
        
        if(unreadMsgCount > 0){
            unreadMsgCountCircle.isHidden = false
            unreadMsgCountCircle.titleLabel?.font = unreadMsgCountCircle.titleLabel?.font.withSize(12)
            unreadMsgCountCircle.setTitle("\(unreadMsgCount)", for: .normal)
            if(unreadMsgCount > 9){
                unreadMsgCountCircle.titleLabel?.font = unreadMsgCountCircle.titleLabel?.font.withSize(8)
                unreadMsgCountCircle.setTitle("\(unreadMsgCount)", for: .normal)
            }
            if(unreadMsgCount > 99){
                unreadMsgCountCircle.titleLabel?.font = unreadMsgCountCircle.titleLabel?.font.withSize(8)
                unreadMsgCountCircle.setTitle("99", for: .normal)
            }
        }else{
            unreadMsgCountCircle.isHidden = true
        }
    }
    
    func setUnreadNotifcationCount(_ count:Int){
        unreadNotifcationCount = count
        print("unreadNotifcationCount:" + "\(unreadNotifcationCount)")
        
        
        if(unreadNotifcationCount > 0){
            unreadNotiCountCircle.isHidden = false
            unreadNotiCountCircle.titleLabel?.font = unreadNotiCountCircle.titleLabel?.font.withSize(12)
            unreadNotiCountCircle.setTitle("\(unreadNotifcationCount)", for: .normal)
            if(unreadNotifcationCount > 9){
                unreadNotiCountCircle.titleLabel?.font = unreadNotiCountCircle.titleLabel?.font.withSize(8)
                unreadNotiCountCircle.setTitle("\(unreadNotifcationCount)", for: .normal)
            }
            if(unreadNotifcationCount > 99){
                unreadNotiCountCircle.titleLabel?.font = unreadNotiCountCircle.titleLabel?.font.withSize(8)
                unreadNotiCountCircle.setTitle("99", for: .normal)
            }
        }else{
            unreadNotiCountCircle.isHidden = true
        }
        
    }
    
    func addMySharedSeatAnnotation(annotation : SharedSeatAnnotation){
        if(annotation.mode == 1){
            sharedSeatAnnotationGetter.sharedSeat2Annotation.append(annotation)
        }else if(annotation.mode > 1){
            sharedSeatAnnotationGetter.sharedSeat4Annotation.append(annotation)
        }
        sharedSeatAnnotationGetter.sharedSeatMyJoinedAnnotation.append(annotation)
        
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)
    }
    
    
    @objc private func accountBtnAct(){
        Analytics.logEvent("地圖_帳號按鈕", parameters:nil)
        ProfilePop.share.popAlert()
        
    }
    
    @objc private func messageBtnAct(){
        Analytics.logEvent("地圖_訊息按鈕", parameters:nil)
        CoordinatorAndControllerInstanceHelper.rootCoordinator.rootTabBarController.selectedViewController = CoordinatorAndControllerInstanceHelper.rootCoordinator.mailTab
    }
    
    @objc private func notificationBtnAct(){
        Analytics.logEvent("地圖_通知按鈕", parameters:nil)
        CoordinatorAndControllerInstanceHelper.rootCoordinator.rootTabBarController.selectedViewController = CoordinatorAndControllerInstanceHelper.rootCoordinator.notifyTab
    }
    
    @objc private func repositionBtnAct(){
        Analytics.logEvent("地圖_再定位按鈕", parameters:nil)
        enableLocationServices()
        centerMapOnUserLocation(shouldLoadAnnotations: false)
    }
    
    @objc private func mySharedSeatBtnAct(){
        Analytics.logEvent("地圖_我的相席按鈕", parameters:nil)
        
        if(sharedSeatAnnotationGetter!.sharedSeatMyJoinedAnnotation.count > 1){
            viewDelegate?.showListLocationViewController(sharedSeatAnnotations:sharedSeatAnnotationGetter!.sharedSeatMyJoinedAnnotation)
        }else{
            if(sharedSeatAnnotationGetter!.sharedSeatMyJoinedAnnotation.count > 0){
                //
                mapView.selectAnnotation(sharedSeatAnnotationGetter!.sharedSeatMyJoinedAnnotation[0], animated: true)
            }
        }
    }
    
    @objc private func explainBtnAct(){
        Analytics.logEvent("地圖_規則說明按鈕", parameters:nil)
        
        UserSetting.isShowedExplain = true
        
        let privacyViewController = (InfoPopOverController.initFromStoryboard() as InfoPopOverController)
        privacyViewController.titleString = "遊戲規則"
        privacyViewController.contentString = " 1.男方付錢，無論主辦者是男是女。\n\n 2.女生舉辦聚會時，可從所有報名者裡主動挑選參加者。\n\n 3.男生舉辦聚會時，將由系統從所有報名者裡隨機骰出參加者，可重新骰三次。\n\n 4.當挑選出參加者後，會開啟聊天室，同時聚會將無法取消。\n\n 5.聚會結束後，可以互相評分。 \n\n 6.評分將影響『被骰出當參加者』的機率，過低的評分鎖帳號。"
        privacyViewController.modalPresentationStyle = .popover
        present(privacyViewController, animated: true, completion: nil)
    }
    
    @objc private func exclamationBtnAct(){
        Analytics.logEvent("地圖_漏斗按鈕", parameters:nil)
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
            showOpenStoreButton.tintColor = smallIconActiveColor
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
            showRequestButton.tintColor = smallIconActiveColor
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
            showTeamUpButton.tintColor = smallIconActiveColor
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
            showCoffeeShopButton.tintColor = smallIconActiveColor
            mapView.addAnnotations(coffeeAnnotationGetter.coffeeAnnotations)
        }
    }
    @objc private func showBoyBtnAct(){
        if UserSetting.isMapShowMakeFriend_Boy{
            UserSetting.isMapShowMakeFriend_Boy = false
            showBoyButton.tintColor = smallIconUnactiveColor
        }else{
            UserSetting.isMapShowMakeFriend_Boy = true
            showBoyButton.tintColor = smallIconActiveColor
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
            showGirlButton.tintColor = smallIconActiveColor
        }
        mapView.removeAnnotations(presonAnnotationGetter.girlSayHiAnnotations)
        mapView.addAnnotations(presonAnnotationGetter.decideCanShowOrNotAndWhichIcon(presonAnnotationGetter.girlSayHiAnnotations))
    }
    
    @objc private func showSharedSeat2BtnAct(){
        if UserSetting.isMapShowSharedSeat2{
            UserSetting.isMapShowSharedSeat2 = false
            showSharedSeat2Button.tintColor = smallIconUnactiveColor
            mapView.removeAnnotations(sharedSeatAnnotationGetter.sharedSeat2Annotation)
        }else{
            UserSetting.isMapShowSharedSeat2 = true
            showSharedSeat2Button.tintColor = smallIconActiveColor
            mapView.addAnnotations(sharedSeatAnnotationGetter.sharedSeat2Annotation)
        }
    }
    
    
    @objc private func showSharedSeat4BtnAct(){
        print("showSharedSeat4BtnAct")
        if UserSetting.isMapShowSharedSeat4{
            UserSetting.isMapShowSharedSeat4 = false
            showSharedSeat4Button.tintColor = smallIconUnactiveColor
            mapView.removeAnnotations(sharedSeatAnnotationGetter.sharedSeat4Annotation)
        }else{
            UserSetting.isMapShowSharedSeat4 = true
            showSharedSeat4Button.tintColor = smallIconActiveColor
            mapView.addAnnotations(sharedSeatAnnotationGetter.sharedSeat4Annotation)
        }
    }
    
    
    @objc private func exclamationPopUpBGBtnAct(){
        exclamationPopUpBGButton.isHidden = true
    }
    
    @objc private func bookMarkAct_OpenStore(){
        currentBulletinBoard = .Sell
        refreshTableViewsContent(.Sell)
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
                self.bulletinBoard_SharedSeat.alpha = 0
            }, completion:  { _ in
                self.bulletinBoard_ProfilePart.isHidden = true
                self.bulletinBoard_TeamUpPart.isHidden = true
                self.bulletinBoard_CoffeeShop.isHidden = true
                self.bulletinBoard_SharedSeat.isHidden = true
                self.bulletinBoard_ProfilePart.alpha = 1
                self.bulletinBoard_TeamUpPart.alpha = 1
                self.bulletinBoard_CoffeeShop.alpha = 1
                self.bulletinBoard_SharedSeat.alpha = 1
            })
        }
    }
    
    @objc private func bookMarkAct_Request(){
        currentBulletinBoard = .Buy
        refreshTableViewsContent(.Buy)
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
        currentBulletinBoard = .TeamUp
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
                self.bulletinBoard_SharedSeat.alpha = 0
            }, completion:  { _ in
                self.bulletinBoard_TeamUpPart.isHidden = true
                self.bulletinBoard_BuySellPart.isHidden = true
                self.bulletinBoard_CoffeeShop.isHidden = true
                self.bulletinBoard_SharedSeat.isHidden = true
                self.bulletinBoard_TeamUpPart.alpha = 1
                self.bulletinBoard_BuySellPart.alpha = 1
                self.bulletinBoard_CoffeeShop.alpha = 1
                self.bulletinBoard_SharedSeat.alpha = 1
            })
        }
    }
    
    @objc private func bookMarkAct_Profile(){
        currentBulletinBoard = .Profile
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
    
    @objc private func bookMarkAct_OpenStore_FullExpand(){
        currentBulletinBoard = .Sell
        refreshTableViewsContent(.Sell)
    }
    @objc private func bookMarkAct_Request_FullExpand(){
        currentBulletinBoard = .Buy
        refreshTableViewsContent(.Buy)
        
    }
    @objc private func bookMarkAct_TeamUp_FullExpand(){
        currentBulletinBoard = .TeamUp
    }
    
    
    
    @objc private func attentionBtnAct(_ btn: UIButton){
        Analytics.logEvent("地圖_咖啡_加入關注", parameters:nil)
        
        var attentionCafe = UserSetting.attentionCafe
        
        if(!attentionCafe.contains(currentCoffeeAnnotation!.address)){
            attentionCafe.append(currentCoffeeAnnotation!.address)
            btn.setImage(UIImage(named: "實愛心")?.withRenderingMode(.alwaysTemplate), for: .normal)
            loveShopLabel.text = "愛店：" + "\(currentCoffeeAnnotation!.favorites + 1)" + "人"
        }else{
            if(attentionCafe.firstIndex(of: currentCoffeeAnnotation!.address) != nil){
                attentionCafe.remove(at: attentionCafe.firstIndex(of: currentCoffeeAnnotation!.address)!)
            }
            btn.setImage(UIImage(named: "loveIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
            loveShopLabel.text = "愛店：" + "\(currentCoffeeAnnotation!.favorites)" + "人"
            
        }
        
        UserSetting.attentionCafe = attentionCafe
    }
    
    @objc private func scoreBtnAct(){
        Analytics.logEvent("地圖_咖啡_評分", parameters:nil)
        
        
        viewDelegate?.gotoScoreCoffeeController_mapView(annotation: currentCoffeeAnnotation!)
    }
    
    @objc private func fbBtnAct(){
        Analytics.logEvent("地圖_咖啡_前往FB", parameters:nil)
        UIApplication.shared.open(URL(string:coffeeShop_url)!, completionHandler: nil)
    }
    
    @objc private func addCoffeeBtnAct(){
        Analytics.logEvent("地圖_加號按鈕_新增咖啡店", parameters:nil)
        mapView.deselectAnnotation(mapView.userLocation, animated: true)
        view.endEditing(true)
        UIApplication.shared.open(URL(string:"https://cafenomad.tw/contribute")!, completionHandler: nil)
        
    }
    
    @objc private func iWantConcealBtnAct(){
        Analytics.logEvent("地圖_加號按鈕_取消", parameters:nil)
        mapView.deselectAnnotation(mapView.userLocation, animated: true)
        view.endEditing(true)
    }
    
    @objc private func iWantActionSheetContainerAct(){
        mapView.deselectAnnotation(mapView.userLocation, animated: true)
        iWantActionSheetKit.allBtnSlideOut()
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
        
        //上傳personAnnotation
        let currentTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMddHHmmss"
        let currentTimeString = dateFormatter.string(from: currentTime)
        
        if UserSetting.storeName == ""{
            UserSetting.storeName = bookMarkName_MakeFriend
        }
        UserSetting.isWantMakeFriend = true
        let myAnnotation = PersonAnnotationData(openTime: currentTimeString, title: UserSetting.storeName, gender: UserSetting.userGender, preferMarkType: UserSetting.perferIconStyleToShowInMap, wantMakeFriend: UserSetting.isWantMakeFriend, isOpenStore: UserSetting.isWantSellSomething, isRequest: UserSetting.isWantBuySomething, isTeamUp: UserSetting.isWantTeamUp, latitude: UserSetting.userLatitude, longitude: UserSetting.userLongitude)
        
        let ref = Database.database().reference()
        let personAnnotationWithIDRef = ref.child("PersonAnnotation/" +  UserSetting.UID)
        personAnnotationWithIDRef.setValue(myAnnotation.toAnyObject()){ (error, ref) -> Void in
            
            self.mapView.deselectAnnotation(self.mapView.userLocation, animated: true)
            loadingView.removeFromSuperview()
            self.iWantSayHiBtn.isEnabled = true
            self.presonAnnotationGetter.reFreshUserAnnotation()
            
            if error != nil{
                print(error ?? "上傳PersonAnnotation失敗")
            }
            
        }
    }
    
    @objc private func iWantOpenStoreBtnAct(){
        
        Analytics.logEvent("地圖_加號按鈕_擺攤", parameters:nil)
        
        viewDelegate?.gotoWantSellViewController_mapView(defaultItem:nil)
        mapView.deselectAnnotation(mapView.userLocation, animated: true)
    }
    
    @objc private func iWantRequestBtnAct(){
        
        Analytics.logEvent("地圖_加號按鈕_徵求物品", parameters:nil)
        
        viewDelegate?.gotoWantBuyViewController_mapView(defaultItem:nil)
        mapView.deselectAnnotation(mapView.userLocation, animated: true)
    }
    
    @objc private func iWantUseInvitationCode(){
        Analytics.logEvent("地圖_加號按鈕_使用邀請碼", parameters:nil)
        mapView.deselectAnnotation(mapView.userLocation, animated: true)
        
        if let infoEditAlertView = Bundle.main.loadNibNamed("InfoEditAlertView", owner: nil, options: nil)?.first as? InfoEditAlertView {
            infoEditAlertView.setColor()
            infoEditAlertView.translatesAutoresizingMaskIntoConstraints = false
            
            let popoverVC = SSPopoverViewController()
            popoverVC.tapToDismiss = false
            popoverVC.containerView.addSubview(infoEditAlertView)
            
            infoEditAlertView.topAnchor.constraint(equalTo: popoverVC.containerView.topAnchor).isActive = true
            infoEditAlertView.leadingAnchor.constraint(equalTo: popoverVC.containerView.leadingAnchor).isActive = true
            infoEditAlertView.trailingAnchor.constraint(equalTo: popoverVC.containerView.trailingAnchor).isActive = true
            infoEditAlertView.bottomAnchor.constraint(equalTo: popoverVC.containerView.bottomAnchor).isActive = true
            
            infoEditAlertView.inputTextField.keyboardType = .numberPad
            
            popoverVC.addAction(SSPopoverAction(title: "取消", style: .cancel, handler: { _ in
                popoverVC.dismiss(animated: true)
            }))
            
            popoverVC.addAction(SSPopoverAction(title: "確定", style: .default, handler: { [weak self] _ in
                if let text = infoEditAlertView.inputTextField.text {
                    if text.count > 6 || text.count == 0{
                        self?.checkFailed(infoEditAlertView.messageLabel)
                    }else{
                        self?.checkInvitationCode(text)
                        popoverVC.dismiss(animated: true)
                    }
                }
            }))
            
            present(popoverVC, animated: true) {
                infoEditAlertView.inputTextField.becomeFirstResponder()
            }
        }
        
    }
    
    func checkInvitationCode(_ code:String){
        let ref = Database.database().reference().child("InvitationCode/" + "\(code)")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists(){
                let split = (snapshot.value as! String).split(separator: "_")
                if(split.count == 5){
                    self.useInvitationCodeToJoinTeam(inviterID:String(split[0]),inviterName: String(split[1]),inviterGender:String(split[2]), annotationID: String(split[3]),annotationName:String(split[4]),invitationCode:code)
                }
            }else{
                self.showToast(message: "此為無效邀請碼", font: .systemFont(ofSize: 14.0))
            }
        })
    }
    
    func useInvitationCodeToJoinTeam(inviterID:String,inviterName:String,inviterGender:String,annotationID:String,annotationName:String,invitationCode:String){
        
        if(inviterID == UserSetting.UID){
            self.showToast(message: "請將邀請碼交給朋友而非自己使用", font: .systemFont(ofSize: 14.0))
            return
        }
        
        if inviterGender != String(UserSetting.userGender){
            if(inviterGender == "0"){
                self.showToast(message: "此邀請碼只能邀請女生", font: .systemFont(ofSize: 14.0))
            }else {
                self.showToast(message: "此邀請碼只能邀請男生", font: .systemFont(ofSize: 14.0))
            }
            return
        }
        
        let title : String
        let message : String
        let toastText : String
        if(inviterID == annotationID){
            title = "是否要參加聚會？"
            message = "確認後將與" + inviterName +  "組隊一同舉辦《" + annotationName + "》聚會"
            toastText = "成功參加聚會"
        }else{
            title = "是否要報名聚會？"
            message =
            "確認後將與" + inviterName + "一同報名《" + annotationName + "》聚會\n\n" +
            "報名將交由聚會舉辦人抽卡，若被抽出後，將無法取消參加。"
            toastText = "成功加入報名"
        }
        
        let alertVC = SSAlertController(title: title, message: message)
        alertVC.addAction(SSPopoverAction(title: "取消", style: .cancel, handler: { _ in
            alertVC.dismiss(animated: true)
        }))
        alertVC.addAction(SSPopoverAction(title: "確定", style: .default, handler: { [weak self] _ in
            alertVC.dismiss(animated: true)
            
            //TODO
            let genderNode : String
            if UserSetting.userGender == 0{
                if(inviterID == annotationID){
                    genderNode = "girlsID"
                }else{
                    genderNode = "signUpGirlsID"
                }
            }else{
                if(inviterID == annotationID){
                    genderNode = "boysID"
                }else{
                    genderNode = "signUpBoysID"
                }
            }
            
            let ref = Database.database().reference().child("SharedSeatAnnotation/" + annotationID + "/" +  genderNode + "/" + UserSetting.UID)
            
            ref.setValue(invitationCode + "#"){ (error, ref) -> Void in
                if error != nil{
                    print(error ?? "")
                    self!.showToast(message: "使用邀請碼失敗", font: .systemFont(ofSize: 14.0))
                }else{
                    self!.showToast(message: toastText, font: .systemFont(ofSize: 14.0))
                    let invitationCodeRef = Database.database().reference().child("InvitationCode/" + invitationCode)
                    invitationCodeRef.removeValue()
                    
                    
                    //調整邀請人那邊的資料，value加上#，代表有使用過邀請碼
                    let inviterIDRef = Database.database().reference().child("SharedSeatAnnotation/" + annotationID + "/" +  genderNode + "/" + inviterID)
                    inviterIDRef.setValue(invitationCode + "#")
                    
                    
                    //處理本地端資料
                    for annotation in self!.mapView.annotations {
                        if(annotation is SharedSeatAnnotation){
                            let sharedSeatAnnotation = (annotation as! SharedSeatAnnotation)
                            if(sharedSeatAnnotation.holderUID == annotationID){
                                if(UserSetting.userGender == 0){
                                    if(inviterID == annotationID){
                                        if(sharedSeatAnnotation.girlsID == nil){
                                            sharedSeatAnnotation.girlsID = [:]
                                        }
                                        sharedSeatAnnotation.girlsID![UserSetting.UID] = invitationCode
                                    }else{
                                        if(sharedSeatAnnotation.signUpGirlsID == nil){
                                            sharedSeatAnnotation.signUpGirlsID = [:]
                                        }
                                        sharedSeatAnnotation.signUpGirlsID![UserSetting.UID] = invitationCode + "#"
                                        sharedSeatAnnotation.signUpGirlsID![inviterID] = invitationCode + "#"
                                    }
                                }else{
                                    if(inviterID == annotationID){
                                        if(sharedSeatAnnotation.boysID == nil){
                                            sharedSeatAnnotation.boysID = [:]
                                        }
                                        sharedSeatAnnotation.boysID![UserSetting.UID] = invitationCode
                                    }else{
                                        if(sharedSeatAnnotation.signUpBoysID == nil){
                                            sharedSeatAnnotation.signUpBoysID = [:]
                                        }
                                        sharedSeatAnnotation.signUpBoysID![UserSetting.UID] = invitationCode + "#"
                                        sharedSeatAnnotation.signUpBoysID![inviterID] = invitationCode + "#"
                                    }
                                }
                                self!.sharedSeatAnnotationGetter.sharedSeatMyJoinedAnnotation.append(sharedSeatAnnotation)
                            }
                        }
                    }
                }
            }
        }))
        self.present(alertVC, animated: true)
        
    }
    
    func checkFailed(_ view: UIView) {
        if view is UILabel {
            let lbl = view as! UILabel
            lbl.textColor = .error
        }
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.toValue = 5
        animation.toValue = -5
        animation.autoreverses = true
        animation.duration = 0.05
        animation.repeatCount = 3
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        view.layer.add(animation, forKey: "topAnimation")
    }
    
    @objc private func iWantSharedSeatBtnAct(){
        Analytics.logEvent("地圖_加號按鈕_發起相席", parameters:nil)
        
        var isHolder = false
        for sharedSeatAnnotation in sharedSeatAnnotationGetter.sharedSeatMyJoinedAnnotation{
            if (sharedSeatAnnotation.holderUID == UserSetting.UID){
                isHolder = true
            }
        }
        
        mapView.deselectAnnotation(mapView.userLocation, animated: true)
        if(isHolder){
            showToast(message: "已是舉辦人，一人最多同時舉辦一個相席")
        }else{
            viewDelegate?.gotoHoldSharedSeatController_mapView()
        }
    }
    
    
    @objc private func iWantTeamUpBtnAct(){
        print("iWantTeamUpBtnAct")
    }
    
    
    @objc func cancelSharedSeatBtnAct(_ sender: UIButton){
        let alertVC = SSAlertController(title: "確定要取消聚會嗎?", message: "按下確認後將取消聚會")
        alertVC.addAction(SSPopoverAction(title: "再想想", style: .cancel, handler: { _ in
            alertVC.dismiss(animated: true)
        }))
        alertVC.addAction(SSPopoverAction(title: "確定", style: .default, handler: { [weak self] _ in
            alertVC.dismiss(animated: true)
            
            //遠端刪除
            let ref = Database.database().reference().child("SharedSeatAnnotation/" +  Auth.auth().currentUser!.uid)
            ref.removeValue(){
                (error, ref) -> Void in
                self!.showToast(message: "已取消聚會", font: .systemFont(ofSize: 14.0))
                //本地端刪除
                self!.mapView.removeAnnotation(self!.currentSharedSeatAnnotation!)
                if let index = self!.sharedSeatAnnotationGetter.sharedSeat2Annotation.firstIndex(of: self!.currentSharedSeatAnnotation!) {
                    self!.sharedSeatAnnotationGetter.sharedSeat2Annotation.remove(at: index)
                }
                if let index = self!.sharedSeatAnnotationGetter.sharedSeat4Annotation.firstIndex(of: self!.currentSharedSeatAnnotation!) {
                    self!.sharedSeatAnnotationGetter.sharedSeat4Annotation.remove(at: index)
                }
                if let index = self!.sharedSeatAnnotationGetter.sharedSeatMyJoinedAnnotation.firstIndex(of: self!.currentSharedSeatAnnotation!) {
                    self!.sharedSeatAnnotationGetter.sharedSeatMyJoinedAnnotation.remove(at: index)
                }
            }
        }))
        self.present(alertVC, animated: true)
    }
    
    @objc func goSharedSeatChatroomAct(){
        
        Analytics.logEvent("相席_前往相席聊天室", parameters:nil)
        print("相席_前往相席聊天室")
        if(currentSharedSeatAnnotation!.mode == 1){
            var joinedID = ""
            if(UserSetting.userGender == 0){
                for(UID,InvitationCode) in currentSharedSeatAnnotation!.boysID!{
                    joinedID = UID
                }
            }else{
                for(UID,InvitationCode) in currentSharedSeatAnnotation!.girlsID!{
                    joinedID = UID
                }
            }
            let sortedIDs = [UserSetting.UID,joinedID].sorted()
            let chatroomID = sortedIDs[0] + "-" + sortedIDs[1]
            
            let ref = Database.database().reference().child("PersonDetail/" + "\(joinedID)")
            ref.observeSingleEvent(of: .value, with: {(snapshot) in
                let personInfo = PersonDetailInfo(snapshot: snapshot)
                let rootCoordinator = CoordinatorAndControllerInstanceHelper.rootCoordinator
                rootCoordinator?.gotoOneToOneChatRoom(chatroomID: chatroomID, personInfo: personInfo, animated: false)
            })
            
            
        }else{
            //TODO
            
        }
        
        
    }
    
    
    @objc func signUpBtnAct() {
        
        Analytics.logEvent("相席_報名相席", parameters:nil)
//        if(){
//            ParticipantsViewController
//        }
        
        if(currentSharedSeatAnnotation!.holderUID == UserSetting.UID){
            
            if (signUpCountCircle.titleLabel?.text ?? "0" == "0"){
                showToast(message: "目前卡池中尚未有報名者")
            }else{
                viewDelegate?.gotoRegistrationList(sharedSeatAnnotation: currentSharedSeatAnnotation!)
            }
        }else{
            var message = "報名將交由聚會舉辦人抽卡，若被抽出後，將無法取消參加。"
            if(currentSharedSeatAnnotation!.mode == 2){
                message = "報名將交由聚會舉辦人抽卡，若被抽出後，將無法取消參加。 \n\n 注意：2對2模式，需要將邀請碼交給朋友，一同組隊報名（按地圖下方的＋號加入組隊），若在抽卡期限前朋友沒有使用邀請碼一同組隊加入卡池，則此次報名無效。"
            }
            
            let alertVC = SSAlertController(title: "確定要報名嗎?", message: message)
            alertVC.addAction(SSPopoverAction(title: "取消", style: .cancel, handler: { _ in
                alertVC.dismiss(animated: true)
            }))
            alertVC.addAction(SSPopoverAction(title: "確定", style: .default, handler: { [weak self] _ in
                
                if(self?.currentSharedSeatAnnotation!.mode == 1){
                    self?.signUpToCurrentSharedSeatAnnotation()
                }else{
                    self?.findValidInvitationCode()
                }
                
                
                alertVC.dismiss(animated: true)
            }))
            self.present(alertVC, animated: true)
        }
    }
    
    @objc func addressBtnAct(){
        Analytics.logEvent("相席_跳往google地圖", parameters:nil)
        
        let latitude = String(currentSharedSeatAnnotation!.coordinate.latitude as! Double)
        let longitude = String(currentSharedSeatAnnotation!.coordinate.longitude as! Double)
        
        let url = URL(string: "comgooglemaps://?saddr=&daddr=" + "\(latitude)" +  ","+"\(longitude)"+"&directionsmode=driving")
        let appleMapUrl = URL(string: "maps://?saddr=&daddr=\(latitude),\(longitude)")
        
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else
        if UIApplication.shared.canOpenURL(appleMapUrl!){
            
            UIApplication.shared.open(appleMapUrl!, options: [:], completionHandler: nil)
            
        }else{
            // 若手機沒安裝 Google Map App 則導到 App Store(id443904275 為 Google Map App 的 ID)
            let appStoreGoogleMapURL = URL(string: "itms-apps://itunes.apple.com/app/id585027354")!
            UIApplication.shared.open(appStoreGoogleMapURL, options: [:], completionHandler: nil)
        }
    }
    
    private func findValidInvitationCode(){
        let invitationCode = String(Int.random(in: 0...999999))
        let ref = Database.database().reference().child("InvitationCode/" + "\(invitationCode)")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists(){
                self.findValidInvitationCode()
            }else{
                let inviterID = UserSetting.UID
                let inviterName = UserSetting.userName
                let inviterGender = String(UserSetting.userGender)
                let annotationID = self.currentSharedSeatAnnotation!.holderUID
                let annotationName = self.currentSharedSeatAnnotation!.title!
                ref.setValue(inviterID + "_" + inviterName + "_" + inviterGender + "_" + annotationID + "_" + annotationName)
                
                self.signUpToCurrentSharedSeatAnnotation(invitationCode:invitationCode)
            }
        })
    }
    
    private func signUpToCurrentSharedSeatAnnotation(){
        signUpToCurrentSharedSeatAnnotation(invitationCode:"-")
    }
    
    private func signUpToCurrentSharedSeatAnnotation(invitationCode:String){
        
        if(self.currentSharedSeatAnnotation == nil){
            return
        }
        
        let gender : String
        if(UserSetting.userGender == 1){
            gender = "/signUpBoysID/"
        }else{
            gender = "/signUpGirlsID/"
        }
        
        let ref = Database.database().reference().child("SharedSeatAnnotation/" + currentSharedSeatAnnotation!.holderUID + gender + UserSetting.UID)
        
        ref.setValue(invitationCode){ (error, ref) -> Void in
            if error != nil{
                print(error ?? "報名失敗")
                self.showToast(message: "報名失敗", font: .systemFont(ofSize: 14.0))
            }else{
                self.showToast(message: "報名成功", font: .systemFont(ofSize: 14.0))
                
                self.changeSignUpBtnToCancelBtn()
                
                //處理本地端資料
                if(UserSetting.userGender == 0){
                    if(self.currentSharedSeatAnnotation!.signUpGirlsID == nil){
                        self.currentSharedSeatAnnotation!.signUpGirlsID = [:]
                    }
                    self.currentSharedSeatAnnotation!.signUpGirlsID![UserSetting.UID] = invitationCode
                }else{
                    if(self.currentSharedSeatAnnotation!.signUpBoysID == nil){
                        self.currentSharedSeatAnnotation!.signUpBoysID = [:]
                    }
                    self.currentSharedSeatAnnotation!.signUpBoysID![UserSetting.UID] = invitationCode
                }
                
                self.invitationCodeLabel.text = "邀請碼：" + invitationCode
            }
        }
        
    }
    
    
    
    
    @objc func cancelSignUpBtnAct(_ sender: UIButton){
        
        Analytics.logEvent("相席_取消報名相席", parameters:nil)
        
        var message = ""
        if(currentSharedSeatAnnotation!.mode == 2){
            message = "注意：若您的朋友已經與您組隊報名（使用邀請碼），取消報名將會將兩人的報名一併取消"
        }
        
        let alertVC = SSAlertController(title: "確定要取消報名嗎?", message: message)
        alertVC.addAction(SSPopoverAction(title: "再想想", style: .cancel, handler: { _ in
            alertVC.dismiss(animated: true)
        }))
        alertVC.addAction(SSPopoverAction(title: "確定", style: .default, handler: { [weak self] _ in
            self?.cancelSignUpToCurrentSharedSeatAnnotation()
            self?.changeCancelToSignUpUI()
            alertVC.dismiss(animated: true)
        }))
        self.present(alertVC, animated: true)
    }
    
    private func cancelSignUpToCurrentSharedSeatAnnotation(){
        
        let gender : String
        if(UserSetting.userGender == 1){
            gender = "/signUpBoysID"
        }else{
            gender = "/signUpGirlsID"
        }
        
        let ref = Database.database().reference().child("SharedSeatAnnotation/" + currentSharedSeatAnnotation!.holderUID + gender + "/" + UserSetting.UID)
        
        if(currentSharedSeatAnnotation!.mode == 2){
            //如果是二對二模式，就找到拿到同樣邀請碼的報名者，然後刪除
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists(){
                    if(snapshot.value as! String != "-"){
                        let invitationCode = snapshot.value as! String
                        let parentRef = Database.database().reference().child("SharedSeatAnnotation/" + self.currentSharedSeatAnnotation!.holderUID + gender)
                        
                        parentRef.observeSingleEvent(of: .value, with:{(snapshot2) in
                            for user_child in (snapshot2.children){
                                if(((user_child as! DataSnapshot).value as! String) == invitationCode){
                                    let childRef = Database.database().reference().child("SharedSeatAnnotation/" + self.currentSharedSeatAnnotation!.holderUID + gender + "/" + (user_child as! DataSnapshot).key)
                                    childRef.removeValue()
                                }
                                
                            }})
                    }
                    
                    
                    ref.removeValue(){
                        (error, ref) -> Void in
                        if error != nil{
                            print(error ?? "取消報名失敗")
                            self.showToast(message: "取消報名失敗", font: .systemFont(ofSize: 14.0))
                        }else{
                            self.showToast(message: "取消報名成功", font: .systemFont(ofSize: 14.0))
                            //處理本地端資料
                            if(UserSetting.userGender == 0){
                                if(self.currentSharedSeatAnnotation!.signUpGirlsID != nil){
                                    self.currentSharedSeatAnnotation!.signUpGirlsID!.removeValue(forKey: UserSetting.UID)
                                }
                            }else{
                                if(self.currentSharedSeatAnnotation!.signUpBoysID != nil){
                                    self.currentSharedSeatAnnotation!.signUpBoysID!.removeValue(forKey: UserSetting.UID)
                                }
                            }
                        }
                    }
                    
                }
            })
        }
        
        
        
        
        
        //刪除邀請碼，如果有的話
        if(currentSharedSeatAnnotation!.signUpBoysID != nil && currentSharedSeatAnnotation!.signUpBoysID![UserSetting.UID] != nil){
            for(UID,InvitationCode) in currentSharedSeatAnnotation!.signUpBoysID!{
                if(UID == UserSetting.UID && InvitationCode != "-"){
                    let invitationCodeRef = Database.database().reference().child("InvitationCode/" + "\(InvitationCode)")
                    invitationCodeRef.removeValue()
                }
            }
        }else if(currentSharedSeatAnnotation!.signUpGirlsID != nil && currentSharedSeatAnnotation!.signUpGirlsID![UserSetting.UID] != nil){
            for(UID,InvitationCode) in currentSharedSeatAnnotation!.signUpGirlsID!{
                if(UID == UserSetting.UID && InvitationCode != "-"){
                    let invitationCodeRef = Database.database().reference().child("InvitationCode/" + "\(InvitationCode)")
                    invitationCodeRef.removeValue()
                }
            }
        }
        
    }
    
    private func changeSignUpBtnToCancelBtn(){
        signUpBtn.setTitle("取消報名", for: .normal)
        signUpBtn.removeTarget(self, action: #selector(signUpBtnAct), for: .touchUpInside)
        signUpBtn.addTarget(self, action: #selector(cancelSignUpBtnAct), for: .touchUpInside)
    }
    
    private func changeCancelToSignUpUI(){
        signUpBtn.setTitle("報名", for: .normal)
        signUpBtn.removeTarget(self, action: #selector(cancelSignUpBtnAct), for: .touchUpInside)
        signUpBtn.addTarget(self, action: #selector(signUpBtnAct), for: .touchUpInside)
        
        invitationCodeLabel.text = ""
    }
    
    
    
    
    @objc func segmentedOnValueChanged_half(_ segmented: UISegmentedControl) {
        
        if(self.bulletinBoardExpansionState == .PartiallyExpanded){
            if(bookMarks_half[segmented.selectedSegmentIndex] == bookMarkName_Sell){
                bookMarkAct_OpenStore()
            }else if(bookMarks_half[segmented.selectedSegmentIndex] == bookMarkName_Buy){
                bookMarkAct_Request()
            }else if(bookMarks_half[segmented.selectedSegmentIndex] == bookMarkName_TeamUp){
                bookMarkAct_TeamUp()
            }else if(bookMarks_half[segmented.selectedSegmentIndex] == bookMarkName_MakeFriend){
                bookMarkAct_Profile()
            }
        }else{
            var bookMarks_temp = bookMarks_half
            bookMarks_temp.remove(at: 0)
            if(bookMarks_temp[segmented.selectedSegmentIndex] == bookMarkName_Sell){
                bookMarkAct_OpenStore_FullExpand()
            }else if(bookMarks_temp[segmented.selectedSegmentIndex] == bookMarkName_Buy){
                bookMarkAct_Request_FullExpand()
            }else if(bookMarks_temp[segmented.selectedSegmentIndex] == bookMarkName_TeamUp){
                bookMarkAct_TeamUp_FullExpand()
            }
        }
        
    }
    
    
}


// MARK: - MapKit Helper Func

extension MapViewController{
    
    func centerMapOnUserLocation(shouldLoadAnnotations: Bool) {
        
        print("centerMapOnUserLocation")
        
        guard let coordinates = locationManager.location?.coordinate else { return }
        
        let zoomWidth = mapView.visibleMapRect.size.width
        var meter : Double = 500
        if zoomWidth < 3694{
            meter = zoomWidth * 500/3694
        }
        let coordinateRegion = MKCoordinateRegion(center: coordinates, latitudinalMeters: meter, longitudinalMeters: meter)
        mapView.setRegion(coordinateRegion, animated: true)
        
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
        
        hiddeningTapBar = false
        hiddenTabBarOrNot()
        
        if view.annotation is CustomPointAnnotation{
            view.subviews[0].alpha = 0
        }
        
        if view.annotation is CoffeeAnnotation{
            //因為可能加入關注，這時caffeeIcon需要變色
            mapView.removeAnnotation(currentCoffeeAnnotation!)
            mapView.addAnnotation(currentCoffeeAnnotation!)
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
        
        hiddeningTapBar = true
        hiddenTabBarOrNot()
        
        let zoomWidth = mapView.visibleMapRect.size.width
        var meter : Double = 500
        if zoomWidth < 3694{
            meter = zoomWidth * 500/3694
        }
        let coordinateRegion = MKCoordinateRegion(center: view.annotation!.coordinate, latitudinalMeters: meter, longitudinalMeters: meter)
        mapView.setRegion(coordinateRegion, animated: true)
        
        
        
        if view.annotation is MKUserLocation{
            if actionSheetExpansionState == .NotExpanded {
                iWantActionSheetKit.allBtnSlideIn()
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
            animateBulletinBoard(targetPosition: self.view.frame.height - 300 - bottomPadding) { (_) in
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
        
        if view.annotation is SharedSeatAnnotation{
            Analytics.logEvent("地圖_點擊地標_相席", parameters:nil)
            
            //抓遠端的資料更新本地端
            let holderUID = (view.annotation as! SharedSeatAnnotation).holderUID
            let ref = Database.database().reference().child("SharedSeatAnnotation/" + "\(holderUID)")
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                let sharedSeatAnnotationData = SharedSeatAnnotationData(snapshot: snapshot)
                
                //抓到本地端的更新
                for annotation in self.sharedSeatAnnotationGetter.sharedSeat2Annotation{
                    if (annotation.holderUID == holderUID){
                        annotation.girlsID = sharedSeatAnnotationData.girlsID
                        annotation.boysID = sharedSeatAnnotationData.boysID
                        annotation.signUpGirlsID = sharedSeatAnnotationData.signUpGirlsID
                        annotation.signUpBoysID = sharedSeatAnnotationData.signUpBoysID
                    }
                }
                for annotation in self.sharedSeatAnnotationGetter.sharedSeat4Annotation{
                    if (annotation.holderUID == holderUID){
                        annotation.girlsID = sharedSeatAnnotationData.girlsID
                        annotation.boysID = sharedSeatAnnotationData.boysID
                        annotation.signUpGirlsID = sharedSeatAnnotationData.signUpGirlsID
                        annotation.signUpBoysID = sharedSeatAnnotationData.signUpBoysID
                    }
                }
                
                self.setBulletinBoard_sharedSeat(sharedSeatAnnotation: view.annotation as! SharedSeatAnnotation)
            }
            )
            
//
            return
        }
        
        if view.annotation is PersonAnnotation {
            
            Analytics.logEvent("地圖_點擊地標_人物", parameters:nil)
            
            var bookMarks : [String] = []
            bookMarks.append(bookMarkName_MakeFriend)
            if (view.annotation as! PersonAnnotation).isOpenStore{
                bookMarks.append(bookMarkName_Sell)
            }
            if (view.annotation as! PersonAnnotation).isRequest{
                bookMarks.append(bookMarkName_Buy)
            }
            if (view.annotation as! PersonAnnotation).isTeamUp{
                bookMarks.append(bookMarkName_TeamUp)
            }
            
            var selectedBookMark = ""
            
            switch  (view.annotation as! PersonAnnotation).markTypeToShow {
                
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
            ref.child((view.annotation as! PersonAnnotation).UID).observeSingleEvent(of: .value, with: { (snapshot) in
                loadingView.removeFromSuperview()
                self.setBulletinBoard(bookMarks: bookMarks,selectedbookMark:selectedBookMark,snapshot: snapshot,UID: (view.annotation as! PersonAnnotation).UID,distance:Int(distance),storeName: (view.annotation?.title!)!,openTimeString: (view.annotation as! PersonAnnotation).openTime)
            }) { (error) in
                loadingView.removeFromSuperview()
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
        
        
        let markColor = smallIconActiveColor
        
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
            
            mkMarker?.displayPriority = .defaultLow
            if(UserSetting.attentionCafe.contains((annotation as! CoffeeAnnotation).address)){
                mkMarker?.displayPriority = .defaultHigh
                if(checkIsOpenTimeOrNot(business_hours: (annotation as! CoffeeAnnotation).business_hours)){
                    mkMarker?.glyphTintColor = .sksPink()
                }else{
                    mkMarker?.glyphTintColor = .sksPink().withAlphaComponent(0.3)
                }
            }else{
                if(checkIsOpenTimeOrNot(business_hours: (annotation as! CoffeeAnnotation).business_hours)){
                    mkMarker?.glyphTintColor = markColor
                }else{
                    mkMarker?.glyphTintColor = markColor.withAlphaComponent(0.3)
                }
            }
            mkMarker?.glyphImage = UIImage(named: "咖啡小icon_紫")
        }
        
        if annotation is PersonAnnotation{
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
            switch (annotation as! PersonAnnotation).markTypeToShow {
            case .openStore:
                mkMarker?.glyphImage = UIImage(named: "icons24ShopLocateFilledBk24")
                break
            case .request:
                mkMarker?.glyphImage = UIImage(named: "icons24ShopNeedWt24")
                break
            case .teamUp:
                mkMarker?.glyphImage = UIImage(named: "旗子小icon_紫")
                break
            case .makeFriend:
                if let headShot = (annotation as! PersonAnnotation).smallHeadShot{
                    mkMarker?.glyphTintColor = .clear
                    let imageView = UIImageView(frame: CGRect(x: 2, y: 0, width: 25, height: 25))
                    imageView.tag = 1
                    imageView.image = headShot
                    imageView.contentMode = .scaleAspectFill
                    imageView.layer.cornerRadius = 12
                    imageView.clipsToBounds = true
                    mkMarker?.addSubview(imageView)
                }else{
                    if (annotation as! PersonAnnotation).gender == .Girl{
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
                if let headShot = (annotation as! PersonAnnotation).smallHeadShot{
                    let imageView = UIImageView(frame: CGRect(x: 2, y: 0, width: 25, height: 25))
                    imageView.tag = 1
                    imageView.contentMode = .scaleAspectFill
                    imageView.image = headShot
                    imageView.layer.cornerRadius = 12
                    imageView.clipsToBounds = true
                    mkMarker?.addSubview(imageView)
                }else{
                    if (annotation as! PersonAnnotation).gender == .Girl{
                        mkMarker?.glyphImage = UIImage(named: "girlIcon")
                    }else{
                        mkMarker?.glyphImage = UIImage(named: "boyIcon")
                    }
                }
            }
        }
        
        if annotation is SharedSeatAnnotation{
            
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
            mkMarker?.viewWithTag(1)?.removeFromSuperview()
            
            if((annotation as! SharedSeatAnnotation).mode == 1){
                mkMarker?.glyphImage = UIImage(named: "兩人相席")
                
            }else if((annotation as! SharedSeatAnnotation).mode > 1){
                mkMarker?.glyphImage = UIImage(named: "四人相席")
                
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


extension MapViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}


// MARK: - CoffeeComment用

extension MapViewController: UITableViewDelegate,UITableViewDataSource{
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coffeeComments.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentTableViewCell", for: indexPath) as! CommentTableViewCell
        
        cell.UID = coffeeComments[indexPath.row].UID
        cell.genderIcon.frame = cell.photo.frame
        cell.genderIcon.contentMode = .scaleAspectFit
        cell.genderIcon.tag = 1
        if coffeeComments[indexPath.row].gender == 0{
            cell.genderIcon.image = UIImage(named: "girlIcon")?.withRenderingMode(.alwaysTemplate)
        }else if coffeeComments[indexPath.row].gender == 1{
            cell.genderIcon.image = UIImage(named: "boyIcon")?.withRenderingMode(.alwaysTemplate)
        }
        cell.genderIcon.tintColor = .lightGray
        cell.addSubview(cell.genderIcon)
        cell.sendSubviewToBack(cell.genderIcon)
        
        if coffeeComments[indexPath.row].smallHeadshot != nil{
            //girlIcon和boyIcon需要Fit,照片需要Fill
            cell.photo.image =  coffeeComments[indexPath.row].smallHeadshot
            cell.photo.contentMode = .scaleAspectFill
            cell.photo.alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                cell.photo.alpha = 1
                cell.genderIcon.alpha = 0
            })
        }
        
        if coffeeComments[indexPath.row].likeUIDs!.count < 100{
            cell.heartNumberLabel.text = "\(coffeeComments[indexPath.row].likeUIDs!.count)"
        }else{
            cell.heartNumberLabel.text = "99+"
        }
        
        cell.heartImage.image = UIImage(named: "空愛心")?.withRenderingMode(.alwaysTemplate)
        for likeUID in coffeeComments[indexPath.row].likeUIDs!{
            if likeUID == UserSetting.UID{
                cell.heartImage.image = UIImage(named: "實愛心")?.withRenderingMode(.alwaysTemplate)
                cell.userPressLike = true
            }
        }
        
        let currentTime = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMddHHmmss"
        var currentTimeString = dateFormatter.string(from: currentTime)
        
        let commmentTime = dateFormatter.date(from: coffeeComments[indexPath.row].time)!
        
        let elapsedYear = currentTime.years(sinceDate: commmentTime) ?? 0
        var elapsedMonth = currentTime.months(sinceDate: commmentTime) ?? 0
        elapsedMonth %= 12
        var elapsedDay = currentTime.days(sinceDate: commmentTime) ?? 0
        elapsedDay %= 30
        var elapsedHour = currentTime.hours(sinceDate: commmentTime) ?? 0
        elapsedHour %= 24
        var elapsedMinute = currentTime.minutes(sinceDate: commmentTime) ?? 0
        elapsedMinute %= 60
        var elapsedSecond = currentTime.seconds(sinceDate: commmentTime) ?? 0
        elapsedSecond %= 60
        
        var finalTimeString : String = ""
        if elapsedYear > 0 {
            finalTimeString = "\(elapsedYear)" + "年前"
        }else if elapsedMonth > 0{
            finalTimeString = "\(elapsedMonth)" + "個月前"
        }else if elapsedDay > 0{
            finalTimeString = "\(elapsedDay)" + "天前"
        }else if elapsedHour > 0{
            finalTimeString = "\(elapsedHour)" + "小時前"
        }else if elapsedMinute > 0{
            finalTimeString = "\(elapsedMinute)" + "分前"
        }else {
            finalTimeString = "剛剛"
        }
        
        cell.nameLabel.text = coffeeComments[indexPath.row].name + " - " + finalTimeString
        cell.commentLabel.text = coffeeComments[indexPath.row].content
        cell.commentID = coffeeComments[indexPath.row].commentID!
        
        cell.coffeeAddress = currentCoffeeAnnotation?.address
        
        let bg = UIView()
        bg.backgroundColor = .clear
        cell.backgroundView = bg
        
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView,
                          didSelectRowAt indexPath: IndexPath) {
    }
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 110;//Choose your custom row height
    }
    
    
    
    
}
