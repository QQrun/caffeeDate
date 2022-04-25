//
//  MailListViewController.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/04/09.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import UserNotifications

protocol MailListViewControllerDelegate: class {
    func gotoChatRoom(chatroomID:String,personDetailInfos: [PersonDetailInfo]?,animated:Bool)
}


class MailListViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    
    
    var mailListTableView = UITableView()
    
    //寄信人的簡單個人資訊
    var mailDatas : [MailData] = []
    
    weak var viewDelegate : MailListViewControllerDelegate?
    
    var customTopBarKit = CustomTopBarKit()
    
    var requestBtn = UIButton()
    
    //一起動App需要先監聽
    override func awakeFromNib() {
        super.awakeFromNib()
        configTableView()
        activeMailListObserver()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("MailListViewController viewDidLoad")
        
        view.backgroundColor = .surface()
        configTopBar()
        //        configTableView()
        //        activeMailListObserver()
        requestNotiAuthorization()
        configMailListTableViewFrame()
        configNotificationRequestBtn()
    }
    
    
    fileprivate func configTopBar() {
        customTopBarKit.CreatTopBar(view: view,showSeparator:true)
        customTopBarKit.showGobackBtn()
        customTopBarKit.getGobackBtn().addTarget(self, action: #selector(gobackBtnAct), for: .touchUpInside)
        customTopBarKit.CreatCenterTitle(text: "訊息")
    }
    
    
    fileprivate func configMailListTableViewFrame() {
        let window = UIApplication.shared.keyWindow
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0
        let topPadding = window?.safeAreaInsets.top ?? 0
        mailListTableView.frame = CGRect(x: 0, y: topPadding + 45, width: view.frame.width, height: view.frame.height - topPadding - bottomPadding - 1)
        view.addSubview(mailListTableView)
    }
    
    fileprivate func requestNotiAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { (settings) in
            if(settings.authorizationStatus == .notDetermined || settings.authorizationStatus == .denied)
            {
                DispatchQueue.main.async {
                    self.view.addSubview(self.requestBtn)
                }
            }
            
        }
    }
    
    fileprivate func configNotificationRequestBtn(){
        requestBtn = {
            let btn = UIButton()
            btn.frame = CGRect(x: 0, y: mailListTableView.frame.maxY - 30 - 45, width: view.frame.width, height: 30)
            let btnColor = UIColor.error
            btn.setBackgroundColor(btnColor, forState: .normal)
            btn.setTitle("尚未開啟通知功能，點擊開啟", for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.titleLabel?.font =  UIFont(name: "HelveticaNeue", size: 15)
            btn.addTarget(self, action: #selector(requestBtnAct), for: .touchUpInside)
            return btn
        }()
    }
    
    @objc private func requestBtnAct(){
        
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { (settings) in
            switch settings.authorizationStatus{
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { granted, error in
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.3, animations: {
                            self.requestBtn.alpha = 0
                        }, completion: nil)
                    }
                }
                )
            case .denied:
                DispatchQueue.main.async {
                    if let bundleID = Bundle.main.bundleIdentifier,let url = URL(string:UIApplication.openSettingsURLString + bundleID) {
                        UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                            UIView.animate(withDuration: 0.3, animations: {
                                self.requestBtn.alpha = 0
                            }, completion: { _ in self.requestBtn.removeFromSuperview()
                            })
                        })
                    }
                }
            case .authorized:
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.requestBtn.alpha = 0
                    }, completion: { _ in self.requestBtn.removeFromSuperview()
                    })
                }
            case .provisional:
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.requestBtn.alpha = 0
                    }, completion: { _ in self.requestBtn.removeFromSuperview()
                    })
                }
            case .ephemeral:
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.requestBtn.alpha = 0
                    }, completion: { _ in self.requestBtn.removeFromSuperview()
                    })
                }
            @unknown default:
                print("UNUserNotificationCenter.authorizationStatus = default")
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.requestBtn.alpha = 0
                    }, completion: { _ in self.requestBtn.removeFromSuperview()
                    })
                }
            }
        }
    }
    
    fileprivate func activeMailListObserver() {
        
        //先清空所有Observer，因為使用者有可能切換帳號
        NotificationCenter.default.removeObserver(self)
        
        let mailListObserverRef = Database.database().reference(withPath: "MessageRoom/" + UserSetting.UID)
        
        //第一步，先取得chatRoomIDList
        mailListObserverRef.observe(.childAdded, with: { (snapshot) in
            
            let chatRoomID = snapshot.key
            let chatRoomName_photoUrl = (snapshot.value as! String).split(separator: "_")
            var targetUIDs = chatRoomID.split(separator: "-")
            var deleteIndex = 0
            for i in 0 ... targetUIDs.count - 1{
                if(targetUIDs[i] == UserSetting.UID){
                    deleteIndex = i
                }
            }
            targetUIDs.remove(at: deleteIndex)
            if(targetUIDs.count > 1){ //多人模式
                if(chatRoomName_photoUrl.count > 1){
                    AF.request(String(chatRoomName_photoUrl[1])).response { (response) in
                        var photo : UIImage?
                        if let data = response.data, let photoImage = UIImage(data: data) {
                            photo = photoImage
                        }else{
                            photo = nil
                        }
                        //下載房間的最後一句話
                        let chatRoomRef = Database.database().reference(withPath: "Message/" + chatRoomID)
                        chatRoomRef.queryOrdered(byChild: "time").queryLimited(toLast: 1).observe(.childAdded, with: { (snapshot) in
                            let lastMessage = ChatMessage(snapshot: snapshot)
                            self.packageMailData(roomID: chatRoomID, personDetailInfos: nil, headShotImage: photo, shopName: "", lastMessage:lastMessage,roomName:"《" + chatRoomName_photoUrl[0] + "》團")})
                    }
                }
            }else{ //兩人模式
                let personDetailRef = Database.database().reference(withPath: "PersonDetail/" + targetUIDs[0])
                
                //下載PersonDetailInfo
                personDetailRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    let personDetail = PersonDetailInfo(snapshot: snapshot)
                    if let url = personDetail.headShot{
                        //下載頭像
                        AF.request(url).response { (response) in
                            
                            var headshot : UIImage?
                            
                            if let data = response.data, let headShotImage = UIImage(data: data) {
                                headshot = headShotImage
                            }else{
                                headshot = nil
                            }
                            
                            //下載房間的最後一句話
                            let chatRoomRef = Database.database().reference(withPath: "Message/" + chatRoomID)
                            chatRoomRef.queryOrdered(byChild: "time").queryLimited(toLast: 1).observe(.childAdded, with: { (snapshot) in
                                let lastMessage = ChatMessage(snapshot: snapshot)
                                self.packageMailData(roomID: chatRoomID, personDetailInfos: [personDetail], headShotImage: headshot, shopName: "", lastMessage:lastMessage)})
                        }
                    }
                })
            }
            
        })
    }
    
    
    fileprivate func packageMailData(roomID:String,personDetailInfos:[PersonDetailInfo]?,headShotImage:UIImage?,shopName:String,lastMessage:ChatMessage,roomName:String = "") {
        
        print("packageMailData")
        var headShot = UIImage()
        let mailData : MailData
        if headShotImage == nil{
            if personDetailInfos != nil{
                if personDetailInfos![0].gender == 0{
                    headShot = UIImage(named: "girlIcon")!.withRenderingMode(.alwaysTemplate)
                }else{
                    headShot = UIImage(named: "boyIcon")!.withRenderingMode(.alwaysTemplate)
                }
            }else{
                if UserSetting.userGender == 0{
                    headShot = UIImage(named: "boyIcon")!.withRenderingMode(.alwaysTemplate)
                }else{
                    headShot = UIImage(named: "girlIcon")!.withRenderingMode(.alwaysTemplate)
                }
            }
            mailData = MailData(roomID:roomID,personDetailInfos: personDetailInfos, headShotImage: headShot,shopName: shopName,lastMessage: lastMessage,isDefaultHeadShot: true,roomName:roomName)
        }else{
            headShot = headShotImage!
            mailData = MailData(roomID:roomID,personDetailInfos: personDetailInfos, headShotImage: headShot,shopName: shopName,lastMessage: lastMessage,roomName: roomName)
        }
        
        var isExist = false
        if(mailDatas.count > 0){
            for i in 0 ... mailDatas.count - 1{
                if(mailDatas[i].roomID == roomID){
                    mailDatas[i] = mailData
                    isExist = true
                }
            }
        }
        if(!isExist){
            mailDatas.append(mailData)
        }
        
        mailDatas = Util.quicksort_MailData(mailDatas)
        mailDatas.reverse()
        mailListTableView.reloadData()
        
        
        //更新mapView的未讀訊息數量
        let mapViewController = CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController
        var unreadMsgCount = 0
        for mailData in self.mailDatas {
            //確認是否有閱讀過
            if UserDefaults.standard.value(forKey: roomID) != nil{
                let readTimeString = UserDefaults.standard.value(forKey: roomID) as! String
                let readTimeInt = Int(readTimeString) ?? 0
                let dateFormat : String = "YYYYMMddHHmmss"
                let formatter = DateFormatter()
                formatter.dateFormat = dateFormat
                let lastMessagetimeString = formatter.string(from: mailData.lastMessage.sentDate)
                let lastMessagetimeInt = Int(lastMessagetimeString) ?? 0
                if lastMessagetimeInt > readTimeInt{
                    if UserSetting.UID != mailData.lastMessage.user.senderId{
                        unreadMsgCount += 1
                    }
                }
            }else{
                unreadMsgCount += 1
            }
        }
        if mapViewController != nil{
            print("unreadMsgCount:" + "\(unreadMsgCount)") //TODO 似乎有bug
            mapViewController!.setUnreadMsgCount(unreadMsgCount)
        }
        
    }
    
    fileprivate func configTableView() {
        //先將tableView除了frame的部分都設置好
        mailListTableView.delegate = self
        mailListTableView.dataSource = self
        mailListTableView.rowHeight = 104
        mailListTableView.isScrollEnabled = true
        mailListTableView.backgroundColor = .clear
        mailListTableView.separatorColor = .clear
        mailListTableView.bounces = false
        mailListTableView.register(UINib(nibName: "MailListTableViewCell", bundle: nil), forCellReuseIdentifier: "mailListTableViewCell")
    }
    
    
    @objc func gobackBtnAct(){
        CoordinatorAndControllerInstanceHelper.rootCoordinator.rootTabBarController.selectedViewController = CoordinatorAndControllerInstanceHelper.rootCoordinator.mapTab
    }
    
    
    //MARK: - tableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        for subView in tableView.subviews{
            if subView.tag == 999{
                subView.removeFromSuperview()
            }
        }
        if mailDatas.count == 0{
            let noDataLabel = { () -> UILabel in
                let label = UILabel()
                let str = "目前還沒有任何訊息喔！"
                let paraph = NSMutableParagraphStyle()
                paraph.lineSpacing = 8
                let attributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 15),
                                  NSAttributedString.Key.paragraphStyle: paraph]
                label.attributedText = NSAttributedString(string: str, attributes: attributes)
                label.numberOfLines = 0
                label.textColor = .gray
                label.textAlignment = .center
                label.font = UIFont(name: "HelveticaNeue", size: 16)
                label.frame = CGRect(x: tableView.frame.width/2 - label.intrinsicContentSize.width/2, y: 45, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
                label.tag = 999
                return label
            }()
            tableView.addSubview(noDataLabel)
        }
        return mailDatas.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "mailListTableViewCell", for: indexPath) as! MailListTableViewCell
        
        cell.backgroundColor = .clear
        //大頭貼
        cell.headShot.image = mailDatas[indexPath.row].headShotImage
        cell.headShot.contentMode = .scaleAspectFit
        if(mailDatas[indexPath.row].isDefaultHeadShot){
            cell.headShot.tintColor = .lightGray
        }
        
        //標題
        if(mailDatas[indexPath.row].personDetailInfos != nil && mailDatas[indexPath.row].personDetailInfos!.count != 0){
            cell.name.text = mailDatas[indexPath.row].personDetailInfos![0].name//人名
        }else{
            cell.name.text = mailDatas[indexPath.row].roomName//多人房間名
        }
        
        cell.name.textColor = .on().withAlphaComponent(0.9)
        if mailDatas[indexPath.row].shopName != ""{
            cell.shopName.text = "《" + mailDatas[indexPath.row].shopName + "》"
            cell.shopName.textColor = .on().withAlphaComponent(0.9)
        }else{
            cell.shopName.text = ""
        }
        
        
        
        //更新時間
        let dateFormat : String = "MM/dd HH:mm"
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        cell.time.text = formatter.string(from: mailDatas[indexPath.row].lastMessage.sentDate)
        cell.time.textColor = .on().withAlphaComponent(0.9)
        //訊息
        switch mailDatas[indexPath.row].lastMessage.kind {
        case .text(let text):
            if UserSetting.UID == mailDatas[indexPath.row].lastMessage.user.senderId{
                cell.lastMessage.text = "       " + text
                cell.arrowIcon.alpha = 1
            }else{
                cell.lastMessage.text = text
                cell.arrowIcon.alpha = 0
            }
            
            //確認是否有閱讀過
            if UserDefaults.standard.value(forKey: mailDatas[indexPath.row].roomID) != nil{
                let readTimeString = UserDefaults.standard.value(forKey: mailDatas[indexPath.row].roomID) as! String
                let readTimeInt = Int(readTimeString) ?? 0
                let dateFormat : String = "YYYYMMddHHmmss"
                let formatter = DateFormatter()
                formatter.dateFormat = dateFormat
                let lastMessagetimeString = formatter.string(from: mailDatas[indexPath.row].lastMessage.sentDate)
                let lastMessagetimeInt = Int(lastMessagetimeString) ?? 0
                
                if lastMessagetimeInt > readTimeInt{
                    if UserSetting.UID != mailDatas[indexPath.row].lastMessage.user.senderId{
                        cell.lastMessage.textColor = .on().withAlphaComponent(0.7)
                        cell.lastMessage.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
                        cell.lastMessage.tag = 0
                    }else{
                        cell.lastMessage.textColor = .on().withAlphaComponent(0.5)
                        cell.lastMessage.font = UIFont(name: "HelveticaNeue", size: 14)
                        cell.lastMessage.tag = 1
                    }
                }else{
                    cell.lastMessage.textColor = .on().withAlphaComponent(0.5)
                    cell.lastMessage.font = UIFont(name: "HelveticaNeue", size: 14)
                    cell.lastMessage.tag = 1
                }
            }else{
                cell.lastMessage.textColor = .on().withAlphaComponent(0.7)
                cell.lastMessage.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
                cell.lastMessage.tag = 0
            }
            
            
        default:
            break
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView,
                          didSelectRowAt indexPath: IndexPath) {
        // 取消 cell 的選取狀態
        tableView.deselectRow(at: indexPath, animated: false)
    
        viewDelegate?.gotoChatRoom(chatroomID: mailDatas[indexPath.row].roomID, personDetailInfos: mailDatas[indexPath.row].personDetailInfos, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! MailListTableViewCell
        //從未閱讀變成已閱讀過
        if(cell.lastMessage.tag == 0){
            cell.lastMessage.tag = 1
            let mapViewController = CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController
            if mapViewController != nil{
                mapViewController!.setUnreadMsgCount(mapViewController!.unreadMsgCount - 1)
            }
        }
        
        cell.lastMessage.textColor = .on().withAlphaComponent(0.5)
        cell.lastMessage.font = UIFont(name: "HelveticaNeue", size: 14)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
}

//MARK: - MailData


class MailData {
    let roomName : String
    let roomID : String
    let personDetailInfos : [PersonDetailInfo]?
    let headShotImage : UIImage!
    let shopName : String
    let lastMessage : ChatMessage!
    var isDefaultHeadShot : Bool = false
    
    init(roomID:String,personDetailInfos:[PersonDetailInfo]?,headShotImage:UIImage,shopName:String,lastMessage:ChatMessage,isDefaultHeadShot:Bool = false,roomName:String = "") {
        self.roomID = roomID
        self.personDetailInfos = personDetailInfos
        self.headShotImage = headShotImage
        self.shopName = shopName
        self.lastMessage = lastMessage
        self.isDefaultHeadShot = isDefaultHeadShot
        self.roomName = roomName
    }
}
