//
//  ProfileViewController.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/04/09.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import MessageUI

protocol SettingViewDelegate: class {
    func gotoShopEditView()
    func gotoProfileEditView()
    func showMailViewController()
}


class SettingViewController: UIViewController {
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var photoBtn: UIButton!
    
    @IBOutlet weak var goProfileViewBtn: UIButton!
    @IBOutlet weak var goReportBtn: UIButton!
    @IBOutlet weak var goLogOutBtn: UIButton!
    @IBOutlet weak var goAuthorPageBtn: UIButton!
    
    @IBOutlet weak var perferMarkLabel: UILabel! //x:34 y:297
    @IBOutlet weak var myStoreLabel: UILabel!
    @IBOutlet weak var reportLabel: UILabel!
    @IBOutlet weak var logOutLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var aboutAuthorLabel: UILabel!
    
    @IBOutlet weak var rightArrow1: UIImageView!
    @IBOutlet weak var rightArrow2: UIImageView!
    @IBOutlet weak var rightArrow3: UIImageView!
    @IBOutlet weak var rightArrow4: UIImageView!
    
    @IBOutlet weak var seperator1: UIImageView!
    @IBOutlet weak var seperator2: UIImageView!
    @IBOutlet weak var seperator3: UIImageView!
    @IBOutlet weak var seperator4: UIImageView!
    @IBOutlet weak var seperator5: UIImageView!
    
    
    @IBOutlet weak var photoIconImage: UIImageView!
    @IBOutlet weak var photoEditLabel: UILabel!
    
    var preferOpenStoreMarkView = UIImageView()
    var preferRequestMarkView = UIImageView()
    var preferTeamUpMarkView = UIImageView()
    var preferMakeFriendMarkView = UIImageView()
    
    var accumulatedWidthOfMarks : CGFloat = 0
    weak var viewDelegate : SettingViewDelegate?
    let loadingView = UIImageView()
    private var actionSheetKit_LogOut = ActionSheetKit()
    
    let isAboutAuthorExist = false //有沒有『關於作者』
    
    private let durationOfAuction = 60 * 60 * 24 * 7 //刊登持續時間（秒） 7天
    
    var storeOpenTimeString : String = ""{
        didSet{
            if storeOpenTimeString != ""{
                startRemainingStoreOpenTimer()
            }
        }
    } //這是拿來倒數計時的，開店剩餘時間
    private var timer : Timer?
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CustomBGKit().CreatDarkStyleBG(view: view)
        
        self.photo.contentMode = .scaleAspectFill
        
        setAllViewsFrame()
        configPhotoImageView()
        
        actionSheetKit_LogOut.creatActionSheet(containerView: view, actionSheetText: ["取消","確定登出"])
        actionSheetKit_LogOut.getActionSheetBtn(i: 1)?.addTarget(self, action: #selector(actionSheetConfirmLogOutBtnAct), for: .touchUpInside)
        actionSheetKit_LogOut.getActionSheetBtn(i: 0)?.addTarget(self, action: #selector(showTabBar), for: .touchUpInside)
        actionSheetKit_LogOut.getbgBtn().addTarget(self, action: #selector(showTabBar), for: .touchUpInside)
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        setPreferMarksAndBtn()
    }
    
    
    func startRemainingStoreOpenTimer(){
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYYMMddHHmmss"
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in
            
            if self.remainingTimeLabel != nil{
                if self.storeOpenTimeString != "" {
                    let seconds = Date().seconds(sinceDate: formatter.date(from: self.storeOpenTimeString)!)
                    let remainingHour = (self.durationOfAuction - seconds!) / (60 * 60)
                    let remainingMin = ((self.durationOfAuction - seconds!) % (60 * 60)) / 60
                    let remainingSecond = ((self.durationOfAuction - seconds!) % (60 * 60)) % 60
                    let remainingTime = "\(remainingHour)" + " : " + "\(remainingMin)" + " : " + "\(remainingSecond)"
                    
                    if remainingHour >= 0 && remainingMin >= 0 && remainingSecond >= 0{
                        self.remainingTimeLabel.text = remainingTime
                    }else{
                        self.remainingTimeLabel.text = ""
                        FirebaseHelper.deleteTradeAnnotation()
                        NotifyHelper.pushNewNoti(title: "擺攤時間到，已收攤", subTitle: "您可以在『我的攤販』設定內再度開啟攤販")
                        self.timer?.invalidate()
                    }
                }else{
                    self.remainingTimeLabel.text = ""
                    self.timer?.invalidate()
                }}
            
        })
        
    }
    
