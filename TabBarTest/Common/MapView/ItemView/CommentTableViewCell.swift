//
//  CommitTableViewCell.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/04/19.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit
import Firebase

class CommentTableViewCell: UITableViewCell {

    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var heartNumberLabel: UILabel!
    @IBOutlet weak var heartImage: UIImageView!
    @IBOutlet weak var reportBtn: UIButton!
    @IBOutlet weak var heartBtn: UIButton!
    @IBOutlet weak var separator: UIView!
    var userPressLike : Bool = false
    
    var commentID : String!
    var itemID : String!
    var UID : String? {
        didSet{
            let profileBtn = ProfileButton(UID: UID!)
            profileBtn.frame = CGRect(x: 0, y: 0, width: 54, height: 54)
            contentView.addSubview(profileBtn)
        }
    }
    
    
    var genderIcon = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        photo.layer.cornerRadius = 18
        photo.clipsToBounds = true
        
        separator.backgroundColor = .on().withAlphaComponent(0.08)
        nameLabel.textColor = .on().withAlphaComponent(0.7)
        commentLabel.textColor = .on().withAlphaComponent(0.9)
        heartNumberLabel.textColor = .primary()
        heartImage.tintColor = .primary()
        
        
        contentView.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func heartBtnAct(_ sender: Any) {
        
        let likeRef = Database.database().reference().child("Comment/" + itemID + "/" + commentID + "/likeUIDs/" + UserSetting.UID)
        
        let heartNumberLabelText = heartNumberLabel.text!.trimmingCharacters(in: ["+"])
        var heartNumber = Int(heartNumberLabelText)!
        
        if userPressLike{
            heartImage.image = UIImage(named:"空愛心")?.withRenderingMode(.alwaysTemplate)
            likeRef.removeValue()
            heartNumber -= 1
            userPressLike = false
        }else{
            heartImage.image = UIImage(named:"實愛心")?.withRenderingMode(.alwaysTemplate)
            likeRef.setValue(UserSetting.userName)
            heartNumber += 1
            userPressLike = true
        }
        
        if heartNumber > 99{
            heartNumberLabel.text = "99+"
        }else{
            heartNumberLabel.text = "\(heartNumber)"
        }
        
    }

}
