//
//  ShopEditViewController.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/05/09.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Alamofire


protocol ShopEditViewControllerViewDelegate: class {
    func gotoItemViewController_shopEditView(item:Item,personDetail:PersonDetailInfo)
    func gotoProfileViewController_shopEditView(personDetail:PersonDetailInfo)
    func gotoWantSellViewController_shopEditView(defaultItem:Item?)
    func gotoWantBuyViewController_shopEditView(defaultItem:Item?)
}


class ShopEditViewController : UIViewController , ShopModelDelegate{
    
    
    
    
    weak var viewDelegate: ShopEditViewControllerViewDelegate?
    weak var mapViewController : MapViewController?
    
    var bigItemTableView = UITableView()
    var bigItemDelegate = BigItemTableViewDelegate()
    
    var bookMarkClassificationNameLabels_ProfileBoard : [UILabel] = []
    
    let shopModel = ShopModel()
    
    var loadingViewDone = false
    var loadingView : UIView!
    var bulletinBoard = UIView()
    
    var customTopBarKit = CustomTopBarKit()
    
    let mediumSizeHeadShot = UIImageView()
    
    private var topBarMaxY : CGFloat = 0
    
    var noDataLabel = UILabel()
    var isSettedTopBar = false
    
    private let actionSheetKit_addBtn = ActionSheetKit()
    private let actionSheetKit_wantCloseUpShop = ActionSheetKit()
    
    var openingStore = false {
        didSet{
            if openingStore{
                Analytics.logEvent("編輯商店_收攤", parameters:nil)
                openOrCloseStoreBtn.setTitle("收攤", for: [])
            }else{
                Analytics.logEvent("編輯商店_擺攤", parameters:nil)
                openOrCloseStoreBtn.setTitle("擺攤", for: [])
            }
        }
    }
    private var openOrCloseStoreBtn = UIButton()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        let bgKit = CustomBGKit()
        bgKit.CreatParchmentBG(view: view)
        bgKit.GetScrollView().isHidden = true
        
        shopModel.viewDelegate = self
        shopModel.fetchPersonDetail(completion: {() -> () in
            self.setProfileAndShopInfo()
            self.view.addSubview(self.circleButton_add)
        })
        
        
        guard let viewController = CoordinatorAndControllerInstanceHelper.rootCoordinator.rootTabBarController.selectedViewController else { return }
        
