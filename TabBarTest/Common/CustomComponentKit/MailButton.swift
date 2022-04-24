//
//  MailButton.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/06/11.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class MailButton : UIButton {

    var personInfo : PersonDetailInfo!

    convenience init(personInfo:PersonDetailInfo) {
        self.init()
        self.personInfo = personInfo
        var mailImage = UIImage(named: "icons24MessageFilledGrey24")?.withRenderingMode(.alwaysTemplate)
        self.setImage(mailImage, for: .normal)
        self.contentMode = .scaleAspectFit
        self.setImage(mailImage?.imageWithInsets(insets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.backgroundColor = .primary()
        self.layer.cornerRadius = 14
        self.tintColor = .white
        self.addTarget(self, action: #selector(self.mailBtnAct), for: .touchUpInside)
    }
    
    @objc func mailBtnAct(){
        let sortedIDs = [personInfo.UID,UserSetting.UID].sorted()
        let chatroomID = sortedIDs[0] + "-" + sortedIDs[1]
        
        let rootCoordinator = CoordinatorAndControllerInstanceHelper.rootCoordinator
        rootCoordinator?.gotoChatRoom(chatroomID: chatroomID, personDetailInfos: [personInfo], animated: false)
        Analytics.logEvent("寄信按鈕", parameters:nil)
    }
}
