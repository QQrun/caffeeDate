/*
 MIT License
 
 Copyright (c) 2017-2019 MessageKit
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit
import Firebase

final class MessageRoomViewController: UIViewController {
    
    let customTopBarKit = CustomTopBarKit()
    let chatroomID : String!
    let targetPersonInfos : [PersonDetailInfo]?
    let moreActionSheetKit = ActionSheetKit()
    
    //評分用
    let scoreWhoActionSheetKit = ActionSheetKit()
    var names : [String]?
    var uids : [String]?
    
    init(chatroomID: String,targetPersonInfos:[PersonDetailInfo]?) {
        self.chatroomID = chatroomID
        self.targetPersonInfos = targetPersonInfos
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

   
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    lazy var chatViewController = ChatViewController(chatroomID: chatroomID,targetPersonInfos: targetPersonInfos)
    
    /// Required for the `MessageInputBar` to be visible
    override var canBecomeFirstResponder: Bool {
        return chatViewController.canBecomeFirstResponder
    }
    
    /// Required for the `MessageInputBar` to be visible
    override var inputAccessoryView: UIView? {
        return chatViewController.inputAccessoryView
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .surface()
        UserSetting.currentChatRoomID = chatroomID
        addConversationView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = .clear
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserSetting.currentChatRoomID = ""
        navigationController?.navigationBar.isTranslucent = false
    }
    
    
    var alreadyCreateTopBar = false
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let headerHeight: CGFloat = 45
        let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top ?? 0
        chatViewController.view.frame = CGRect(x: 0, y: headerHeight + topPadding, width: view.bounds.width, height: view.bounds.height - headerHeight - topPadding)
        if(!alreadyCreateTopBar){
            alreadyCreateTopBar = true
            configTopBar()
        }
    }
    
    
    fileprivate func addConversationView() {
        chatViewController.willMove(toParent: self)
        addChild(chatViewController)
        view.addSubview(chatViewController.view)
        chatViewController.didMove(toParent: self)
    }
    
    fileprivate func creatMoreBtnActionSheet() {
        let actionSheetText = ["取消","給予聚會夥伴評分"]
        moreActionSheetKit.creatActionSheet(containerView: view, actionSheetText: actionSheetText)
        moreActionSheetKit.getActionSheetBtn(i: 1)?.addTarget(self, action: #selector(scoreAct), for: .touchUpInside)
    }
    
    @objc private func gobackBtnAct(){
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc private func moreBtnAct(){
        moreActionSheetKit.allBtnSlideIn()
    }
    
    fileprivate func configTopBar() {
        
        customTopBarKit.CreatTopBar(view: view,showSeparator: true)
        customTopBarKit.CreatMoreBtn()
        customTopBarKit.getMoreBtn().addTarget(self, action: #selector(moreBtnAct), for: .touchUpInside)
        creatMoreBtnActionSheet()
        
        if(targetPersonInfos != nil && targetPersonInfos!.count == 1){
            customTopBarKit.CreatHeatShotAndName(personDetailInfo: targetPersonInfos![0], canGoProfileView: true,completion: {
                img -> () in
                self.chatViewController.targetAvatars[0] = Avatar(image: img, initials: "")
                self.chatViewController.messagesCollectionView.reloadData()
            })
        }else{
            let splitUID = chatroomID.split(separator: "-")
            if(splitUID.count == 2){
                var targetUID = ""
                for id in splitUID{
                    if(String(id) != UserSetting.UID){
                        targetUID = String(id)
                    }
                }
                let ref = Database.database().reference()
                ref.child("PersonDetail/" + targetUID).observeSingleEvent(of: .value, with:{(snapshot) in
                    if snapshot.exists(){
                        let personDetail = PersonDetailInfo(snapshot: snapshot)
                        self.customTopBarKit.CreatHeatShotAndName(personDetailInfo: personDetail, canGoProfileView: true,completion: {
                            img -> () in
                            self.chatViewController.targetAvatars[0] = Avatar(image: img, initials: "")
                            self.chatViewController.messagesCollectionView.reloadData()
                        })
                    }
                })
            }else if (splitUID.count == 4){
                uids = []
                uids!.append(UserSetting.UID)
                for id in splitUID{
                    if(String(id) != UserSetting.UID){
                        uids!.append(String(id))
                    }
                }
                customTopBarKit.Creat4photo(UIDs: uids!, completion: {
                    imgs,names -> () in
                    
                    self.names = names
                    self.configMultiScoreActionSheet()
                    
                    self.chatViewController.targetAvatars[0] = Avatar(image: imgs[1], initials: "")
                    self.chatViewController.targetAvatars[1] = Avatar(image: imgs[2], initials: "")
                    self.chatViewController.targetAvatars[2] = Avatar(image: imgs[3], initials: "")
                    self.chatViewController.messagesCollectionView.reloadData()
                    
                })
            }
        }
        
        let gobackBtn = customTopBarKit.getGobackBtn()
        gobackBtn.addTarget(self, action: #selector(gobackBtnAct), for: .touchUpInside)
    }
    
    fileprivate func configMultiScoreActionSheet() {
        
        var actionSheetText = ["取消"]
        actionSheetText.append(names![1])
        actionSheetText.append(names![2])
        actionSheetText.append(names![3])
        scoreWhoActionSheetKit.creatActionSheet(containerView: view, actionSheetText: actionSheetText)
        scoreWhoActionSheetKit.getActionSheetBtn(i: 0)?.addTarget(self, action: #selector(cancelAct), for: .touchUpInside)
        scoreWhoActionSheetKit.getActionSheetBtn(i: 1)?.addTarget(self, action: #selector(scorefirstAct), for: .touchUpInside)
        scoreWhoActionSheetKit.getActionSheetBtn(i: 2)?.addTarget(self, action: #selector(scoreSecondAct), for: .touchUpInside)
        scoreWhoActionSheetKit.getActionSheetBtn(i: 3)?.addTarget(self, action: #selector(scoreThirdAct), for: .touchUpInside)
        
    }
    
    @objc private func scoreAct(){
        
        moreActionSheetKit.allBtnSlideOut()
        
        if(targetPersonInfos != nil && targetPersonInfos!.count == 1){
            goGiveScorePage(UID:targetPersonInfos![0].UID,name: targetPersonInfos![0].name)
        }else{
            if(names == nil || names!.count < 4){
                showToast(message: "讀取中，請數秒後再試")
                return
            }
            scoreWhoActionSheetKit.allBtnSlideIn()
        }
    }
    
    @objc private func scorefirstAct(){
        goGiveScorePage(UID:uids![1],name: names![1])
    }
    @objc private func scoreSecondAct(){
        goGiveScorePage(UID:uids![2],name: names![2])
    }
    @objc private func scoreThirdAct(){
        goGiveScorePage(UID:uids![3],name: names![3])
    }
    
    @objc private func cancelAct(){
        scoreWhoActionSheetKit.allBtnSlideOut()
    }
    
    private func goGiveScorePage(UID:String,name:String){
        let giveScoreViewController = ScorePersonViewController(UID: UID,name: name)
        giveScoreViewController.modalPresentationStyle = .overCurrentContext
        if let viewController = CoordinatorAndControllerInstanceHelper.rootCoordinator.rootTabBarController.selectedViewController{
            (viewController as! UINavigationController).pushViewController(giveScoreViewController, animated: true)
        }
    }
}
