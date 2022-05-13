//
//  ItemViewController.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/04/18.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//



import UIKit
import Alamofire
import Firebase

class ItemViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UITextViewDelegate {
    
    var item : Item
    var personInfo : PersonDetailInfo?
    let itemOwnerID : String
    
    var photo : UIImageView!
    var photosContainer : [UIImage] = []
    var photoIndicatorViews : [UIView] = []
    var currentPhotoNumber = 0
    
    var commentTableView  =  UITableView()
    
    var scrollView = UIScrollView()
    
    var likeUIDs : [String] = []
    
    var comments : [Comment] = []
    
    var heartImage = UIImageView()
    var heartBtn = UIButton()
    var heartNumberLabel = UILabel()
    
    var heartNumberRef =  Database.database().reference(withPath: "PersonDetail/")
    var heartNumberObserver : UInt!
    
    var commentObserverRef : DatabaseReference!
    var commentObserver : UInt!
    
    var currentScrollHeignt : CGFloat = 0
    
    let customInputBoxKit = CustomInputBoxKit()
    
    let customTopBarKit = CustomTopBarKit()
    
    var commenterHeadShotDict = [String:UIImage]()
    let actionSheetKit = ActionSheetKit()
    
    var userPressLike : Bool = false
    
    //隐藏狀態欄
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    init(item: Item,personInfo : PersonDetailInfo) {
        self.item = item
        self.personInfo = personInfo
        self.itemOwnerID = personInfo.UID
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }
    
    init(item: Item,itemOwnerID:String) {
        self.item = item
        self.itemOwnerID = itemOwnerID
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //loading動畫放在viewDidLoad不會動 但loading動畫我沒有很喜歡 省略
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackground() //含scrollView InputBox
        configScrollContent()
        configTopbar()
        adjustScrollViewContentHeight()
        observeCommentRef()
        creatReportActionSheet()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        customInputBoxKit.addKeyBoardObserver()
    }
    