    fileprivate func configPhotoImageView() {
        photo.alpha = 0
        if UserSetting.userPhotosUrl.count > 0{
            let url = UserSetting.userPhotosUrl[0]
            loadingView.frame = photo.frame
            loadingView.contentMode = .scaleAspectFill
            loadingView.image = UIImage(named: "photoIcon_ square_booming")
            view.addSubview(loadingView)
            view.bringSubviewToFront(photo)
            view.bringSubviewToFront(photoBtn)
            AF.request(url).response { (response) in
                guard let data = response.data, let image = UIImage(data: data)
                    else { return }
                self.changePhotoImage(image)
            }
            
        }else{
            changePhotoImage(UIImage(named: "photoIcon_ square_booming")!)
        }
    }
    
    
    public func changePhotoImage(_ image:UIImage){
        photo.alpha = 0
        photo.image = image
        if image != UIImage(named: "photoIcon_ square_booming"){
            photoIconImage.frame = CGRect(x: 240 - 20 - 89, y: 240 - 15 - 7, width: 20, height: 15)
            photoEditLabel.frame = CGRect(x: 240 - photoEditLabel.intrinsicContentSize.width - 6, y: 240 - photoEditLabel.intrinsicContentSize.height - 6, width: photoEditLabel.intrinsicContentSize.width, height: photoEditLabel.intrinsicContentSize.height)
            UIView.animate(withDuration: 0.3, animations: {
                self.photo.alpha = 1
                self.loadingView.alpha = 0
            })
        }else{
            photoIconImage.frame = CGRect(x: 240 - 20 - 89 - 20, y: 240 - 15 - 7 - 20, width: 20, height: 15)
            photoEditLabel.frame = CGRect(x: 240 - photoEditLabel.intrinsicContentSize.width - 6 - 20, y: 240 - photoEditLabel.intrinsicContentSize.height - 6 - 20, width: photoEditLabel.intrinsicContentSize.width, height: photoEditLabel.intrinsicContentSize.height)
            photo.alpha = 1
        }
    }
    
