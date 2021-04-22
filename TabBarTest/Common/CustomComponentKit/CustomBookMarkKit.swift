//
//  File.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/10/06.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import UIKit

class CustomBookMarkKit {
    
    
    var titleLabels : [UILabel] = []
    var titleBtns : [UIButton] = []
    
    init(title:[String],containerView:UIView) {
        
        let separator = { () -> UIImageView in
            let imageView = UIImageView()
            imageView.image = UIImage(named: "分隔線擦痕")
            imageView.frame = CGRect(x:40, y:0, width: containerView.frame.width - 70, height: 1.3)
            imageView.contentMode = .scaleToFill
            return imageView
        }()
        containerView.addSubview(separator)
        
        let separator2 = { () -> UIImageView in
            let imageView = UIImageView()
            imageView.image = UIImage(named: "分隔線擦痕")
            imageView.frame = CGRect(x:40, y:containerView.frame.height - 1.3, width: containerView.frame.width - 70, height: 1.3)
            imageView.contentMode = .scaleToFill
            return imageView
        }()
        containerView.addSubview(separator2)
        
        
        for i in 0 ... title.count - 1 {
            let titleLabel = UILabel()
            titleLabel.text = title[i]
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 15)
            titleLabel.numberOfLines = 0
            titleLabel.textColor = UIColor.hexStringToUIColor(hex: "#414141")
            titleLabel.frame = CGRect(x: (0.5 + CGFloat(i)) * containerView.frame.width/CGFloat(title.count) - titleLabel.intrinsicContentSize.width/2,y: containerView.frame.height/2 -  titleLabel.intrinsicContentSize.height/2,width: titleLabel.intrinsicContentSize.width, height: titleLabel.intrinsicContentSize.height)
            containerView.addSubview(titleLabel)
            titleLabels.append(titleLabel)
            
            let btn = UIButton()
            btn.frame = CGRect(x:CGFloat(i) * containerView.frame.width/CGFloat(title.count),y:0,width: containerView.frame.width/CGFloat(title.count),height: containerView.frame.height)
            containerView.addSubview(btn)
            titleBtns.append(btn)
            
            pressBookMark(at:0) 
        }
        
    }
    
    
    func pressBookMark(at:Int) {
        for i in 0 ... titleLabels.count - 1{
            if i == at{
                titleLabels[i].textColor = UIColor.hexStringToUIColor(hex: "#751010")
                titleLabels[i].font = UIFont(name: "HelveticaNeue-Medium", size: 15)
            }else{
                titleLabels[i].textColor = UIColor.hexStringToUIColor(hex: "#414141")
                titleLabels[i].font = UIFont(name: "HelveticaNeue", size: 15)
            }
        }
    }
    
}
