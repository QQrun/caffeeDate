//
//  ChatViewController.swift
//  ForFastBuilding
//
//  Created by 金融研發一部-邱冠倫 on 2020/05/29.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//


import UIKit
import MapKit
import Firebase
import Alamofire



class ChatViewController: MessagesViewController, MessagesDataSource{
    
    let outgoingAvatarOverlap: CGFloat = 17.5
    let messageAmountToLoadOnce : UInt = 30
    
    var messageList: [ChatMessage] = []
    
    var messageObserverRef : DatabaseReference!
    var messageObserver : UInt!
    
    let refreshControl = UIRefreshControl()
    
    let primaryColor = UIColor.primary()
    let user = ChatUser(senderId: UserSetting.UID, displayName: UserSetting.userName)
    var userAvatar =  Avatar(image: #imageLiteral(resourceName: "cricleButton"), initials: UserSetting.userName)
    lazy var targetAvatar =  Avatar(image: #imageLiteral(resourceName: "cricleButton"), initials: targetPersonInfo.name)
    var targetToken : String?
    
    let customInputBoxKit = CustomInputBoxKit()
    
    let chatroomID : String!
    let targetPersonInfo : PersonDetailInfo!
    
    
    init(chatroomID: String,personInfo:PersonDetailInfo) {
        self.chatroomID = chatroomID
        self.targetPersonInfo = personInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.backgroundColor = .surface()
        
        getTargetToken()
        
        configureMessageCollectionView()
        loadFirstMessages()
        
        getAvatarHeadshot()
        
        configureViewTapGesture()
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configCustomInputBox()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //        MockSocket.shared.connect(with: [SampleData.shared.nathan, SampleData.shared.wu])
        //            .onNewMessage { [weak self] message in
        //                self?.insertMessage(message)
        //        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        customInputBoxKit.removeKeyBoardObserver()
        
        messageObserverRef.removeObserver(withHandle: messageObserver)
        
        //更新已閱讀時間
        //TODO 如果是團體room，不需要更新已閱讀時間
        
        if messageList.count > 0{
            let dateFormat : String = "YYYYMMddHHmmss"
            let formatter = DateFormatter()
            formatter.dateFormat = dateFormat
            let timeString = formatter.string(from: messageList[messageList.count - 1].sentDate)
            UserDefaults.standard.set(timeString, forKey: chatroomID)
            UserDefaults.standard.synchronize()
        }
        
    }
    
    fileprivate func getTargetToken() {
        let tokenRef = Database.database().reference().child("PersonDetail/" +  targetPersonInfo!.UID + "/token")
        tokenRef.observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.exists(){
                self.targetToken = snapshot.value as? String
            }
        })
    }
    
    //點擊空白處結束edit
    fileprivate func configureViewTapGesture() {
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        messagesCollectionView.addGestureRecognizer(viewTap)
    }
    
    @objc func viewTapped() {
        self.view.endEditing(true)
    }
    
    fileprivate func getAvatarHeadshot(){
        
        
        //
        //        if UserSetting.userGender == 0 {
        //            userAvatar = Avatar(image: UIImage(named:"girlIcon"), initials: UserSetting.userName)
        //        }else{
        //            userAvatar = Avatar(image: UIImage(named:"boyIcon"), initials: UserSetting.userName)
        //        }
        //
        //        if targetPersonInfo.gender == 0 {
        //            targetAvatar = Avatar(image: UIImage(named:"girlIcon"), initials: targetPersonInfo.name)
        //        }else{
        //            targetAvatar = Avatar(image: UIImage(named:"boyIcon"), initials: targetPersonInfo.name)
        //        }
        
        //userAvatar =  Avatar(image: #imageLiteral(resourceName: "tapbar_star_active"), initials: UserSetting.userName)
        //targetAvatar
        if let url = UserSetting.userSmallHeadShotURL{
            AF.request(url).response { (response) in
                guard let data = response.data, let image = UIImage(data: data)
                else { return }
                self.userAvatar =  Avatar(image: image, initials: UserSetting.userName)
                self.messagesCollectionView.reloadData()
            }
        }
        if let url = targetPersonInfo.headShot{
            AF.request(url).response { (response) in
                guard let data = response.data, let image = UIImage(data: data)
                else { return }
                self.targetAvatar = Avatar(image: image, initials: UserSetting.userName)
                self.messagesCollectionView.reloadData()
            }
        }
    }
    
    fileprivate func configCustomInputBox() {
        
        messageInputBar.removeFromSuperview()
        messageInputBar.isHidden = true
        //用自己的kit
        customInputBoxKit.isInMessageKit = true
        customInputBoxKit.customInputBoxKitDelegate = self
        customInputBoxKit.creatView(containerView:view)
    }
    
    func configureMessageCollectionView() {
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        //        view.layer.ba = bulletinBoardBG
        //        messagesCollectionView.backgroundView = bulletinBoardBG
        messagesCollectionView.backgroundColor = .clear
        
        //這個在只有行時是對的，但多行後，改成true更好？
        maintainPositionOnKeyboardFrameChanged = false // default false
        
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.sectionInset = UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 8)
        
