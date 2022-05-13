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
    
    var bookMarks_segmented = SSSegmentedControl(items: [],type: .pure)
    var bookMarks : [String] = []
    
    let bookMarkName_Sell = "擺攤"
    let bookMarkName_Buy = "徵求"
    
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
        
        view.backgroundColor = .surface()
        
        let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top ?? 0
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0 + topPadding, width: view.frame.width, height: view.frame.height - topPadding))
        scrollView.contentSize = CGSize(width: view.frame.width,height: view.frame.height)
        view.addSubview(scrollView)
        scrollView.isScrollEnabled = true
        scrollView.bounces = false
        view.addSubview(scrollView)
        
    }
    
    fileprivate func configProfileTopBar() {
        customTopBarKit.CreatTopBar(view: view)
#if FACETRADER
        customTopBarKit.CreatMailBtn(personDetailInfo: personDetail!)
#endif
        customTopBarKit.getGobackBtn().addTarget(self, action: #selector(gobackBtnAct), for: .touchUpInside)
        
        if personDetail!.UID != UserSetting.UID{
            customTopBarKit.CreatMoreBtn()
            customTopBarKit.getMoreBtn().addTarget(self, action: #selector(reportBtnAct), for: .touchUpInside)
        }
    }
    
    
    fileprivate func creatReportActionSheet() {
        let actionSheetText = ["取消","這是假帳號","盜用他人圖片","照片與自我介紹俱不恰當內容"]
        actionSheetKit.creatActionSheet(containerView: view, actionSheetText: actionSheetText)
        actionSheetKit.getActionSheetBtn(i: 1)?.addTarget(self, action: #selector(isFakeAccountAct), for: .touchUpInside)
        actionSheetKit.getActionSheetBtn(i: 2)?.addTarget(self, action: #selector(useOtherOnePhotoAct), for: .touchUpInside)
        actionSheetKit.getActionSheetBtn(i: 3)?.addTarget(self, action: #selector(HasInappropriateInfoAct), for: .touchUpInside)
    }
    
    
    fileprivate func configScrollContent() {
        
        let photoWidth : CGFloat = view.frame.width
        let photoTopMargin : CGFloat = 0
        
        if let urls = personDetail!.photos {
            let photoLoadingView = UIView(frame: CGRect(x: photoWidth/4, y: photoTopMargin + photoWidth/4, width: photoWidth/2, height: photoWidth/2))
            photoLoadingView.setupToLoadingView()
            scrollView.addSubview(photoLoadingView)
            for i in 0 ... urls.count - 1{
                photosContainer.append(UIImage())
                AF.request(urls[i]).response { (response) in
                    guard let data = response.data, let image = UIImage(data: data)
                    else {
                        return }
                    self.photosContainer[i] = image
                    self.photo.alpha = 0
                    self.photo.image = self.photosContainer[self.currentPhotoNumber]
                    UIView.animate(withDuration: 0.3, animations: {
                        self.photo.alpha = 1
                    })
                }
            }
        }
        
        if photosContainer.count > 0 {
            photo = { () -> UIImageView in
                let imageView = UIImageView()
                imageView.frame = CGRect(x: 0, y: photoTopMargin, width: photoWidth, height: photoWidth)
                imageView.contentMode = .scaleAspectFill
                imageView.backgroundColor = .clear
                imageView.image = photosContainer[0]
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
                btn.frame = CGRect(x: 0, y: photo.frame.minY, width: view.frame.width/2, height: view.frame.width)
                btn.addTarget(self, action: #selector(photoLeftBtnAct), for: .touchUpInside)
                return btn
            }()
            scrollView.addSubview(photoLeftBtn)
            
            let photoRightBtn = { () -> UIButton in
                let btn = UIButton()
                btn.frame = CGRect(x: view.frame.width/2, y: photo.frame.minY, width: view.frame.width/2, height: view.frame.width)
                btn.addTarget(self, action: #selector(photoRightBtnAct), for: .touchUpInside)
                return btn
            }()
            scrollView.addSubview(photoRightBtn)
        }
        
        let nameLabel = UILabel()
        nameLabel.font = UIFont(name: "HelveticaNeue", size: 24)
        nameLabel.textColor = .on()
        nameLabel.text = personDetail!.name
        nameLabel.frame = CGRect(x: 16, y: currentScrollHeignt + 16, width: nameLabel.intrinsicContentSize.width, height: nameLabel.intrinsicContentSize.height)
        scrollView.addSubview(nameLabel)
        
        //年齡
        let ageLabel = UILabel()
        ageLabel.font = UIFont(name: "HelveticaNeue", size: 24)
        ageLabel.textColor = .on()
        let birthdayFormatter = DateFormatter()
        birthdayFormatter.dateFormat = "yyyy/MM/dd"
        let currentTime = Date()
        let birthDayDate = birthdayFormatter.date(from: personDetail!.birthday)
        let age = currentTime.years(sinceDate: birthDayDate!) ?? 0
        if age != 0 {
            ageLabel.text = "\(age)"
        }
        ageLabel.frame = CGRect(x: 16 + nameLabel.intrinsicContentSize.width + 8, y: currentScrollHeignt + 16, width: nameLabel.intrinsicContentSize.width, height: nameLabel.intrinsicContentSize.height)
        scrollView.addSubview(ageLabel)
        
        var scoreCount = 0
        var scoreTotalAmount = 0
        for (key,value) in personDetail!.sharedSeatScore{
            let score = value
            if(score != 0){
                scoreTotalAmount += score
                scoreCount += 1
            }
        }
        var averageScore : Float = 0
        if(scoreCount != 0){
            averageScore = Float(scoreTotalAmount)/Float(scoreCount)
        }
        let scoreLabel = UILabel()
        scoreLabel.font = UIFont(name: "HelveticaNeue", size: 18)
        scoreLabel.textColor = .on().withAlphaComponent(0.7)
        scoreLabel.text = String(format: "%.1f", averageScore) + " (" + "\(scoreCount)" + "人)"
        scoreLabel.frame = CGRect(x: view.frame.width - 16 - scoreLabel.intrinsicContentSize.width, y: nameLabel.frame.origin.y + 3.5, width: scoreLabel.intrinsicContentSize.width, height: scoreLabel.intrinsicContentSize.height)
        scrollView.addSubview(scoreLabel)
        
        let starImageView : UIImageView = {
            let imageView = UIImageView()
            imageView.frame = CGRect(x: view.frame.width - 20 - 16 - scoreLabel.intrinsicContentSize.width - 4, y: nameLabel.frame.origin.y + 3.5, width: 20, height: 20)
            imageView.contentMode = .scaleAspectFill
            imageView.backgroundColor = .clear
            imageView.tintColor = UIColor.hexStringToUIColor(hex: "#FBBC05")
            imageView.clipsToBounds = true
            imageView.image = UIImage(named: "FullStar")?.withRenderingMode(.alwaysTemplate)
            return imageView
        }()
        scrollView.addSubview(starImageView)
        
        let scoreBtn : UIButton = {
            let btn = UIButton()
            btn.frame = CGRect(x: starImageView.frame.origin.x, y: starImageView.frame.origin.y, width: 20 + scoreLabel.intrinsicContentSize.width + 4, height: scoreLabel.intrinsicContentSize.height)
            btn.addTarget(self, action: #selector(goScorePageBtnAct), for: .touchUpInside)
            return btn
        }()
        scrollView.addSubview(scoreBtn)
        
        
        currentScrollHeignt += 16
        currentScrollHeignt += nameLabel.frame.height
        
        let selfIntroductionLabel = { () -> UILabel in
            let label = UILabel()
            label.text = personDetail!.selfIntroduction
            label.textColor = .on().withAlphaComponent(0.7)
            label.font = UIFont(name: "HelveticaNeue", size: 14)
            label.frame = CGRect(x: 16, y: currentScrollHeignt + 16, width: photoWidth - 32, height: 0)
            label.numberOfLines = 0
            label.sizeToFit()
            return label
        }()
        scrollView.addSubview(selfIntroductionLabel)
        
        if personDetail!.UID == UserSetting.UID{
            return
        }
        
        currentScrollHeignt += 16
        currentScrollHeignt += selfIntroductionLabel.frame.height
        
#if VERYINCORRECT
        return
#endif
        
        shopModel.viewDelegate = self
        shopModel.personInfo = personDetail!
        
        //製作書籤
        
        
        bookMarks = []
        if personDetail!.sellItems.count > 0{
            bookMarks.append("擺攤")
        }
        if personDetail!.buyItems.count > 0{
            bookMarks.append("徵求")
        }
        if bookMarks.count == 0 {
            return
        }
        
        //做出書頁標籤
        bookMarks_segmented = SSSegmentedControl(items: bookMarks,type: .pure)
        bookMarks_segmented.translatesAutoresizingMaskIntoConstraints = false
        bookMarks_segmented.selectedSegmentIndex = 0
        scrollView.addSubview(bookMarks_segmented)
        bookMarks_segmented.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        bookMarks_segmented.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: selfIntroductionLabel.frame.maxY + 20).isActive = true
        bookMarks_segmented.widthAnchor.constraint(equalToConstant: CGFloat(80 * bookMarks.count)).isActive = true
        bookMarks_segmented.heightAnchor.constraint(equalToConstant: 30).isActive = true
        bookMarks_segmented.addTarget(self, action: #selector(segmentedOnValueChanged), for: .valueChanged)
        
        
    
        currentScrollHeignt += 20
        currentScrollHeignt += 30
        
        print("GOGOGO")
        
        var maxCount = personDetail!.sellItems.count
        if(personDetail!.buyItems.count > personDetail!.sellItems.count){
            maxCount = personDetail!.buyItems.count
        }
        
        bigItemDelegate.personDetail = shopModel.personInfo
        bigItemDelegate.currentItemType = shopModel.currentItemType
        bigItemTableView = UITableView()
        bigItemTableView.frame = CGRect(x: 0, y: currentScrollHeignt + 20, width: view.frame.width, height: CGFloat(110 * maxCount))
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
    
    
    @objc func segmentedOnValueChanged(_ segmented: UISegmentedControl) {
        
        if(bookMarks[segmented.selectedSegmentIndex] == bookMarkName_Sell){
            bookMarkAct_OpenStore()
        }else if(bookMarks[segmented.selectedSegmentIndex] == bookMarkName_Buy){
            bookMarkAct_Request()
        }
        
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
        dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func goScorePageBtnAct(){
        if(personDetail == nil){
            showToast(message: "資料讀取中，請幾秒後再點擊。")
            return
        }
        let profileScoreViewController = ProfileScoreViewController(personDetail: personDetail!)
        profileScoreViewController.modalPresentationStyle = .overFullScreen
        present(profileScoreViewController, animated: true,completion: nil)
    }
    
    @objc private func bookMarkAct_OpenStore(){
        shopModel.currentItemType = .Sell
    }
    @objc private func bookMarkAct_Request(){
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
