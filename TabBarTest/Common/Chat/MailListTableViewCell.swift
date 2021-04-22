//
//  MailListTableViewCell.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/06/28.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit

class MailListTableViewCell: UITableViewCell {

    @IBOutlet weak var headShot: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var shopName: UILabel!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var arrowIcon: UIImageView!
    @IBOutlet weak var separator: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.backgroundColor = .clear
        
        headShot.contentMode = .scaleAspectFill
        headShot.backgroundColor = .clear
        headShot.layer.cornerRadius = 33
        headShot.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
           super.setSelected(selected, animated: animated)

           // Configure the view for the selected state
    }
}
