//
//  ChatMassage.swift
//  ForFastBuilding
//
//  Created by 金融研發一部-邱冠倫 on 2020/05/29.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
//import MessageKit
import CoreLocation
import AVFoundation
import Firebase
import UIKit


internal struct ChatMessage: MessageType {

    var messageId: String
    var sender: SenderType {
        return user
    }
    var sentDate: Date
    var kind: MessageKind
    var user: ChatUser
    
    private init(kind: MessageKind, user: ChatUser, messageId: String, date: Date) {
        self.kind = kind
        self.user = user
        self.messageId = messageId
        self.sentDate = date
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYYMMddHHmmss"
        self.sentDate = formatter.date(from: snapshotValue["time"] as? String ?? "20000408015408")!
        self.messageId = snapshot.key
        self.kind = .text(snapshotValue["text"] as? String ?? "錯誤")
        self.user = ChatUser(senderId: snapshotValue["UID"] as? String ?? "錯誤", displayName: snapshotValue["name"] as? String ?? "錯誤")
    }
    
    
    init(custom: Any?, user: ChatUser, messageId: String, date: Date) {
        self.init(kind: .custom(custom), user: user, messageId: messageId, date: date)
    }

    init(text: String, user: ChatUser, messageId: String, date: Date) {
        self.init(kind: .text(text), user: user, messageId: messageId, date: date)
    }

    init(attributedText: NSAttributedString, user: ChatUser, messageId: String, date: Date) {
        self.init(kind: .attributedText(attributedText), user: user, messageId: messageId, date: date)
    }

    init(image: UIImage, user: ChatUser, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(image: image)
        self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date)
    }

    init(thumbnail: UIImage, user: ChatUser, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(image: thumbnail)
        self.init(kind: .video(mediaItem), user: user, messageId: messageId, date: date)
    }

    init(location: CLLocation, user: ChatUser, messageId: String, date: Date) {
        let locationItem = CoordinateItem(location: location)
        self.init(kind: .location(locationItem), user: user, messageId: messageId, date: date)
    }

    init(emoji: String, user: ChatUser, messageId: String, date: Date) {
        self.init(kind: .emoji(emoji), user: user, messageId: messageId, date: date)
    }

    init(audioURL: URL, user: ChatUser, messageId: String, date: Date) {
        let audioItem = ChatAudioItem(url: audioURL)
        self.init(kind: .audio(audioItem), user: user, messageId: messageId, date: date)
    }

    init(contact: ChatContactItem, user: ChatUser, messageId: String, date: Date) {
        self.init(kind: .contact(contact), user: user, messageId: messageId, date: date)
    }
}



private struct CoordinateItem: LocationItem {

    var location: CLLocation
    var size: CGSize

    init(location: CLLocation) {
        self.location = location
        self.size = CGSize(width: 240, height: 240)
    }

}



private struct ImageMediaItem: MediaItem {

    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize

    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }

}



private struct ChatAudioItem: AudioItem {

    var url: URL
    var size: CGSize
    var duration: Float

    init(url: URL) {
        self.url = url
        self.size = CGSize(width: 160, height: 35)
        // compute duration
        let audioAsset = AVURLAsset(url: url)
        self.duration = Float(CMTimeGetSeconds(audioAsset.duration))
    }

}


struct ChatContactItem: ContactItem {
    
    var displayName: String
    var initials: String
    var phoneNumbers: [String]
    var emails: [String]
    
    init(name: String, initials: String, phoneNumbers: [String] = [], emails: [String] = []) {
        self.displayName = name
        self.initials = initials
        self.phoneNumbers = phoneNumbers
        self.emails = emails
    }
    
}
