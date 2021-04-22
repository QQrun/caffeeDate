//
//  ChatUser.swift
//  ForFastBuilding
//
//  Created by 金融研發一部-邱冠倫 on 2020/05/29.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
//import MessageKit

struct ChatUser: SenderType, Equatable {
    var senderId: String
    var displayName: String
}
