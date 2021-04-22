//
//  PhotoTableViewCell.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/04/13.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {
    
    
    var photo : UIImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.frame =  CGRect(x: 0, y: 0, width: 96, height: 96)
        
        photo = {
            let imageView = UIImageView()
            imageView.frame = CGRect(x: 0, y: 0, width: 96, height: 96)
            let oneDegree = CGFloat.pi / 180
            imageView.transform = CGAffineTransform(rotationAngle: oneDegree * 90)
            imageView.backgroundColor = .clear
            return imageView
        }()
        contentView.addSubview(photo)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}