        actionSheetKit_wantCloseUpShop.creatActionSheet(containerView: viewController.view, actionSheetText: ["取消","確認要收攤"])
        actionSheetKit_wantCloseUpShop.getActionSheetBtn(i: 1)?.addTarget(self, action: #selector(iWantCloseStoreBtnAct), for: .touchUpInside)
        
        actionSheetKit_addBtn.creatActionSheet(containerView: viewController.view, actionSheetText: ["取消","發布任務(徵求一場約會、二手物品⋯⋯)","擺攤(賣全新或二手商品、技術)"])
        actionSheetKit_addBtn.getActionSheetBtn(i: 1)?.addTarget(self, action: #selector(iWantRequestBtnAct), for: .touchUpInside)
        actionSheetKit_addBtn.getActionSheetBtn(i: 2)?.addTarget(self, action: #selector(iWantOpenStoreBtnAct), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if !isSettedTopBar{
            customTopBarKit.CreatTopBar(view: view)
            customTopBarKit.CreatDoSomeThingTextBtn(text: "擺攤")
            openOrCloseStoreBtn = customTopBarKit.getDoSomeThingBtn()
            openOrCloseStoreBtn.addTarget(self, action: #selector(openOrCloseStoreBtnAct), for: .touchUpInside)
            let gobackBtn = customTopBarKit.getGobackBtn()
            gobackBtn.addTarget(self, action: #selector(gobackBtnAct), for: .touchUpInside)
            topBarMaxY = customTopBarKit.getTopBar().frame.maxY
            isSettedTopBar = true
            
            if CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.presonAnnotationGetter.userAnnotation == nil{
                openingStore = false
            }else{
                openingStore = true
            }
            
        }
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        if bigItemDelegate.orderChanged{
            shopModel.putItemOrderToFireBase()
        }
    }
    
    
    lazy var circleButton_add : UIButton = {
        let btn = UIButton(frame:CGRect(x: view.frame.width/2 - 53/2, y: view.frame.height - 53 - 40, width: 53, height: 53))
        btn.setImage(UIImage(named: "開攤販button")!, for: [])
        btn.isEnabled = true
        btn.addTarget(self, action: #selector(addBtnAct), for: .touchUpInside)
        return btn
    }()
    
    
    fileprivate func setProfileAndShopInfo() {
        
        bulletinBoard.frame = CGRect(x: 0, y: topBarMaxY, width: view.frame.width, height: view.frame.height - topBarMaxY)
        view.addSubview(bulletinBoard)
        
        let offsetY : CGFloat = -35
        
        //照片
        mediumSizeHeadShot.frame = CGRect(x: 9, y: 47 + offsetY, width: 120, height: 120)
        mediumSizeHeadShot.layer.cornerRadius = 60
        mediumSizeHeadShot.clipsToBounds = true
        mediumSizeHeadShot.contentMode = .scaleAspectFill
        
        let loadingView = UIImageView(frame: CGRect(x: mediumSizeHeadShot.frame.minX + mediumSizeHeadShot.frame.width * 1/12, y: mediumSizeHeadShot.frame.minY + mediumSizeHeadShot.frame.height * 1/12, width: mediumSizeHeadShot.frame.width * 5/6, height: mediumSizeHeadShot.frame.height * 5/6))
        loadingView.contentMode = .scaleAspectFit
        if shopModel.personInfo.gender == 0{
            loadingView.image = UIImage(named: "girlIcon")?.withRenderingMode(.alwaysTemplate)
        }else{
            loadingView.image = UIImage(named: "boyIcon")?.withRenderingMode(.alwaysTemplate)
        }
        loadingView.tintColor = UIColor.hexStringToUIColor(hex: "472411")
        bulletinBoard.addSubview(loadingView)
        bulletinBoard.addSubview(mediumSizeHeadShot)
        
        //姓名
        let nameLabel = UILabel()
        nameLabel.font = UIFont(name: "HelveticaNeue", size: 18)
        nameLabel.textColor = UIColor.hexStringToUIColor(hex: "000000")
        nameLabel.text = shopModel.personInfo.name
        nameLabel.frame = CGRect(x: 9 + 120 + 6, y: 47 + offsetY, width: nameLabel.intrinsicContentSize.width, height: nameLabel.intrinsicContentSize.height)
        bulletinBoard.addSubview(nameLabel)
        
        //年齡
        let ageLabel = UILabel()
        ageLabel.font = UIFont(name: "HelveticaNeue", size: 16)
        ageLabel.textColor = UIColor.hexStringToUIColor(hex: "000000")
        let birthdayFormatter = DateFormatter()
        birthdayFormatter.dateFormat = "yyyy/MM/dd"
        let currentTime = Date()
        let birthDayDate = birthdayFormatter.date(from: shopModel.personInfo.birthday)
        let age = currentTime.years(sinceDate: birthDayDate!) ?? 0
        if age != 0 {
            ageLabel.text = "\(age)"
        }
        ageLabel.frame = CGRect(x: 9 + 120 + 6 + nameLabel.intrinsicContentSize.width + 4, y: 49 + offsetY, width: nameLabel.intrinsicContentSize.width, height: ageLabel.intrinsicContentSize.height)
        bulletinBoard.addSubview(ageLabel)
        
        let selfIntroductionLabel = UILabel()
        selfIntroductionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        selfIntroductionLabel.textColor = .black
        selfIntroductionLabel.text = shopModel.personInfo.selfIntroduction
        selfIntroductionLabel.numberOfLines = 0
        selfIntroductionLabel.textAlignment = .left
        selfIntroductionLabel.frame = CGRect(x: 135, y: nameLabel.frame.maxY + 5, width: view.frame.width - 145, height: 66.4)
        bulletinBoard.addSubview(selfIntroductionLabel)
        selfIntroductionLabel.sizeToFit()
        //66.4是四行的高度 如果超過四行，就縮小
        if selfIntroductionLabel.frame.height > 66.4{
            selfIntroductionLabel.frame = CGRect(x: 135, y: nameLabel.frame.maxY + 5, width: view.frame.width - 145, height: 66.4)
        }
        
        //點擊照片或是自我介紹，前往PhotoProfileView
        let gotoPhotoProfileViewBtn = { () -> UIButton in
            let btn = UIButton()
            btn.frame = CGRect(x: 0, y: 47 + offsetY, width: view.frame.width, height: 120)
            btn.addTarget(self, action: #selector(gotoPhotoProfileViewBtnAct), for: .touchUpInside)
            return btn
        }()
        bulletinBoard.addSubview(gotoPhotoProfileViewBtn)
        
        //點擊照片或是自我介紹，前往PhotoProfileView
        let gotoPhotoProfileViewBtn_Bottom = { () -> UIButton in
            let btn = UIButton()
            btn.frame = CGRect(x: 0, y: 47 + offsetY, width: view.frame.width, height: 120)
            btn.addTarget(self, action: #selector(gotoPhotoProfileViewBtnAct), for: .touchUpInside)
            return btn
        }()
        bulletinBoard.addSubview(gotoPhotoProfileViewBtn_Bottom)
        
        
        //製作書籤
        let bookMarkContainerView = UIView()
        bookMarkContainerView.frame = CGRect(x: 0, y: 240 + offsetY - 60, width: view.frame.width, height: 44)
        let bookMarkKit = CustomBookMarkKit(title: ["擺攤","任務"], containerView: bookMarkContainerView)
        bookMarkKit.titleBtns[0].addTarget(self, action: #selector(ProfileBoard_bookMarkAct_OpenStore), for: .touchUpInside)
        bookMarkKit.titleBtns[1].addTarget(self, action: #selector(ProfileBoard_bookMarkAct_Request), for: .touchUpInside)
        shopModel.customBookMarkKit = bookMarkKit
        bulletinBoard.addSubview(bookMarkContainerView)
        
        bigItemDelegate.personDetail = shopModel.personInfo
        bigItemDelegate.currentItemType = shopModel.currentItemType
        bigItemDelegate.shopEditViewDelegate = viewDelegate
        bigItemDelegate.canMoveRow = true
        bigItemTableView = UITableView()
        bigItemTableView.frame = CGRect(x: 0, y: 44 + 240 + offsetY - 60, width: view.frame.width, height: bulletinBoard.frame.height - 44 - 240 + 40 - offsetY + 60)
        bigItemTableView.delegate = bigItemDelegate
        bigItemTableView.dataSource = bigItemDelegate
        bigItemTableView.showsVerticalScrollIndicator = false
        bigItemTableView.register(BigItemTableViewCell.self, forCellReuseIdentifier: "bigItemTableViewCell")
        bigItemTableView.rowHeight = 110
        bigItemTableView.estimatedRowHeight = 0
        bigItemTableView.backgroundColor = .clear
        bigItemTableView.separatorColor = .clear
        bigItemTableView.separatorInset = .zero
        bigItemTableView.setEditing(true, animated: false)
        bulletinBoard.addSubview(bigItemTableView)
        
        shopModel.currentItemType = .Sell
    }
    
    
    
    //MARK: - BtnAct
    
    
    @objc fileprivate func gotoPhotoProfileViewBtnAct(){
        viewDelegate?.gotoProfileViewController_shopEditView(personDetail: shopModel.personInfo)
    }
    
    @objc private func ProfileBoard_bookMarkAct_OpenStore(){
        shopModel.currentItemType = .Sell
    }
    @objc private func ProfileBoard_bookMarkAct_Request(){
        shopModel.currentItemType = .Buy
    }
    
    @objc private func gobackBtnAct(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func openOrCloseStoreBtnAct(){
        if openingStore{
            actionSheetKit_wantCloseUpShop.allBtnSlideIn()
        }else{
            FirebaseHelper.updatePersonAnnotation()
            openingStore = true
        }
    }
    
    
    
    
    
    
    @objc fileprivate func addBtnAct(){
        Analytics.logEvent("編輯商店_加號", parameters:nil)
        actionSheetKit_addBtn.allBtnSlideIn()
    }
    
    
    @objc private func iWantOpenStoreBtnAct(){
        Analytics.logEvent("編輯商店_加號_擺攤", parameters:nil)
        viewDelegate?.gotoWantSellViewController_shopEditView(defaultItem:nil)
    }
    @objc private func iWantRequestBtnAct(){
        Analytics.logEvent("編輯商店_加號_發布任務", parameters:nil)
        viewDelegate?.gotoWantBuyViewController_shopEditView(defaultItem:nil)
    }
    
    @objc private func iWantTeamUpBtnAct(){
        print("iWantTeamUpBtnAct")
    }
    
    
    
    @objc private func iWantCloseStoreBtnAct(){
        Analytics.logEvent("編輯商店_收攤_確認要收攤", parameters:nil)
        openingStore = false
        FirebaseHelper.deletePersonAnnotation()
    }
    
    //MARK:- ShopEditViewModelDelegate
    
    func stopLoadingView() {
        
        
    }
    
    func reloadTableView() {
        bigItemDelegate.currentItemType = shopModel.currentItemType
        bigItemTableView.reloadData()
    }
    
    func reloadTableView(indexPath:IndexPath){

    }
    
    func updateHeadShot() {
        mediumSizeHeadShot.image = shopModel.personInfo.headShotContainer
        mediumSizeHeadShot.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.mediumSizeHeadShot.alpha = 1
        })
    }
}