        // Hide the outgoing avatar and adjust the label alignment to line up with the messages
        layout?.setMessageOutgoingAvatarSize(.zero)
        layout?.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))
        layout?.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))
        
        // Set outgoing avatar to overlap with the message bubble
        layout?.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 18, bottom: outgoingAvatarOverlap, right: 0)))
        layout?.setMessageIncomingAvatarSize(CGSize(width: 30, height: 30))
        layout?.setMessageIncomingMessagePadding(UIEdgeInsets(top: 0, left: -18, bottom: 0, right: 18))
        
        //        layout?.setMessageIncomingAccessoryViewSize(CGSize(width: 30, height: 30))
        //        layout?.setMessageIncomingAccessoryViewPadding(HorizontalEdgeInsets(left: 8, right: 0))
        //        layout?.setMessageIncomingAccessoryViewPosition(.messageBottom)
        //        layout?.setMessageOutgoingAccessoryViewSize(CGSize(width: 30, height: 30))
        //        layout?.setMessageOutgoingAccessoryViewPadding(HorizontalEdgeInsets(left: 0, right: 8))
        
        
        messagesCollectionView.addSubview(refreshControl)
        refreshControl.tintColor = .black
        refreshControl.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
    }
    func loadFirstMessages(){
        self.messagesCollectionView.alpha = 0
        messageObserverRef = Database.database().reference(withPath: "Message/" + self.chatroomID!)
        
        //先一次取得前30筆
        messageObserverRef.queryOrdered(byChild: "time").queryLimited(toLast: messageAmountToLoadOnce).observeSingleEvent(of:.value, with: { (snapshot) in
            
            let snapshots : [DataSnapshot] = snapshot.children.allObjects as? [DataSnapshot] ?? []
            
            for snap in snapshots{
                self.messageList.append(ChatMessage(snapshot: snap))
                print("insertMessage")
                print(self.messagesCollectionView.frame.height)

                
            }
            
            if(self.messageList.count > 6){
                self.maintainPositionOnKeyboardFrameChanged = true
            }
            
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToBottom(animated: false)
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {  UIView.animate(withDuration: 0.2, animations: {
                self.messagesCollectionView.alpha = 1
            })}
            
            //監聽之後新增的筆數
            var isFirstLoad = true
            if self.messageList.count == 0{
                isFirstLoad = false
            }
            self.messageObserver = self.messageObserverRef.queryOrdered(byChild: "time").queryLimited(toLast: 1).observe(.childAdded, with: { (snapshot) in
                
                if isFirstLoad{
                    isFirstLoad = false
                    return
                }
                let message = ChatMessage(snapshot: snapshot)
                self.messageList.append(message)
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom(animated: true)
                
                
                
                if(self.messageList.count > 6){
                    self.maintainPositionOnKeyboardFrameChanged = true
                }

            }
            )
            
        }
        )
        
        
        
    }
    
    fileprivate func updateMessageToFireBase(_ text: String) {
        let messageId = NSUUID().uuidString
        let messageRef = Database.database().reference(withPath: "Message/" + chatroomID + "/" + messageId)
        
        let currentTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMddHHmmss"
        let currentTimeString = dateFormatter.string(from: currentTime)
        
        let messageValue =
            [
                "time": currentTimeString,
                "UID": UserSetting.UID,
                "name": UserSetting.userName,
                "text": text,
                "targetToken":targetToken,
            ]
        messageRef.setValue(messageValue)
    }
    
    // MARK: - Helpers
    
    func insertMessage(_ message: ChatMessage) {
        //        print("insertMessage")
        
    
        messageList.append(message)
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
    }
    
    
    func isLastSectionVisible() -> Bool {
        
        guard !messageList.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    //MARK: - MessagesDataSource
    
    func currentSender() -> SenderType {
        return user
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if !isNextMessageSameSender(at: indexPath) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd HH:mm"
            let dateString = dateFormatter.string(from: messageList[indexPath.section].sentDate)
            return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1),NSAttributedString.Key.foregroundColor:UIColor.darkGray])
        }
        return nil
    }
    
    
    
    //MARK: - Act
    
    @objc
    func loadMoreMessages() {
        
        DispatchQueue.global(qos: .userInitiated).async {
            let messageObserverRef = Database.database().reference(withPath: "Message/" + self.chatroomID!)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYYMMddHHmmss"
            if self.messageList.count == 0 {
                messageObserverRef.queryOrdered(byChild: "time").queryLimited(toLast: self.messageAmountToLoadOnce).observeSingleEvent(of: .value, with: { (snapshot) in
                    var childSnapShots = snapshot.children.allObjects as! [DataSnapshot]
                    childSnapShots.remove(at: childSnapShots.count - 1)
                    childSnapShots.reverse()
                    for childSnapShot in childSnapShots{
                        let message = ChatMessage(snapshot: childSnapShot)
                        self.messageList.insert(message, at: 0)
                    }
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                    self.refreshControl.endRefreshing()
                })
            }else{
                messageObserverRef.queryOrdered(byChild: "time").queryLimited(toLast: self.messageAmountToLoadOnce).queryEnding(atValue: dateFormatter.string(from: self.messageList[0].sentDate)).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    var childSnapShots = snapshot.children.allObjects as! [DataSnapshot]
                    childSnapShots.remove(at: childSnapShots.count - 1)
                    childSnapShots.reverse()
                    for childSnapShot in childSnapShots{
                        let message = ChatMessage(snapshot: childSnapShot)
                        self.messageList.insert(message, at: 0)
                    }
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                    self.refreshControl.endRefreshing()
                })}
        }
    }
    
}


