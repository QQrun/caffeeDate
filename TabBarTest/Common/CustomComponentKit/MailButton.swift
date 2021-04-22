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
        self.setImage(UIImage(named: "飛鴿傳書icon"), for: .normal)
        self.isEnabled = true
        self.addTarget(self, action: #selector(self.mailBtnAct), for: .touchUpInside)
    }
    
    @objc func mailBtnAct(){
        let sortedIDs = [personInfo.UID,UserSetting.UID].sorted()
        let chatroomID = sortedIDs[0] + "-" + sortedIDs[1]
        
        let rootCoordinator = CoordinatorAndControllerInstanceHelper.rootCoordinator
        rootCoordinator?.gotoOneToOneChatRoom(chatroomID: chatroomID, personInfo: personInfo, animated: false)
        Analytics.logEvent("寄信按鈕", parameters:nil)
    }
}