    //用這種方式捨棄autolayout
    //將在storyboard先做好的元件放在正確的位置
    fileprivate func setAllViewsFrame() {
        
        let topPadding = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
        
        photo.layer.cornerRadius = 12
        photo.clipsToBounds = true
        photo.frame = CGRect(x: view.frame.width/2 - 240/2, y: topPadding + 35, width: 240, height: 242)
        photoBtn.frame = CGRect(x: view.frame.width/2 - 240/2, y: topPadding + 35, width: 240, height: 240)
        photoIconImage.frame = CGRect(x: 240 - 20 - 89, y: topPadding + 240 - 15 - 7, width: 20, height: 15)
        photoIconImage.removeFromSuperview()
        photo.addSubview(photoIconImage)
        photoEditLabel.frame = CGRect(x: 240 - photoEditLabel.intrinsicContentSize.width - 6, y: topPadding + 240 - photoEditLabel.intrinsicContentSize.height - 6, width: photoEditLabel.intrinsicContentSize.width, height: photoEditLabel.intrinsicContentSize.height)
        photoEditLabel.removeFromSuperview()
        photo.addSubview(photoEditLabel)
        
        perferMarkLabel.frame = CGRect(x: 34, y: topPadding + 297, width: perferMarkLabel.intrinsicContentSize.width, height: perferMarkLabel.intrinsicContentSize.height)
        myStoreLabel.frame = CGRect(x: 34, y: topPadding + 380, width: myStoreLabel.intrinsicContentSize.width, height: myStoreLabel.intrinsicContentSize.height)
        remainingTimeLabel.frame = CGRect(x: view.frame.width - 10 * 2 - 34 - remainingTimeLabel.intrinsicContentSize.width, y:topPadding + 380, width: remainingTimeLabel.intrinsicContentSize.width, height: remainingTimeLabel.intrinsicContentSize.height)
        remainingTimeLabel.text = ""
        reportLabel.frame = CGRect(x: 34, y:topPadding + 431, width: reportLabel.intrinsicContentSize.width, height: reportLabel.intrinsicContentSize.height)
        aboutAuthorLabel.frame = CGRect(x: 34, y: topPadding + 482, width: aboutAuthorLabel.intrinsicContentSize.width, height: aboutAuthorLabel.intrinsicContentSize.height)
        logOutLabel.frame = CGRect(x: 34, y:topPadding + 533, width: logOutLabel.intrinsicContentSize.width, height: logOutLabel.intrinsicContentSize.height)
        
        seperator1.frame = CGRect(x: 20, y:topPadding + 364, width: view.frame.width - 40, height: 1)
        seperator2.frame = CGRect(x: 20, y:topPadding + 415, width: view.frame.width - 40, height: 1)
        seperator3.frame = CGRect(x: 20, y:topPadding + 466, width: view.frame.width - 40, height: 1)
        seperator4.frame = CGRect(x: 20, y:topPadding + 517, width: view.frame.width - 40, height: 1)
        seperator5.frame = CGRect(x: 20, y:topPadding + 568, width: view.frame.width - 40, height: 1)
        
        goProfileViewBtn.frame = CGRect(x: 0, y:topPadding + 365, width: view.frame.width, height: 50)
        let highLightColor = UIColor(red: 23/255, green: 25/255, blue: 27/255, alpha: 0.7)
        goProfileViewBtn.setBackgroundColor(highLightColor, forState: .highlighted)
        goReportBtn.frame = CGRect(x: 0, y:topPadding + 416, width: view.frame.width, height: 50)
        goReportBtn.setBackgroundColor(highLightColor, forState: .highlighted)
        goAuthorPageBtn.frame = CGRect(x: 0, y:topPadding + 467, width: view.frame.width, height: 50)
        goAuthorPageBtn.setBackgroundColor(highLightColor, forState: .highlighted)
        goLogOutBtn.frame = CGRect(x: 0, y:topPadding + 518, width: view.frame.width, height: 50)
        goLogOutBtn.setBackgroundColor(highLightColor, forState: .highlighted)
        
        rightArrow1.frame = CGRect(x: view.frame.width - 10 - 34, y: topPadding + 378, width: 10, height: 22)
        rightArrow2.frame = CGRect(x: view.frame.width - 10 - 34, y: topPadding + 378 + 50, width: 10, height: 22)
        rightArrow3.frame = CGRect(x: view.frame.width - 10 - 34, y: topPadding + 378 + 50 * 2, width: 10, height: 22)
        rightArrow4.frame = CGRect(x: view.frame.width - 10 - 34, y: 378 + 50 * 3, width: 10, height: 22)
        if !isAboutAuthorExist{
            rightArrow4.isHidden = true
            seperator5.isHidden = true
            aboutAuthorLabel.isHidden = true
            goAuthorPageBtn.isHidden = true
            goAuthorPageBtn.isEnabled = false
            logOutLabel.frame = aboutAuthorLabel.frame
            goLogOutBtn.frame = goAuthorPageBtn.frame
        }
        
    }
    