// MARK: - MessageCellDelegate

extension ChatViewController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        print("Image tapped")
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom cell label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }
    
    func didTapPlayButton(in cell: AudioMessageCell) {
        //        guard let indexPath = messagesCollectionView.indexPath(for: cell),
        //            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
        //                print("Failed to identify message when audio cell receive tap gesture")
        //                return
        //        }
        //        guard audioController.state != .stopped else {
        //            // There is no audio sound playing - prepare to start playing for given audio message
        //            audioController.playSound(for: message, in: cell)
        //            return
        //        }
        //        if audioController.playingMessage?.messageId == message.messageId {
        //            // tap occur in the current cell that is playing audio sound
        //            if audioController.state == .playing {
        //                audioController.pauseSound(for: message, in: cell)
        //            } else {
        //                audioController.resumeSound()
        //            }
        //        } else {
        //            // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
        //            audioController.stopAnyOngoingPlaying()
        //            audioController.playSound(for: message, in: cell)
        //        }
    }
    
    func didStartAudio(in cell: AudioMessageCell) {
        print("Did start playing audio sound")
    }
    
    func didPauseAudio(in cell: AudioMessageCell) {
        print("Did pause audio sound")
    }
    
    func didStopAudio(in cell: AudioMessageCell) {
        print("Did stop audio sound")
    }
    
    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        print("Accessory view tapped")
    }
    
}


// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention: return [.foregroundColor: UIColor.blue]
        default: return MessageLabel.defaultAttributes
        }
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? primaryColor : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 0.5)
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        //        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        //        return .bubbleTail(tail, .curved)
        
        var corners: UIRectCorner = []
        if isFromCurrentSender(message: message) {
            corners.formUnion(.topLeft)
            corners.formUnion(.bottomLeft)
            if !isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topRight)
            }
            if !isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomRight)
            }
        } else {
            corners.formUnion(.topRight)
            corners.formUnion(.bottomRight)
            if !isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topLeft)
            }
            if !isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomLeft)
            }
        }
        
        return .custom { view in
            let radius: CGFloat = 16
            let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            view.layer.mask = mask
        }
        
    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return messageList[indexPath.section].user == messageList[indexPath.section - 1].user
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messageList.count else { return false }
        return messageList[indexPath.section].user == messageList[indexPath.section + 1].user
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if isFromCurrentSender(message: message) {
            avatarView.isHidden = true
        }else{
            avatarView.set(avatar: targetAvatar)
            avatarView.isHidden = isNextMessageSameSender(at: indexPath)
        }
    }
    
    // MARK: - Location Messages
    
    func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
        let pinImage = #imageLiteral(resourceName: "ic_map_marker")
        annotationView.image = pinImage
        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
        return annotationView
    }
    
    func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
        return { view in
            view.layer.transform = CATransform3DMakeScale(2, 2, 2)
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
                view.layer.transform = CATransform3DIdentity
            }, completion: nil)
        }
    }
    
    func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {
        
        return LocationMessageSnapshotOptions(showsBuildings: true, showsPointsOfInterest: true, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    }
    
    // MARK: - Audio Messages
    
    func audioTintColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : UIColor(red: 15/255, green: 135/255, blue: 255/255, alpha: 1.0)
    }
    
    func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
        //        audioController.configureAudioCell(cell, message: message) // this is needed especily when the cell is reconfigure while is playing sound
    }
    
}

// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        //        if isTimeLabelVisible(at: indexPath) {
        //            return 18
        //        }
        return 0
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isFromCurrentSender(message: message) {
            return !isPreviousMessageSameSender(at: indexPath) ? (5 + outgoingAvatarOverlap) : 0
        } else {
            return !isPreviousMessageSameSender(at: indexPath) ? (5 + outgoingAvatarOverlap) : 0
        }
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return (!isNextMessageSameSender(at: indexPath)) ? 16 : 0
    }
}


//MARK:- CustomInputBoxKitDelegate

extension ChatViewController : CustomInputBoxKitDelegate{
    
    func addBtnAction() {
        self.view.endEditing(true)
        
    }
    
    
    func textViewBeginEditing() {
        
    }
    
    
    func publishCompletion() {
        let content = customInputBoxKit.getInputBoxTextViewText()
        
        //如果是第一筆訊息，就建立MessageRoom節點
        if messageList.count == 0{
            var messageRoomRef : DatabaseReference!
            chatroomID.components(separatedBy: "-").forEach{
                (uid) in
                messageRoomRef = Database.database().reference(withPath: "MessageRoom/" + uid + "/" + chatroomID)
                messageRoomRef.setValue(0)
            }
        }
        
        updateMessageToFireBase(content)
    }
    
}