    fileprivate func creatReportActionSheet() {
        let actionSheetText = ["取消","文章具有不恰當的內容"]
        actionSheetKit.creatActionSheet(containerView: view, actionSheetText: actionSheetText)
        actionSheetKit.getActionSheetBtn(i: 1)?.addTarget(self, action: #selector(HasInappropriateInfoAct), for: .touchUpInside)
    }
    
    
    fileprivate func configTopbar() {
        
        customTopBarKit.CreatTopBar(view: view)
        
        if personInfo != nil{
            self.customTopBarKit.CreatMailBtn(personDetailInfo: personInfo!)
        }else {
            let ref = Database.database().reference(withPath: "PersonDetail/" + "\(itemOwnerID)")
            ref.observeSingleEvent(of: .value,  with: {(snapshot) in
                if snapshot.exists(){
                    self.customTopBarKit.CreatMailBtn(personDetailInfo: PersonDetailInfo(snapshot: snapshot))
                }
            })
        }
        let gobackBtn = customTopBarKit.getGobackBtn()
        gobackBtn.addTarget(self, action: #selector(gobackBtnAct), for: .touchUpInside)
        
        
//        if itemOwnerID != UserSetting.UID {
            customTopBarKit.CreatMoreBtn()
            let moreBtn = customTopBarKit.getMoreBtn()
            moreBtn.addTarget(self, action: #selector(reportBtnAct), for: .touchUpInside)
//        }
    }
    
    fileprivate func observeCommentRef() {
        
        item.commentIDs = [] //先清空，之後監控時，再一個一個加入，讓回去上個畫面時也能刷新
        
        commentObserverRef = Database.database().reference(withPath: "Comment/" + item.itemID!)
        
        commentObserver = commentObserverRef.queryOrdered(byChild: "time").observe(.childAdded, with: { (snapshot) in
            
            var comment = Comment(snapshot: snapshot)
            if(comment.UID == "錯誤"){
                return
            }
            comment.commentID = snapshot.key
            self.item.commentIDs?.append(snapshot.key as String)
            
            if let childSnapshots = snapshot.childSnapshot(forPath: "likeUIDs").children.allObjects as? [DataSnapshot]{
                comment.likeUIDs = []
                for childSnapshot in childSnapshots{
                    comment.likeUIDs!.append(childSnapshot.key as String)
                }
            }
            
            self.commentTableView.beginUpdates()
            
            self.comments.append(comment)
            let index = self.comments.count - 1
            //插入新的comment時，先確認是否smallHeadshot已經下載了
            if self.commenterHeadShotDict[self.comments[index].UID] != nil && self.commenterHeadShotDict[self.comments[index].UID] != UIImage(named: "Thumbnail"){
                self.comments[index].smallHeadshot = self.commenterHeadShotDict[self.comments[index].UID]
            }
            let indexPath = IndexPath(row: index, section: 0)
            self.commentTableView.insertRows(at: [indexPath], with: .automatic)
            self.commentTableView.endUpdates()
            
            
            //調整tableView跟scrollView高度
            self.commentTableView.invalidateIntrinsicContentSize()
            self.commentTableView.layoutIfNeeded()
            self.currentScrollHeignt -= self.commentTableView.frame.height
            self.commentTableView.frame = CGRect(x: 0, y: self.commentTableView.frame.origin.y, width: self.view.frame.width, height: self.commentTableView.contentSize.height + 10)
            self.currentScrollHeignt += self.commentTableView.contentSize.height
            self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.currentScrollHeignt)
            
            
            //確認是否commenterHeadShot已經抓過圖了
            if self.commenterHeadShotDict[self.comments[index].UID] == nil{
                self.commenterHeadShotDict[self.comments[index].UID] = UIImage(named: "Thumbnail") //這只是隨便一張圖，來確認是否下載過了
                //去storage那邊找到URL
                let smallHeadshotRef = Storage.storage().reference().child("userSmallHeadShot/" + self.comments[index].UID)
                smallHeadshotRef.downloadURL(completion: { (url, error) in
                    guard let downloadURL = url else {
                        return
                    }
                    //下載URL的圖
                    AF.request(downloadURL).response { (response) in
                        guard let data = response.data, let image = UIImage(data: data)
                        else { return }
                        //裝進commenterHeadShotDict
                        self.commenterHeadShotDict[self.comments[index].UID] = image
                        
                        //替換掉所有有相同ID的Comment的headShot
                        for i in 0 ... self.comments.count - 1 {
                            if self.comments[i].UID == self.comments[index].UID{
                                let indexPathForSameIDComment = IndexPath(row: i, section: 0)
                                self.comments[i].smallHeadshot = image
                                self.commentTableView.reloadRows(at: [indexPathForSameIDComment], with: .none)
                                let cell = self.commentTableView.cellForRow(at: indexPathForSameIDComment) as! CommentTableViewCell
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
        })
    }
    
    
    fileprivate func adjustScrollViewContentHeight() {
        commentTableView.frame = CGRect(x: 0, y: currentScrollHeignt + 8, width: view.frame.width, height: commentTableView.contentSize.height)
        currentScrollHeignt += (8 + commentTableView.contentSize.height + view.frame.height * 2/3) //view.frame.height * 2/3是留給鍵盤的空間
        scrollView.contentSize = CGSize(width: view.frame.width, height: currentScrollHeignt)
    }
    
    
    //observe likeUIDs 並替換heartNumber.text
    fileprivate func observeHeartNumber(_ heartNumber: UILabel) {
        
        if item.itemType == .Sell{
            heartNumberRef =  Database.database().reference(withPath: "PersonDetail/" + itemOwnerID + "/SellItems/" + item.itemID! + "/likeUIDs")
        }else if item.itemType == .Buy{
            heartNumberRef =  Database.database().reference(withPath: "PersonDetail/" + itemOwnerID + "/BuyItems/" + item.itemID! + "/likeUIDs")
        }
        
        heartNumberObserver = heartNumberRef.observe(.childAdded, with: { (snapshot) in
            var notExist = true
            for likeUID in self.likeUIDs{
                if likeUID == snapshot.key{
                    notExist = false
                }
            }
            if notExist{
                self.likeUIDs.append(snapshot.key)
            }
            heartNumber.text = "\(self.likeUIDs.count)"
            
            for likeUID in self.likeUIDs{
                if likeUID == UserSetting.UID{
                    self.heartImage.image = UIImage(named: "實愛心")?.withRenderingMode(.alwaysTemplate)
                    self.userPressLike = true
                }
            }
        })
    }
    
    fileprivate func configScrollContent() {
        
        let photoWidth : CGFloat = view.frame.width
        let photoTopMargin : CGFloat = 0
        
        if let urls = item.photosUrl,urls.count != 0{
            var getPhotoNumber = 0
            for i in 0 ... urls.count - 1{
                photosContainer.append(UIImage())
                AF.request(urls[i]).response { (response) in
                    guard let data = response.data, let image = UIImage(data: data)
                    else {
                        getPhotoNumber += 1
                        return }
                    self.photosContainer[i] = image
                    self.photo.image = self.photosContainer[self.currentPhotoNumber]
                    
                    getPhotoNumber += 1
                    if getPhotoNumber == urls.count{
                        UIView.animate(withDuration: 0.3, animations: {
                            self.photo.alpha = 1
                            
                        })
                    }
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
                imageView.alpha = 0
                return imageView
            }()
            scrollView.addSubview(photo)
            
            currentScrollHeignt = photoTopMargin + photoWidth
            
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
                btn.frame = CGRect(x: 0, y: photo.frame.minY, width: (view.frame.width)/2, height: view.frame.width)
                btn.addTarget(self, action: #selector(photoLeftBtnAct), for: .touchUpInside)
                return btn
            }()
            scrollView.addSubview(photoLeftBtn)
            
            let photoRightBtn = { () -> UIButton in
                let btn = UIButton()
                btn.frame = CGRect(x: view.frame.width/2, y: photo.frame.minY , width: view.frame.width/2, height: view.frame.width)
                btn.addTarget(self, action: #selector(photoRightBtnAct), for: .touchUpInside)
                return btn
            }()
            scrollView.addSubview(photoRightBtn)
        }else{
            currentScrollHeignt = 50
        }
        
        let itemNameLabel = { () -> UILabel in
            let label = UILabel()
            label.text = item.name
            label.textColor = .on().withAlphaComponent(0.9)
            label.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
            label.frame = CGRect(x: 24, y: currentScrollHeignt + 8, width: photoWidth - 20 - 3, height: 0)
            label.numberOfLines = 0
            label.sizeToFit()
            return label
        }()
        scrollView.addSubview(itemNameLabel)
        
    
        currentScrollHeignt += (8 + itemNameLabel.frame.height)
        
        
        let priceLabel = { () -> UILabel in
            let label = UILabel()
            
            if item.itemType == .Buy{
                label.text = "Price：" + "\(item.price)"
            }else if item.itemType == .Sell{
                label.text = "Price：" + "\(item.price)"
            }
            label.textColor = .on().withAlphaComponent(0.7)
            label.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
            label.frame = CGRect(x: 24, y: currentScrollHeignt + 4, width: photoWidth - 42, height: 0)
            label.numberOfLines = 0
            label.sizeToFit()
            return label
        }()
        scrollView.addSubview(priceLabel)
        
        currentScrollHeignt += (4 + priceLabel.frame.height)
        
        let itemDescriptLabel = { () -> UILabel in
            let label = UILabel()
            label.text = item.descript
            label.textColor = .on().withAlphaComponent(0.9)
            label.font = UIFont(name: "HelveticaNeue", size: 14)
            label.frame = CGRect(x: 24, y: currentScrollHeignt + 8, width: photoWidth, height: 0)
            label.numberOfLines = 0
            label.sizeToFit()
            return label
        }()
        scrollView.addSubview(itemDescriptLabel)
        
        currentScrollHeignt += (8 + itemDescriptLabel.frame.height)
        
        
        heartImage = { () -> UIImageView in
            let imageView = UIImageView()
            imageView.image = UIImage(named: "空愛心")?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = .primary()
            imageView.frame = CGRect(x:25, y:currentScrollHeignt + 8, width: 22, height: 20)
            return imageView
        }()
        scrollView.addSubview(heartImage)
        
        
        heartBtn = { () -> UIButton in
            let btn = UIButton()
            btn.frame = CGRect(x: 25, y: currentScrollHeignt + 8 - 15, width: 50, height: 50)
            btn.addTarget(self, action: #selector(heartBtnAct), for: .touchUpInside)
            btn.isEnabled = true
            return btn
        }()
        scrollView.addSubview(heartBtn)
        
        heartNumberLabel = { () -> UILabel in
            let label = UILabel()
            label.text = "0"
            label.textColor = .primary()
            label.font = UIFont(name: "HelveticaNeue", size: 14)
            label.frame = CGRect(x: 25 + 22 + 5, y: currentScrollHeignt + 8 + 20/2 - label.intrinsicContentSize.height/2 - 1, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            return label
        }()
        scrollView.addSubview(heartNumberLabel)
        
        
        
        observeHeartNumber(heartNumberLabel)
        
        currentScrollHeignt += 28
        
        commentTableView.delegate = self
        commentTableView.dataSource = self
        commentTableView.frame = CGRect(x: 0, y: currentScrollHeignt + 8, width: view.frame.width, height: view.frame.height)
        commentTableView.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "commentTableViewCell")
        commentTableView.backgroundColor = .clear
        commentTableView.separatorColor = .clear
        commentTableView.allowsSelection = false
        commentTableView.bounces = false
        commentTableView.isScrollEnabled = false
        commentTableView.rowHeight = UITableView.automaticDimension
        commentTableView.estimatedRowHeight = 54.0
        
        
        scrollView.addSubview(commentTableView)
        
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
        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        scrollView.addGestureRecognizer(scrollViewTap)
        view.addSubview(scrollView)
    
        
        customInputBoxKit.customInputBoxKitDelegate = self
        customInputBoxKit.creatView(containerView:view)
    }
    
    //MARK: - TableViewDelegate
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentTableViewCell", for: indexPath) as! CommentTableViewCell
        
        cell.UID = comments[indexPath.row].UID
        cell.genderIcon.frame = cell.photo.frame
        cell.genderIcon.contentMode = .scaleAspectFit
        cell.genderIcon.tag = 1
        if comments[indexPath.row].gender == 0{
            cell.genderIcon.image = UIImage(named: "girlIcon")?.withRenderingMode(.alwaysTemplate)
        }else if comments[indexPath.row].gender == 1{
            cell.genderIcon.image = UIImage(named: "boyIcon")?.withRenderingMode(.alwaysTemplate)
        }
        cell.genderIcon.tintColor = .lightGray
        cell.addSubview(cell.genderIcon)
        cell.sendSubviewToBack(cell.genderIcon)
        
        if comments[indexPath.row].smallHeadshot != nil{
            //girlIcon和boyIcon需要Fit,照片需要Fill
            cell.photo.image =  comments[indexPath.row].smallHeadshot
            cell.photo.contentMode = .scaleAspectFill
            cell.photo.alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                cell.photo.alpha = 1
                cell.genderIcon.alpha = 0
            })
        }
        
        if comments[indexPath.row].likeUIDs!.count < 100{
            cell.heartNumberLabel.text = "\(comments[indexPath.row].likeUIDs!.count)"
        }else{
            cell.heartNumberLabel.text = "99+"
        }
        
        cell.heartImage.image = UIImage(named: "空愛心")?.withRenderingMode(.alwaysTemplate)
        for likeUID in comments[indexPath.row].likeUIDs!{
            if likeUID == UserSetting.UID{
                cell.heartImage.image = UIImage(named: "實愛心")?.withRenderingMode(.alwaysTemplate)
                cell.userPressLike = true
            }
        }
        
        let currentTime = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMddHHmmss"
        var currentTimeString = dateFormatter.string(from: currentTime)
        
        let commmentTime = dateFormatter.date(from: comments[indexPath.row].time)!
        
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
        
        cell.nameLabel.text = comments[indexPath.row].name + " - " + finalTimeString
        cell.commentLabel.text = comments[indexPath.row].content
        cell.commentID = comments[indexPath.row].commentID!
        cell.itemID = item.itemID!
        
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
    
    
    //MARK: - BtnAct
    
    @objc fileprivate func heartBtnAct(){
        
        
        Analytics.logEvent("貼文頁_喜歡", parameters:nil)
        
        let ref = Database.database().reference()
        var likeRef = ref.child("PersonDetail")
        
        let itemID = item.itemID!
        if item.itemType == .Sell{
            likeRef = ref.child("PersonDetail/" + itemOwnerID + "/SellItems/" + itemID +  "/likeUIDs/" + UserSetting.UID)
        }else if item.itemType == .Buy{
            likeRef = ref.child("PersonDetail/" +  itemOwnerID + "/BuyItems/" + itemID + "/likeUIDs/" + UserSetting.UID)
        }
        
        if !userPressLike{
            heartImage.image = UIImage(named: "實愛心")?.withRenderingMode(.alwaysTemplate)
            likeRef.setValue(UserSetting.UID)
            heartNumberLabel.text =  "\(Int(heartNumberLabel.text!)! + 1)"
            item.likeUIDs?.append(UserSetting.UID)
            userPressLike = true
        }else{
            heartImage.image = UIImage(named: "空愛心")?.withRenderingMode(.alwaysTemplate)
            likeRef.removeValue()
            heartNumberLabel.text =  "\(Int(heartNumberLabel.text!)! - 1)"
            userPressLike = false            
            
            if let likeUIDs = item.likeUIDs{
                if let index = likeUIDs.firstIndex(of: UserSetting.UID){
                    item.likeUIDs?.remove(at: index)
                }
            }
        }
    }
    
    
    @objc private func gobackBtnAct(){
        
        //取消訂閱
        heartNumberRef.removeObserver(withHandle: heartNumberObserver)
        commentObserverRef.removeObserver(withHandle: commentObserver)
        
        self.navigationController?.popViewController(animated: true)
        
    }
    @objc private func reportBtnAct(){
        Analytics.logEvent("貼文頁_檢舉", parameters:nil)
        actionSheetKit.allBtnSlideIn()
    }
    
    @objc private func photoLeftBtnAct(){
        Analytics.logEvent("貼文頁_左切照片", parameters:nil)
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
        Analytics.logEvent("貼文頁_右切照片", parameters:nil)
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
    
    @objc private func HasInappropriateInfoAct(){
        Analytics.logEvent("貼文頁_檢舉_不恰當內容", parameters:nil)
        let ref = Database.database().reference().child("Report/" + itemOwnerID + "/Item/" + item.itemID! + "/" + UserSetting.UID)
        ref.setValue("Inappropriate")
        self.showToast(message: "已回報", font: .systemFont(ofSize: 14.0))
//        fatalError()
    }
    
    //點擊空白處結束edit
    @objc func scrollViewTapped() {
        self.view.endEditing(true)
    }
    
    @objc private func mailBtnAct(){
        customInputBoxKit.removeKeyBoardObserver()
    }
    
    
}

//MARK:- CustomInputBoxKitDelegate

extension ItemViewController : CustomInputBoxKitDelegate{
    func addBtnAction() {
        
    }
    
    func textViewBeginEditing() {
        let bottomOffset = CGPoint(x: 0, y: currentScrollHeignt - scrollView.bounds.size.height)
        scrollView.setContentOffset(bottomOffset, animated: true)
    }
    
    
    func publishCompletion() {
        
        let commentContent = customInputBoxKit.getInputBoxTextViewText()
        updateCommentToFireBase(commentContent)
        let bottomOffset = CGPoint(x: 0, y: currentScrollHeignt - scrollView.bounds.size.height)
        scrollView.setContentOffset(bottomOffset, animated: true)
    }
    
    fileprivate func updateCommentToFireBase(_ commentContent: String) {
        if commentContent.trimmingCharacters(in: [" "]) != ""{
            
            let commentID = NSUUID().uuidString
            var commentRef : DatabaseReference!
            
            //先上傳Comment本體
            commentRef = Database.database().reference(withPath: "Comment/" + item.itemID! + "/" + commentID)
            let currentTimeString = Date().getCurrentTimeString()
            let comment = Comment(time: currentTimeString, UID: UserSetting.UID, name: UserSetting.userName,
                                  gender: UserSetting.userGender, content: commentContent, likeUIDs: nil)
            commentRef.setValue(comment.toAnyObject())
            
            //再更新item裡的commentIDs
            var commentIDRef : DatabaseReference!
            if item.itemType == .Sell{
                commentIDRef = Database.database().reference(withPath: "PersonDetail/" + itemOwnerID + "/SellItems/" + item.itemID! + "/commentIDs/" + commentID)
            }else if item.itemType == .Buy{
                commentIDRef = Database.database().reference(withPath: "PersonDetail/" + itemOwnerID + "/BuyItems/" + item.itemID! + "/commentIDs/" + commentID)
            }
            commentIDRef.setValue(UserSetting.userName)
            
            //更新item裡面的subscribedIDs
            if item.subscribedIDs?.firstIndex(of: UserSetting.UID) == nil || item.subscribedIDs == nil{
                var subscribedIDRef : DatabaseReference!
                if item.itemType == .Sell{
                    subscribedIDRef = Database.database().reference(withPath: "PersonDetail/" + itemOwnerID + "/SellItems/" + item.itemID! + "/subscribedIDs/" + UserSetting.UID)
                }else if item.itemType == .Buy{
                    subscribedIDRef = Database.database().reference(withPath: "PersonDetail/" + itemOwnerID + "/BuyItems/" + item.itemID! + "/subscribedIDs/" + UserSetting.UID)
                }
                subscribedIDRef.setValue(UserSetting.userName)
                item.subscribedIDs?.append(UserSetting.UID)
            }
            
        }
    }
    
}
