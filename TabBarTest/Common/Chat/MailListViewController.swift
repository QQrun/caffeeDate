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
    func gotoOneToOneChatRoom(chatroomID:String,personInfo:PersonDetailInfo,animated:Bool)
}


class MailListViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    
    
    var mailListTableView = UITableView()
    
    //寄信人的簡單個人資訊
    var mailDatas : [MailData] = []
    
    weak var viewDelegate : MailListViewControllerDelegate?
    
    var requestBtn = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configTableView()
        activeMailListObserver()
        requestNotiAuthorization()
        CustomBGKit().CreatDarkStyleBG(view: view)
        configMailListTableViewFrame()
        configNotificationRequestBtn()
    }
    
    fileprivate func configMailListTableViewFrame() {
        let window = UIApplication.shared.keyWindow
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0
        let topPadding = window?.safeAreaInsets.top ?? 0
        mailListTableView.frame = CGRect(x: 0, y: topPadding + 1, width: view.frame.width, height: view.frame.height - topPadding - bottomPadding - 1)
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
            let btnColor = UIColor.hexStringToUIColor(hex: "#4F1E1F",alpha: 0.9)
            btn.setBackgroundColor(btnColor, forState: .normal)
            btn.setTitle("尚未開啟通知功能，點擊開啟", for: .normal)
            btn.setTitleColor(UIColor.hexStringToUIColor(hex: "#FFFFFF",alpha: 0.7), for: .normal)
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
            let targetUID = chatRoomID.replace(target: UserSetting.UID, withString: "").replace(target: "-", withString: "")
            
            //第二步，取得PersonDetail與TradeAnnotation中的shopName
            var shopName = ""
            let shopNameRef = Database.database().reference(withPath: "PersonAnnotation/" + targetUID + "/title")
            shopNameRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists(){
                    shopName = snapshot.value as! String
                }
            })
            
            let personDetailRef = Database.database().reference(withPath: "PersonDetail/" + targetUID)
            personDetailRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                let personDetail = PersonDetailInfo(snapshot: snapshot)
                let chatRoomRef = Database.database().reference(withPath: "Message/" + chatRoomID)
                
                
                var firstFetch = true //拿來判斷是否要發本地推播
                //第三步，取得LastMessage的內容、更新時間、發送者UID
                chatRoomRef.queryOrdered(byChild: "time").queryLimited(toLast: 1).observe(.childAdded, with: { (snapshot) in
                    
                    let lastMessage = ChatMessage(snapshot: snapshot)
                    
                    //如果並非第一次抓取，就判斷要不要發本地推播
                    var title : String
                    if shopName != ""{
                        title = "《"+shopName+"》"
                    }else{
                        title = ""
                    }
                    if !firstFetch {
                        if lastMessage.user.senderId != UserSetting.UID{
                            //NotifyHelper.pushNewMsgNoti(title: title, subTitle: lastMessage.user.displayName + "傳送了新訊息給您",chatRoomID: chatRoomID)
                        }
                    }else{
                        firstFetch = false
                        //如果UserDefaults完全沒存chatRoomID的更新時間，代表沒點進去過聊天室，是全新的訊息，這時候要發推播
                        if UserDefaults.standard.string(forKey: chatRoomID) == nil{
                            //NotifyHelper.pushNewMsgNoti(title:  title, subTitle: lastMessage.user.displayName + "傳送了新訊息給您",chatRoomID: chatRoomID)
                        }
                    }
                    //第四步，取得大頭貼後封裝成MailData
                    //先確認是否mail對象已經存在
                    var mailDataExisted = false
                    if self.mailDatas.count > 0{
                        for i in 0 ... self.mailDatas.count - 1{
                            if targetUID == self.mailDatas[i].targetUID{
                                mailDataExisted = true
                                let headShotImage = self.mailDatas[i].headShotImage
                                self.mailDatas.remove(at: i)
                                self.packageMailData(targetUID:targetUID,personDetail: personDetail, headShotImage: headShotImage,shopName: shopName,lastMessage: lastMessage)
                            }
                        }
                    }
                    
                    //如果不存在，下載headShotImage
                    if !mailDataExisted{
                        if let url = personDetail.headShot{
                            AF.request(url).response { (response) in
                                guard let data = response.data, let headShotImage = UIImage(data: data)
                                else {
                                    self.packageMailData(targetUID:targetUID,personDetail: personDetail, headShotImage: nil,shopName: shopName,lastMessage: lastMessage)
                                    return }
                                self.packageMailData(targetUID:targetUID,personDetail: personDetail, headShotImage: headShotImage,shopName: shopName,lastMessage: lastMessage)
                            }
                        }else{
                            self.packageMailData(targetUID:targetUID,personDetail: personDetail, headShotImage: nil,shopName: shopName,lastMessage: lastMessage)
                        }
                        
                    }
                })
                
            }
            )
            
            
        })
    }
    
    fileprivate func packageMailData(targetUID:String,personDetail:PersonDetailInfo,headShotImage:UIImage?,shopName:String,lastMessage:ChatMessage) {
        
        let headShot : UIImage!
        if headShotImage == nil{
            if personDetail.gender == 0{
                headShot = UIImage(named: "girlIcon")
            }else{
                headShot = UIImage(named: "boyIcon")
            }
        }else{
            headShot = headShotImage
        }
        let mailData = MailData(targetUID:targetUID,personDetail: personDetail, headShotImage: headShot,shopName: shopName,lastMessage: lastMessage)
        mailDatas.append(mailData)
        mailDatas = Util.quicksort_MailData(mailDatas)
        mailDatas.reverse()
        mailListTableView.reloadData()
    }
    
    fileprivate func configTableView() {
        //先將tableView除了frame的部分都設置好
        mailListTableView.delegate = self
        mailListTableView.dataSource = self
        mailListTableView.rowHeight = 85
        mailListTableView.isScrollEnabled = true
        mailListTableView.backgroundColor = .clear
        mailListTableView.separatorColor = .clear
        mailListTableView.bounces = false
        mailListTableView.register(UINib(nibName: "MailListTableViewCell", bundle: nil), forCellReuseIdentifier: "mailListTableViewCell")
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
                label.textColor = UIColor.hexStringToUIColor(hex: "D8D8D8")
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
        //人名
        cell.name.text = mailDatas[indexPath.row].personDetail.name
        if mailDatas[indexPath.row].shopName != ""{
            cell.shopName.text = "《" + mailDatas[indexPath.row].shopName + "》"
        }else{
            cell.shopName.text = ""
        }
        
        
        if indexPath.row % 2 == 1{
            cell.separator.transform = CGAffineTransform(rotationAngle: CGFloat.pi)}
        
        //更新時間
        let dateFormat : String = "MM/dd HH:mm"
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        cell.time.text = formatter.string(from: mailDatas[indexPath.row].lastMessage.sentDate)
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
            let sortedIDs = [mailDatas[indexPath.row].targetUID,UserSetting.UID].sorted()
            let chatroomID = sortedIDs[0] + "-" + sortedIDs[1]
            if UserDefaults.standard.value(forKey: chatroomID) != nil{
                let readTimeString = UserDefaults.standard.value(forKey: chatroomID) as! String
                let readTimeInt = Int(readTimeString) ?? 0
                let dateFormat : String = "YYYYMMddHHmmss"
                let formatter = DateFormatter()
                formatter.dateFormat = dateFormat
                let lastMessagetimeString = formatter.string(from: mailDatas[indexPath.row].lastMessage.sentDate)
                let lastMessagetimeInt = Int(lastMessagetimeString) ?? 0
                
                if lastMessagetimeInt > readTimeInt{
                    if UserSetting.UID != mailDatas[indexPath.row].lastMessage.user.senderId{
                        cell.lastMessage.textColor = UIColor.hexStringToUIColor(hex: "FFFFFF")
                        cell.lastMessage.font = UIFont(name: "HelveticaNeue-Medium", size: 13)
                    }else{
                        cell.lastMessage.textColor = UIColor.hexStringToUIColor(hex: "D8D8D8")
                        cell.lastMessage.font = UIFont(name: "HelveticaNeue", size: 13)
                    }
                }else{
                    cell.lastMessage.textColor = UIColor.hexStringToUIColor(hex: "D8D8D8")
                    cell.lastMessage.font = UIFont(name: "HelveticaNeue", size: 13)
                }
            }else{
                cell.lastMessage.textColor = UIColor.hexStringToUIColor(hex: "FFFFFF")
                cell.lastMessage.font = UIFont(name: "HelveticaNeue-Medium", size: 13)
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
        
        let sortedIDs = [mailDatas[indexPath.row].targetUID,UserSetting.UID].sorted()
        let chatroomID = sortedIDs[0] + "-" + sortedIDs[1]
        viewDelegate?.gotoOneToOneChatRoom(chatroomID: chatroomID, personInfo: mailDatas[indexPath.row].personDetail, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! MailListTableViewCell
        cell.lastMessage.textColor = UIColor.hexStringToUIColor(hex: "D8D8D8")
        cell.lastMessage.font = UIFont(name: "HelveticaNeue", size: 13)
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
    let targetUID : String
    let personDetail : PersonDetailInfo!
    let headShotImage : UIImage!
    let shopName : String
    let lastMessage : ChatMessage!
    
    init(targetUID:String,personDetail:PersonDetailInfo,headShotImage:UIImage,shopName:String,lastMessage:ChatMessage) {
        self.targetUID = targetUID
        self.personDetail = personDetail
        self.headShotImage = headShotImage
        self.shopName = shopName
        self.lastMessage = lastMessage
    }
}
