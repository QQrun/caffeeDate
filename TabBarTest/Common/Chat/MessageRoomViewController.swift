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
        
        var chatTargetNames : [String] = []
        if(targetPersonInfos != nil){
            for info in targetPersonInfos!{
                chatTargetNames.append(info.name)
            }
        }else{
            //TODO 這個應該要改function? currentChatTarget不應該是name 應該是 UID
        }
        UserSetting.currentChatTarget = chatTargetNames
        addConversationView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = .clear
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserSetting.currentChatTarget = []
        navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let headerHeight: CGFloat = 45
        customTopBarKit.CreatTopBar(view: view,showSeparator: true)
        
        if(targetPersonInfos != nil && targetPersonInfos!.count == 1){
            customTopBarKit.CreatHeatShotAndName(personDetailInfo: targetPersonInfos![0], canGoProfileView: true,completion: {
                img -> () in
                self.chatViewController.targetAvatars[0] = Avatar(image: img, initials: "")
                self.chatViewController.messagesCollectionView.reloadData()
            })
        }else{
            let splitUID = chatroomID.split(separator: "-")
            var uids : [String] = []
            uids.append(UserSetting.UID)
            for id in splitUID{
                if(String(id) != UserSetting.UID){
                    uids.append(String(id))
                }
            }
            customTopBarKit.Creat4photo(UIDs: uids, completion: {
                imgs -> () in
                
                self.chatViewController.targetAvatars[0] = Avatar(image: imgs[1], initials: "")
                self.chatViewController.targetAvatars[1] = Avatar(image: imgs[2], initials: "")
                self.chatViewController.targetAvatars[2] = Avatar(image: imgs[3], initials: "")
                self.chatViewController.messagesCollectionView.reloadData()
                
            })
        }

        let gobackBtn = customTopBarKit.getGobackBtn()
        gobackBtn.addTarget(self, action: #selector(gobackBtnAct), for: .touchUpInside)
        
        let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top ?? 0
        chatViewController.view.frame = CGRect(x: 0, y: headerHeight + topPadding, width: view.bounds.width, height: view.bounds.height - headerHeight - topPadding)
    }
    
    
    fileprivate func addConversationView() {
        chatViewController.willMove(toParent: self)
        addChild(chatViewController)
        view.addSubview(chatViewController.view)
        chatViewController.didMove(toParent: self)
    }
    
    @objc private func gobackBtnAct(){
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
}
