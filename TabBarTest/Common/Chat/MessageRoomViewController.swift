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
    let targetPersonInfos : [PersonDetailInfo]!
    
    init(chatroomID: String,targetPersonInfos:[PersonDetailInfo]) {
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
    
    lazy var conversationViewController = ChatViewController(chatroomID: chatroomID,targetPersonInfos: targetPersonInfos)
    
    /// Required for the `MessageInputBar` to be visible
    override var canBecomeFirstResponder: Bool {
        return conversationViewController.canBecomeFirstResponder
    }
    
    /// Required for the `MessageInputBar` to be visible
    override var inputAccessoryView: UIView? {
        return conversationViewController.inputAccessoryView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .surface()
        UserSetting.currentChatTarget = targetPersonInfos[0].name //TODO 不知道怎麼改
        addConversationView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = .clear
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserSetting.currentChatTarget = ""
        navigationController?.navigationBar.isTranslucent = false
//        navigationController?.navigationBar.barTintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let headerHeight: CGFloat = 45
        customTopBarKit.CreatTopBar(view: view,showSeparator: true)
        customTopBarKit.CreatHeatShotAndName(personDetailInfo: targetPersonInfos[0], canGoProfileView: true) //TODO
        let gobackBtn = customTopBarKit.getGobackBtn()
        gobackBtn.addTarget(self, action: #selector(gobackBtnAct), for: .touchUpInside)
        
        let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top ?? 0
        conversationViewController.view.frame = CGRect(x: 0, y: headerHeight + topPadding, width: view.bounds.width, height: view.bounds.height - headerHeight - topPadding)
    }
    
    
    fileprivate func addConversationView() {
        conversationViewController.willMove(toParent: self)
        addChild(conversationViewController)
        view.addSubview(conversationViewController.view)
        conversationViewController.didMove(toParent: self)
    }
    
    @objc private func gobackBtnAct(){
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
}