    fileprivate func setPreferMarksAndBtn() {
        
        accumulatedWidthOfMarks = 0
        
        let topPadding = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
        
        if preferOpenStoreMarkView.superview != nil{
            preferOpenStoreMarkView.removeFromSuperview()
        }
        if UserSetting.isWantSellSomething{
            preferOpenStoreMarkView = { () -> UIImageView in
                let view = UIImageView()
                
                view.frame = CGRect(x: 34 + 10, y: topPadding + 297 + 27, width: 30, height: 26)
                let tintedImage = UIImage(named: "天秤小icon")?.withRenderingMode(.alwaysTemplate)
                view.tintColor = UIColor.hexStringToUIColor(hex: "4A4A4A")
                if UserSetting.perferIconStyleToShowInMap == "openStore"{
                    view.tintColor = UIColor.hexStringToUIColor(hex: "D8D8D8")
                }
                view.image = tintedImage
                return view
                
            }()
            view.addSubview(preferOpenStoreMarkView)
            
            let preferOpenStoreMarkBtn = {() -> UIButton in
                let btn = UIButton()
                btn.frame = CGRect(x: 34, y: topPadding + 297 + 15, width: 50, height: 50)
                btn.addTarget(self, action: #selector(preferOpenStoreMarkBtnAct), for: .touchUpInside)
                return btn
            }()
            view.addSubview(preferOpenStoreMarkBtn)
            
            accumulatedWidthOfMarks += 50
        }
        
        if preferRequestMarkView.superview != nil{
            preferRequestMarkView.removeFromSuperview()
        }
        if UserSetting.isWantBuySomething{
            preferRequestMarkView = { () -> UIImageView in
                let view = UIImageView()
                view.frame = CGRect(x: 34 + accumulatedWidthOfMarks + 10, y:topPadding + 297 + 27, width: 30, height: 30)
                let tintedImage = UIImage(named: "捲軸小icon")?.withRenderingMode(.alwaysTemplate)
                view.tintColor = UIColor.hexStringToUIColor(hex: "4A4A4A")
                if UserSetting.perferIconStyleToShowInMap == "request"{
                    view.tintColor = UIColor.hexStringToUIColor(hex: "D8D8D8")
                }
                view.image = tintedImage
                return view
            }()
            view.addSubview(preferRequestMarkView)
            
            
            let preferRequestMarkBtn = {() -> UIButton in
                let btn = UIButton()
                btn.frame = CGRect(x: 34 + accumulatedWidthOfMarks, y: topPadding + 297 + 15, width: 50, height: 50)
                btn.addTarget(self, action: #selector(preferRequestMarkBtnAct), for: .touchUpInside)
                return btn
            }()
            view.addSubview(preferRequestMarkBtn)
            
            accumulatedWidthOfMarks += 50
        }
        
        if preferTeamUpMarkView.superview != nil{
            preferTeamUpMarkView.removeFromSuperview()
        }
        if UserSetting.isWantTeamUp{
            preferTeamUpMarkView = { () -> UIImageView in
                let view = UIImageView()
                view.frame = CGRect(x: 34 + accumulatedWidthOfMarks + 11.5, y:topPadding + 297 + 25.5, width: 29, height: 34)
                let tintedImage = UIImage(named: "旗子小icon")?.withRenderingMode(.alwaysTemplate)
                view.tintColor = UIColor.hexStringToUIColor(hex: "4A4A4A")
                if UserSetting.perferIconStyleToShowInMap == "teamUp"{
                    view.tintColor = UIColor.hexStringToUIColor(hex: "D8D8D8")
                }
                view.image = tintedImage
                return view
            }()
            view.addSubview(preferTeamUpMarkView)
            
            
            let preferTeamUpMarkBtn = {() -> UIButton in
                let btn = UIButton()
                btn.frame = CGRect(x: 34 + accumulatedWidthOfMarks, y:topPadding + 297 + 15, width: 50, height: 50)
                btn.addTarget(self, action: #selector(preferTeamUpMarkBtnAct), for: .touchUpInside)
                
                return btn
            }()
            view.addSubview(preferTeamUpMarkBtn)
            
            accumulatedWidthOfMarks += 50
        }
        
        if preferMakeFriendMarkView.superview != nil{
            preferMakeFriendMarkView.removeFromSuperview()
        }
        if UserSetting.isWantMakeFriend{
            preferMakeFriendMarkView = { () -> UIImageView in
                let view = UIImageView()
                view.frame = CGRect(x: 34 + accumulatedWidthOfMarks + 10, y:topPadding + 297 + 27, width: 30, height: 30)
                var tintedImage : UIImage
                
                if UserSetting.userGender == 0{
                    tintedImage = (UIImage(named: "girlPhotoIcon")?.withRenderingMode(.alwaysTemplate))!
                }else{
                    tintedImage = (UIImage(named: "boyPhotoIcon")?.withRenderingMode(.alwaysTemplate))!
                }
                view.tintColor = UIColor.hexStringToUIColor(hex: "4A4A4A")
                if UserSetting.perferIconStyleToShowInMap == "makeFriend"{
                    view.tintColor = UIColor.hexStringToUIColor(hex: "D8D8D8")
                }
                view.image = tintedImage
                return view
            }()
            view.addSubview(preferMakeFriendMarkView)
            
            
            let preferMakeFriendMarkBtn = {() -> UIButton in
                let btn = UIButton()
                btn.frame = CGRect(x: 34 + accumulatedWidthOfMarks, y:topPadding + 297 + 15, width: 50, height: 50)
                btn.addTarget(self, action: #selector(preferMakeFriendMarkBtnAct), for: .touchUpInside)
                
                return btn
            }()
            view.addSubview(preferMakeFriendMarkBtn)
        }
        
        if !UserSetting.isWantSellSomething && !UserSetting.isWantBuySomething && !UserSetting.isWantTeamUp && !UserSetting.isWantMakeFriend{
            perferMarkLabel.alpha = 0
        }
    }
    
    @objc private func showTabBar(){
        CoordinatorAndControllerInstanceHelper.rootCoordinator.showTabBar()
    }
    
    //MARK:- ButtonAct
    
    @IBAction func goProfileBtnAct(_ sender: Any) {
        Analytics.logEvent("我_我的攤販", parameters:nil)
        viewDelegate?.gotoShopEditView()
    }
    
    
    @IBAction func goReportBtnAct(_ sender: Any) {
        Analytics.logEvent("我_回報", parameters:nil)
        viewDelegate?.showMailViewController()
    }
    
    @IBAction func goAuthorPageBtnAct(_ sender: Any) {
        print("goAuthorPageBtnAct")
        Analytics.logEvent("我_關於作者", parameters:nil)
    }
    
    @IBAction func goLogOutBtnAct(_ sender: Any) {
        Analytics.logEvent("我_登出", parameters:nil)
        actionSheetKit_LogOut.allBtnSlideIn()
        CoordinatorAndControllerInstanceHelper.rootCoordinator.hiddenTabBar()
    }
    
    
    @IBAction func photoBtnAct(_ sender: Any) {
        viewDelegate?.gotoProfileEditView()
        Analytics.logEvent("我_編輯個人檔案", parameters:nil)
    }
    
    
    
    @objc fileprivate func preferOpenStoreMarkBtnAct(){
        
        Analytics.logEvent("我_地圖上優先被顯示為_擺攤", parameters:nil)
        
        preferOpenStoreMarkView.tintColor = UIColor.hexStringToUIColor(hex: "D8D8D8")
        preferRequestMarkView.tintColor = UIColor.hexStringToUIColor(hex: "4A4A4A")
        preferTeamUpMarkView.tintColor = UIColor.hexStringToUIColor(hex: "4A4A4A")
        preferMakeFriendMarkView.tintColor = UIColor.hexStringToUIColor(hex: "4A4A4A")
        UserSetting.perferIconStyleToShowInMap = "openStore"
        updatePreferMarkToFireBase()
        CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.presonAnnotationGetter.reFreshUserAnnotation(smallHeadShot: nil, refreshLocation: false)
    }
    
    @objc fileprivate func preferRequestMarkBtnAct(){
        
        Analytics.logEvent("我_地圖上優先被顯示為_任務", parameters:nil)
        
        preferOpenStoreMarkView.tintColor = UIColor.hexStringToUIColor(hex: "4A4A4A")
        preferRequestMarkView.tintColor = UIColor.hexStringToUIColor(hex: "D8D8D8")
        preferTeamUpMarkView.tintColor = UIColor.hexStringToUIColor(hex: "4A4A4A")
        preferMakeFriendMarkView.tintColor = UIColor.hexStringToUIColor(hex: "4A4A4A")
        UserSetting.perferIconStyleToShowInMap = "request"
        
        updatePreferMarkToFireBase()
        CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.presonAnnotationGetter.reFreshUserAnnotation(smallHeadShot: nil, refreshLocation: false)
        
    }
    
    @objc fileprivate func preferTeamUpMarkBtnAct(){
        
        Analytics.logEvent("我_地圖上優先被顯示為_揪團", parameters:nil)
        
        preferOpenStoreMarkView.tintColor = UIColor.hexStringToUIColor(hex: "4A4A4A")
        preferRequestMarkView.tintColor = UIColor.hexStringToUIColor(hex: "4A4A4A")
        preferTeamUpMarkView.tintColor = UIColor.hexStringToUIColor(hex: "D8D8D8")
        preferMakeFriendMarkView.tintColor = UIColor.hexStringToUIColor(hex: "4A4A4A")
        UserSetting.perferIconStyleToShowInMap = "teamUp"
        
        updatePreferMarkToFireBase()
        CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.presonAnnotationGetter.reFreshUserAnnotation(smallHeadShot: nil, refreshLocation: false)
        
    }
    
    @objc fileprivate func preferMakeFriendMarkBtnAct(){
        
        Analytics.logEvent("我_地圖上優先被顯示為_交友", parameters:nil)
        
        preferOpenStoreMarkView.tintColor = UIColor.hexStringToUIColor(hex: "4A4A4A")
        preferRequestMarkView.tintColor = UIColor.hexStringToUIColor(hex: "4A4A4A")
        preferTeamUpMarkView.tintColor = UIColor.hexStringToUIColor(hex: "4A4A4A")
        preferMakeFriendMarkView.tintColor = UIColor.hexStringToUIColor(hex: "D8D8D8")
        UserSetting.perferIconStyleToShowInMap = "makeFriend"
        
        updatePreferMarkToFireBase()
        CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.presonAnnotationGetter.reFreshUserAnnotation(smallHeadShot: nil, refreshLocation: false)
    }
    
    
    fileprivate func updatePreferMarkToFireBase() {
        let ref = Database.database().reference().child("PersonAnnotation/" + "\(UserSetting.UID)" + "/preferMarkType")
        ref.setValue(UserSetting.perferIconStyleToShowInMap)
    }
    
    //MARK:- ActionSheetKitAct
    
    
    @objc fileprivate func actionSheetConfirmLogOutBtnAct(){
        
        Analytics.logEvent("我_登出_確定登出", parameters:nil)
        
        CoordinatorAndControllerInstanceHelper.rootCoordinator.showTabBar()
        
        let dic = ["alreadyUpdatePersonDetail":false,
                   "UID":"",
                   "userName":"",
                   "userBirthDay":"",
                   "userGender":1,
                   "isMapShowOpenStore": UserSetting.isMapShowTeamUp,
                   "isMapShowRequest":UserSetting.isMapShowRequest,
                   "isMapShowTeamUp":UserSetting.isMapShowTeamUp,
                   "isMapShowCoffeeShop":UserSetting.isMapShowCoffeeShop,
                   "isMapShowMakeFriend_Boy":UserSetting.isMapShowMakeFriend_Boy,
                   "isMapShowMakeFriend_Girl":UserSetting.isMapShowMakeFriend_Girl,
                   "perferIconStyleToShowInMap":UserSetting.perferIconStyleToShowInMap,
                   "isWantSellSomething":false,
                   "isWantBuySomething":false,
                   "isWantTeamUp":false,
                   "isWantMakeFriend":false,
                   "sellItemsID":[],
                   "buyItemsID":[],
                   "userPhotosUrl":[] ] as [String : Any]
        for data in dic {
            UserDefaults.standard.set(data.value, forKey: data.key)
        }
        
        CoordinatorAndControllerInstanceHelper.rootCoordinator.rootTabBarController.children.forEach({vc in
            vc.dismiss(animated: false, completion: nil)
        })
        
        let window = UIApplication.shared.keyWindow
        window?.rootViewController = RootTabBarController.initFromStoryboard()
        window?.makeKeyAndVisible()
        AppCoordinator(window: window).start()
        
        
    }
    
    
    
    
    
    
}


extension SettingViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}
