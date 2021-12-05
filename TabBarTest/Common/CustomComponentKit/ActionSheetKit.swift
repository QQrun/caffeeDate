//
//  actionSheetCreator.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/05/09.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import UIKit

class ActionSheetKit{
    
    private var bgBtn : UIButton!
    private var btns : [UIButton] = []
    private var containerView : UIView!
    
    //actionSheetText 由下到上:取消btn、依此往上  n+1個
    func creatActionSheet(containerView:UIView,actionSheetText:[String]){
        
        self.containerView = containerView
        
        bgBtn = { () -> UIButton in
            let btn = UIButton()
            btn.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height)
            btn.isEnabled = true
            btn.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            btn.addTarget(self, action: #selector(btnAct), for: .touchUpInside)
            return btn
        }()
        bgBtn.isHidden = true
        containerView.addSubview(bgBtn)
        
        let iWantConcealBtn = UIButton()
        iWantConcealBtn.frame = CGRect(x: 6, y:containerView.frame.height - 53 - 9 - 40, width: containerView.frame.width - 12, height: 53)
//        iWantConcealBtn.setImage(UIImage(named: "ActionSheet_兩邊有弧度"), for: .normal)
        iWantConcealBtn.backgroundColor = .sksWhite()
        iWantConcealBtn.layer.cornerRadius = 6
        iWantConcealBtn.imageView?.contentMode = .scaleToFill
        let iWantConcealLabel = UILabel()
        iWantConcealLabel.text = actionSheetText[0]
        iWantConcealLabel.font = UIFont(name: "HelveticaNeue", size: 18)
        iWantConcealLabel.textColor = .black
        iWantConcealLabel.frame = CGRect(x: iWantConcealBtn.frame.width/2 - iWantConcealLabel.intrinsicContentSize.width/2, y: iWantConcealBtn.frame.height/2 -  iWantConcealLabel.intrinsicContentSize.height/2, width: iWantConcealLabel.intrinsicContentSize.width, height: iWantConcealLabel.intrinsicContentSize.height)
        iWantConcealBtn.addSubview(iWantConcealLabel)
        containerView.addSubview(iWantConcealBtn)
        btns.append(iWantConcealBtn)
        iWantConcealBtn.addTarget(self, action: #selector(btnAct), for: .touchUpInside)
        iWantConcealBtn.isHidden = true
        iWantConcealBtn.frame = CGRect(x: iWantConcealBtn.frame.origin.x, y: iWantConcealBtn.frame.origin.y + containerView.frame.height, width: iWantConcealBtn.frame.width, height: iWantConcealBtn.frame.height)
        
        for i in 1 ... actionSheetText.count - 1{
            let optionBtn = { () -> UIButton in
                let btn = UIButton()
                btn.frame = CGRect(x: 6, y: containerView.frame.height - 53 - 9 * 2 - 53 * CGFloat(i) - 40, width: containerView.frame.width - 12, height: 53)
                btn.addTarget(self, action: #selector(btnAct), for: .touchUpInside)
                var firstOne = false //由下往上不算取消的firstOne
                var lastOne = false
                if i == 1{
                    firstOne = true
                }
                if i == actionSheetText.count - 1{
                    lastOne = true
                }
                btn.backgroundColor = .sksWhite()
                if lastOne && firstOne{
                    btn.roundCorners(corners: [.bottomLeft,.bottomRight,.topRight,.topLeft], radius: 6,shadowRadius:6,shadowOffset: CGSize(width: 2, height: 2),shadowOpacity:0.3)
                }else if firstOne{
                    btn.roundCorners(corners: [.bottomLeft,.bottomRight], radius: 6,shadowRadius:6,shadowOffset: CGSize(width: 2, height: 2),shadowOpacity:0.3)
                }else if lastOne{
                    btn.roundCorners(corners: [.topLeft,.topRight], radius: 6,shadowRadius:6,shadowOffset: CGSize(width: 2, height: 2),shadowOpacity:0.3)
                }else{
                    btn.roundCorners(corners: [.bottomLeft,.bottomRight,.topRight,.topLeft], radius: 0,shadowRadius:6,shadowOffset: CGSize(width: 2, height: 2),shadowOpacity:0.3)
                }
                btn.layer.shadowColor = UIColor.black.cgColor
                btn.layer.shadowRadius = 2
                btn.layer.shadowOffset = CGSize(width: 2, height: 2)
                btn.layer.shadowOpacity = 0.3
                
                let btnLabel = { () -> UILabel in
                    let label = UILabel()
                    label.text = actionSheetText[i]
                    label.font = UIFont(name: "HelveticaNeue", size: 18)
                    label.textColor = .black
                    label.frame = CGRect(x: btn.frame.width/2 - label.intrinsicContentSize.width/2, y: btn.frame.height/2 -  label.intrinsicContentSize.height/2, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
                    return label
                }()
                btn.addSubview(btnLabel)
                btn.isHidden = true
                btn.frame = CGRect(x: btn.frame.origin.x, y: btn.frame.origin.y + containerView.frame.height, width: btn.frame.width, height: btn.frame.height)
                return btn
            }()
            containerView.addSubview(optionBtn)
            btns.append(optionBtn)
        }
        
        
    }
    
    
    private func slideInAnimation(btn : UIButton,containerHeight : CGFloat){
        
        btn.isHidden = false
        UIView.animate(withDuration: 0.15, animations: {
            btn.frame = CGRect(x: btn.frame.origin.x, y: btn.frame.origin.y - containerHeight, width: btn.frame.width, height: btn.frame.height)
        })
        
    }
    
    private func slideOutAnimation(btn : UIButton,containerHight : CGFloat){
        
        UIView.animate(withDuration: 0.3, animations: {
            btn.frame = CGRect(x: btn.frame.origin.x, y: btn.frame.origin.y + containerHight, width: btn.frame.width, height: btn.frame.height)
        },completion: { _ in
            btn.isHidden = true
        })
        
    }
    
    func allBtnSlideIn(){
        bgBtn.isHidden = false
        for btn in btns{
            slideInAnimation(btn: btn, containerHeight: containerView.frame.height)
        }
    }
    func allBtnSlideOut(){
        bgBtn.isHidden = true
        for btn in btns{
            slideOutAnimation(btn: btn, containerHight: containerView.frame.height)
        }
    }
    
    func getActionSheetBtn(i:Int) -> UIButton?{
        if btns.count >= i + 1{
            return btns[i]
        }else{
            return nil
        }
    }
    
    func getbgBtn() -> UIButton{
        return bgBtn
    }
    
    @objc private func btnAct(){
        allBtnSlideOut()
    }
    
    
}
