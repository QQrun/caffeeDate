//
//  RegistrationListViewCell.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2022/04/16.
//  Copyright © 2022 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit

class RegistrationListViewCell: UITableViewCell {
    
    
    var headshot : ProfilePhoto? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    func setContent(UID:String,gender:Gender,name:String,age:String,selfIntroduction:String,evaluation:String,isPair:Bool = false){
        
        var tintColor = UIColor.sksBlue().withAlphaComponent(1)
        if(gender == .Girl){
            tintColor = .sksPink()
        }
        headshot = ProfilePhoto(frame: CGRect(x: 8, y: 8, width: 60, height: 60), gender: gender, tintColor: tintColor)
        headshot?.setUID(UID: UID)
        addSubview(headshot!)
        
        let nameLabel = { () -> UILabel in
            let label = UILabel()
            label.text = name
            label.textColor = .on().withAlphaComponent(0.9)
            label.font = UIFont(name: "HelveticaNeue", size: 16)
            label.frame = CGRect(x: 88, y: 10, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            return label
        }()
        addSubview(nameLabel)
        
        
        let dotLabel = { () -> UILabel in
            let label = UILabel()
            label.text = "・"
            label.textColor = .gray
            label.font = UIFont(name: "HelveticaNeue-bold", size: 16)
            label.frame = CGRect(x: nameLabel.frame.origin.x + nameLabel.frame.width, y: 11, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            return label
        }()
        addSubview(dotLabel)
        
        let ageLabel = { () -> UILabel in
            let label = UILabel()
            label.text = age
            label.textColor = .on().withAlphaComponent(0.9)
            label.font = UIFont(name: "HelveticaNeue", size: 16)
            label.frame = CGRect(x: dotLabel.frame.origin.x + dotLabel.frame.width, y: nameLabel.frame.origin.y, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            return label
        }()
        addSubview(ageLabel)
        
        let selfIntroductionLabel = { () -> UILabel in
            let label = UILabel()
            label.text = selfIntroduction
            label.textColor = .on().withAlphaComponent(0.5)
            label.font = UIFont(name: "HelveticaNeue", size: 14)
            label.numberOfLines = 2
            label.frame = CGRect(x: nameLabel.frame.origin.x, y: nameLabel.frame.origin.y + nameLabel.frame.height + 4, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            return label
        }()
        addSubview(selfIntroductionLabel)
        
        let evaluationLabel = { () -> UILabel in
            let label = UILabel()
            label.text = evaluation
            label.textColor = .on().withAlphaComponent(0.7)
            label.font = UIFont(name: "HelveticaNeue", size: 14)
            label.numberOfLines = 2
            label.frame = CGRect(x: frame.width - 16 - label.intrinsicContentSize.width, y: nameLabel.frame.origin.y, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            return label
        }()
        addSubview(evaluationLabel)
        
        let star = UIImageView(frame: CGRect(x: evaluationLabel.frame.origin.x - 16 - 4, y: evaluationLabel.frame.origin.y + 1, width: 16, height: 14.4))
        star.image = UIImage(named: "FullStar")?.withRenderingMode(.alwaysTemplate)
        star.tintColor = UIColor.hexStringToUIColor(hex: "#FBBC05")
        addSubview(star)
        
        if(!isPair){
            let seperator = UIView()
            seperator.frame = CGRect(x: 0, y: frame.height - 1, width: frame.width, height: 1)
            seperator.backgroundColor = .on().withAlphaComponent(0.08)
            addSubview(seperator)
        }else{
            let seperator = UIView()
            seperator.frame = CGRect(x: 0, y: frame.height - 2, width: frame.width, height: 2)
            if(gender == .Boy){
                seperator.backgroundColor = .sksBlue().withAlphaComponent(0.2)
            }else{
                seperator.backgroundColor = .sksPink().withAlphaComponent(0.2)
            }
            addSubview(seperator)
        }
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
        print("setSelected 1")
        
        // Configure the view for the selected state
    }
    
    func goProfile(){
        headshot?.profileBtn?.goProfileBtnAct_ByUID()
    }
    
}
