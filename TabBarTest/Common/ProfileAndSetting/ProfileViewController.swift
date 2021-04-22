//
//  ProfileViewController.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/05/06.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Firebase

class ProfileViewController: UIViewController , ShopModelDelegate{
    
    
    var scrollView : UIScrollView!
    
    var bigItemTableView = UITableView()
    var bigItemDelegate = BigItemTableViewDelegate()
    
    var UID : String?
    var personDetail : PersonDetailInfo?
    
    var currentScrollHeignt : CGFloat = 0
    
    var photo : UIImageView = UIImageView()
    var photoIndicatorViews : [UIView] = []
    var photosContainer : [UIImage] = []
    var currentPhotoNumber : Int = 0
    
    let customTopBarKit = CustomTopBarKit()
    
    let shopModel = ShopModel()
    
    let actionSheetKit = ActionSheetKit()
    
    
    init(UID: String) {
        self.UID = UID
        super.init(nibName: nil, bundle: nil)
    }
    
    init(personDetail: PersonDetailInfo) {
        self.personDetail = personDetail
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //隐藏狀態欄
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hidesBottomBarWhenPushed = true
        //        overrideUserInterfaceStyle = .dark
        setBackground()
        
        if personDetail != nil{
            configScrollContent()
            configProfileTopBar()
        }else{
            customTopBarKit.CreatTopBar(view: view)
            customTopBarKit.getGobackBtn().addTarget(self, action: #selector(gobackBtnAct), for: .touchUpInside)
            if let UserID = UID{
                let ref = Database.database().reference()
                ref.child("PersonDetail/" + UserID).observeSingleEvent(of: .value, with:{(snapshot) in
                    if snapshot.exists(){
                        self.personDetail = PersonDetailInfo(snapshot: snapshot)
                        self.configScrollContent()
                        self.configProfileTopBar()
                        
                        
                    }
                })
            }
        }
        
        creatReportActionSheet()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
    }
    
    
    fileprivate func setBackground() {
        
        let bgKit = CustomBGKit()
        bgKit.CreatParchmentBG(view: view)
        scrollView = bgKit.GetScrollView()
        scrollView.isScrollEnabled = true
        scrollView.bounces = false
        
    }
    
    fileprivate func configProfileTopBar() {
        customTopBarKit.CreatTopBar(view: view)
        customTopBarKit.CreatCenterTitle(text: personDetail!.name)
        customTopBarKit.CreatMailBtn(personDetailInfo: personDetail!)
        customTopBarKit.getGobackBtn().addTarget(self, action: #selector(gobackBtnAct), for: .touchUpInside)
    }
    
    
    fileprivate func creatReportActionSheet() {
        let actionSheetText = ["取消","這是假帳號","盜用他人圖片","照片與自我介紹俱不恰當內容"]
        actionSheetKit.creatActionSheet(containerView: view, actionSheetText: actionSheetText)
        actionSheetKit.getActionSheetBtn(i: 1)?.addTarget(self, action: #selector(isFakeAccountAct), for: .touchUpInside)
        actionSheetKit.getActionSheetBtn(i: 2)?.addTarget(self, action: #selector(useOtherOnePhotoAct), for: .touchUpInside)
        actionSheetKit.getActionSheetBtn(i: 3)?.addTarget(self, action: #selector(HasInappropriateInfoAct), for: .touchUpInside)
    }
    
    
    fileprivate func configScrollContent() {
        
        let photoWidth : CGFloat = view.frame.width -  76
        
        let photoTopMargin : CGFloat = 20
        
        if let urls = personDetail!.photos {
            let photoLoadingView = UIView(frame: CGRect(x: 38 + photoWidth/4, y: photoTopMargin + photoWidth/4, width: photoWidth/2, height: photoWidth/2))
            photoLoadingView.setupToLoadingView()
            scrollView.addSubview(photoLoadingView)
            for i in 0 ... urls.count - 1{
                photosContainer.append(UIImage())
                AF.request(urls[i]).response { (response) in
                    guard let data = response.data, let image = UIImage(data: data)
                    else {
                        return }
                    self.photosContainer[i] = image
                    self.photo.image = self.photosContainer[self.currentPhotoNumber]
                }
            }
        }
        
        if photosContainer.count > 0 {
            photo = { () -> UIImageView in
                let imageView = UIImageView()
                imageView.frame = CGRect(x: 38, y: photoTopMargin, width: photoWidth, height: photoWidth)
                imageView.contentMode = .scaleAspectFill
                imageView.backgroundColor = .clear
                imageView.image = photosContainer[0]
                imageView.layer.cornerRadius = 12
                imageView.clipsToBounds = true
                return imageView
            }()
            scrollView.addSubview(photo)
            currentScrollHeignt = (photo.frame.minY + photoWidth)
            
            if photosContainer.count > 1 {
                for i in 0 ... photosContainer.count - 1 {
                    let indicatorView = UIView()
                    let width = (photo.frame.width - 16 - CGFloat(photosContainer.count - 1) * 2 )/CGFloat(photosContainer.count)
                    indicatorView.frame = CGRect(x:8 + CGFloat(i) * (2 + width), y: 4, width: width, height: 2)
                    indicatorView.backgroundColor = .white
                    indicatorView.layer.cornerRadius = 2
                    indicatorView.alpha = 0.4
                    photoIndicatorViews.append(indicatorView)
                    photo.addSubview(indicatorView)
                }
                photoIndicatorViews[0].alpha = 1
            }
            let photoLeftBtn = { () -> UIButton in
                let btn = UIButton()
                btn.frame = CGRect(x: 38, y: photo.frame.minY, width: (view.frame.width -  38 * 2)/2, height: view.frame.width -  38 * 2)
                btn.addTarget(self, action: #selector(photoLeftBtnAct), for: .touchUpInside)
                return btn
            }()
            scrollView.addSubview(photoLeftBtn)
            
            let photoRightBtn = { () -> UIButton in
                let btn = UIButton()
                btn.frame = CGRect(x: 38 + (view.frame.width -  38 * 2)/2, y: photo.frame.minY, width: (view.frame.width -  38 * 2)/2, height: view.frame.width -  38 * 2)
                btn.addTarget(self, action: #selector(photoRightBtnAct), for: .touchUpInside)
                return btn
            }()
            scrollView.addSubview(photoRightBtn)
        }
        
        let selfIntroductionLabel = { () -> UILabel in
            let label = UILabel()
            label.text = personDetail!.selfIntroduction
            label.textColor = UIColor.hexStringToUIColor(hex: "000000")
            label.font = UIFont(name: "HelveticaNeue", size: 14)
            label.frame = CGRect(x: 38, y: currentScrollHeignt + 25, width: photoWidth, height: 0)
            label.numberOfLines = 0
            label.sizeToFit()
            return label
        }()
        scrollView.addSubview(selfIntroductionLabel)
        
        if personDetail!.UID == UserSetting.UID{
            return
        }
        
        let reportBtn = { () -> UIButton in
            let btn = UIButton()
            btn.frame = CGRect(x: view.frame.width - 38 - 20, y:currentScrollHeignt + 8, width: 20, height: 20)
            let icon = UIImage(named: "reportIcon")?.withRenderingMode(.alwaysTemplate)
            btn.setImage(icon, for: .normal)
            btn.tintColor = UIColor.hexStringToUIColor(hex: "#751010")
            btn.contentMode = .center
            btn.addTarget(self, action: #selector(reportBtnAct), for: .touchUpInside)
            return btn
        }()
        scrollView.addSubview(reportBtn)
        
        currentScrollHeignt += 20
        currentScrollHeignt += selfIntroductionLabel.frame.height
        
        shopModel.viewDelegate = self
        shopModel.personInfo = personDetail!
        
        //製作書籤
        var title : [String] = []
        if personDetail!.sellItems.count > 0{
            title.append("擺攤")
        }
        if personDetail!.buyItems.count > 0{
            title.append("任務")
        }
        if title.count == 0 {
            return
        }
        
        let bookMarkContainerView = UIView()
        bookMarkContainerView.frame = CGRect(x: 0, y: selfIntroductionLabel.frame.maxY + 20, width: view.frame.width, height: 44)
        let bookMarkKit = CustomBookMarkKit(title:title, containerView: bookMarkContainerView)
        
        for i in 0 ... title.count - 1 {
            if title[i] == "擺攤"{
                bookMarkKit.titleBtns[i].addTarget(self, action: #selector(bookMarkAct_OpenStore), for: .touchUpInside)
            }else if title[i] == "任務"{
                bookMarkKit.titleBtns[i].addTarget(self, action: #selector(bookMarkAct_Request), for: .touchUpInside)
            }
        }
        shopModel.customBookMarkKit = bookMarkKit
        scrollView.addSubview(bookMarkContainerView)
        
        currentScrollHeignt += 20
        currentScrollHeignt += bookMarkContainerView.frame.height
        
        
        bigItemDelegate.personDetail = shopModel.personInfo
        bigItemDelegate.currentItemType = shopModel.currentItemType
        bigItemTableView = UITableView()
        bigItemTableView.frame = CGRect(x: 0, y: bookMarkContainerView.frame.maxY, width: view.frame.width, height: CGFloat(110 * personDetail!.sellItems.count))
        bigItemTableView.delegate = bigItemDelegate
        bigItemTableView.dataSource = bigItemDelegate
        bigItemTableView.showsVerticalScrollIndicator = false
        bigItemTableView.register(BigItemTableViewCell.self, forCellReuseIdentifier: "bigItemTableViewCell")
        bigItemTableView.rowHeight = 110
        bigItemTableView.estimatedRowHeight = 0
        bigItemTableView.backgroundColor = .clear
        bigItemTableView.separatorColor = .clear
        bigItemTableView.separatorInset = .zero
        scrollView.addSubview(bigItemTableView)
        
        currentScrollHeignt += bigItemTableView.frame.height
        scrollView.contentSize = CGSize(width: view.frame.width, height: currentScrollHeignt)
        shopModel.currentItemType = .Sell
    }
    
    
    @objc private func photoLeftBtnAct(){
        
        if currentPhotoNumber - 1 >= 0{
            currentPhotoNumber -= 1
            photo.image = photosContainer[currentPhotoNumber]
            
            for indicator in photoIndicatorViews{
                indicator.alpha = 0.4
            }
            photoIndicatorViews[currentPhotoNumber].alpha = 1
        }
        self.view.endEditing(true)
        
        
    }
    @objc private func photoRightBtnAct(){
        
        if currentPhotoNumber + 1 < photosContainer.count{
            currentPhotoNumber += 1
            photo.image = photosContainer[currentPhotoNumber]
            
            for indicator in photoIndicatorViews{
                indicator.alpha = 0.4
            }
            photoIndicatorViews[currentPhotoNumber].alpha = 1
        }
        self.view.endEditing(true)
    }
    
    
    @objc private func reportBtnAct(){
        actionSheetKit.allBtnSlideIn()
    }
    
    
    @objc private func gobackBtnAct(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func bookMarkAct_OpenStore(){
        currentScrollHeignt -= bigItemTableView.frame.height
        bigItemTableView.frame = CGRect(x: bigItemTableView.frame.minX, y: bigItemTableView.frame.minY, width: bigItemTableView.frame.width, height: CGFloat(110 * personDetail!.sellItems.count))
        currentScrollHeignt += bigItemTableView.frame.height
        scrollView.contentSize = CGSize(width: view.frame.width, height: currentScrollHeignt)
        shopModel.currentItemType = .Sell
    }
    @objc private func bookMarkAct_Request(){
        currentScrollHeignt -= bigItemTableView.frame.height
        bigItemTableView.frame = CGRect(x: bigItemTableView.frame.minX, y: bigItemTableView.frame.minY, width: bigItemTableView.frame.width, height: CGFloat(110 * personDetail!.buyItems.count))
        currentScrollHeignt += bigItemTableView.frame.height
        scrollView.contentSize = CGSize(width: view.frame.width, height: currentScrollHeignt)
        shopModel.currentItemType = .Buy
    }
    //假帳號
    @objc private func isFakeAccountAct(){
        let ref = Database.database().reference().child("Report/" + personDetail!.UID + "/Person/" + UserSetting.UID)
        ref.setValue("Fake")
        self.showToast(message: "已回報", font: .systemFont(ofSize: 14.0))
    }
    @objc private func useOtherOnePhotoAct(){
        let ref = Database.database().reference().child("Report/" + personDetail!.UID + "/Person/" + UserSetting.UID)
        ref.setValue("OtherPhoto")
        self.showToast(message: "已回報", font: .systemFont(ofSize: 14.0))
    }
    @objc private func HasInappropriateInfoAct(){
        let ref = Database.database().reference().child("Report/" + personDetail!.UID + "/Person/" + UserSetting.UID)
        ref.setValue("Inappropriate")
        self.showToast(message: "已回報", font: .systemFont(ofSize: 14.0))
    }
    
    //MARK:- ShopModelDelegate
    
    func stopLoadingView() {
        
    }
    
    func reloadTableView() {
        bigItemDelegate.currentItemType = shopModel.currentItemType
        bigItemTableView.reloadData()
    }
    
    func reloadTableView(indexPath: IndexPath) {
        bigItemDelegate.currentItemType = shopModel.currentItemType
        self.bigItemTableView.reloadRows(at: [indexPath], with: .none)
        if let bigItemCell = self.bigItemTableView.cellForRow(at: indexPath) as? BigItemTableViewCell{
            bigItemCell.photo.alpha = 0
            UIView.animate(withDuration: 0.4, animations: {
                bigItemCell.photo.alpha = 1
                bigItemCell.viewWithTag(1)?.alpha = 0
                bigItemCell.viewWithTag(2)?.alpha = 0
            })
        }
    }
    
    func updateHeadShot() {
        
    }
    
    
    
    
}
