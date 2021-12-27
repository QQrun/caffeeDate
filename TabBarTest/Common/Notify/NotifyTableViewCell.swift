//
//  NotifyTableViewCell.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/08/20.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit

class NotifyTableViewCell: UITableViewCell {

    @IBOutlet weak var body: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var separator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        body.textColor = .on().withAlphaComponent(0.9)
        time.textColor = .on().withAlphaComponent(0.7)
        separator.backgroundColor = .on().withAlphaComponent(0.08)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
