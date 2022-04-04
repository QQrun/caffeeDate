//
//  ProfilePhoto.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2022/03/11.
//  Copyright © 2022 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class ProfilePhoto : UIView{
    
    var loadingView : UIImageView?
    var circle: UIView?
    var headShot : UIImageView?
    
    private var isAccompanyLabel : UILabel?
    
    init(frame:CGRect,gender:Gender,tintColor:UIColor) {
        super.init(frame: frame)
        
        loadingView = UIImageView(frame: CGRect(x: self.frame.width * 1/12, y: self.frame.height * 1/12, width: self.frame.width * 5/6, height: self.frame.height * 5/6))
        loadingView!.contentMode = .scaleAspectFit
        if gender == .Boy{
            loadingView!.image = UIImage(named: "boyIcon")?.withRenderingMode(.alwaysTemplate)
        }else{
            loadingView!.image = UIImage(named: "girlIcon")?.withRenderingMode(.alwaysTemplate)
        }
        loadingView!.tintColor = tintColor
        addSubview(loadingView!)
        
        circle = UIView()
        circle!.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        circle!.layer.cornerRadius = self.frame.width/2
        if gender == .Boy{
            circle!.backgroundColor = .sksBlue()
        }else{
            circle!.backgroundColor = .sksPink()
        }
        circle!.alpha = 0
        addSubview(circle!)
        
        headShot = UIImageView()
        headShot!.frame = CGRect(x: 1.5, y: 1.5, width: self.frame.width - 3, height: self.frame.height - 3)
        headShot!.contentMode = .scaleAspectFill
        headShot!.alpha = 0
        headShot!.layer.cornerRadius = (self.frame.width - 3)/2
        headShot!.clipsToBounds = true
        addSubview(headShot!)
        
    }
    
    func setUID(UID:String){
        let ref = Database.database().reference()
        ref.child("PersonDetail/" + UID + "/" + "headShot").observeSingleEvent(of: .value, with:{(snapshot) in
            if snapshot.exists(){
                AF.request(snapshot.value as! String).response { (response) in
                    guard let data = response.data, let image = UIImage(data: data)
                    else { return }
                    self.headShot!.image = image
                    UIView.animate(withDuration: 0.4, animations:{
                        self.headShot!.alpha = 1
                        self.circle!.alpha = 1
                        self.loadingView!.alpha = 0
                    })
                }
            }
        })
        
        let profileBtn = ProfileButton(UID: UID)
        profileBtn.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        self.addSubview(profileBtn)
    }
    
    func isAccompany(_ text:String){
        circle!.alpha = 1
        loadingView!.alpha = 0
        isAccompanyLabel = UILabel()
        isAccompanyLabel?.numberOfLines = 2
        isAccompanyLabel?.text = text
        isAccompanyLabel?.font = isAccompanyLabel?.font.withSize(13)
        isAccompanyLabel?.textColor = .white
        isAccompanyLabel?.frame = CGRect(x: 0, y: self.frame.height/2 - (isAccompanyLabel?.intrinsicContentSize.height)!/2, width: self.frame.width, height: (isAccompanyLabel?.intrinsicContentSize.height)!)
        isAccompanyLabel?.textAlignment = .center
        addSubview(isAccompanyLabel!)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
