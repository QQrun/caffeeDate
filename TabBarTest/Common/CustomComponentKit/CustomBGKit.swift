//
//  BGKit.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/06/07.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import UIKit

class CustomBGKit{
    
    private var scrollView = UIScrollView()
    private var topPadding : CGFloat = 0
    
    func CreatDarkStyleBG(view:UIView){
        view.backgroundColor = UIColor.hexStringToUIColor(hex: "2B2D2F")
    }
    
    //預設有加scrollView
    func CreatParchmentBG(view:UIView){
        
        let window = UIApplication.shared.keyWindow
        topPadding = window?.safeAreaInsets.top ?? 0

        view.backgroundColor = .white
        
        
        let bulletinBoardBG = UIImageView(frame: CGRect(x: 0, y: 10 + topPadding, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        bulletinBoardBG.contentMode = .scaleToFill
        bulletinBoardBG.image = UIImage(named: "bulletinBoardParchmentBG")
        let oneDegree = CGFloat.pi / 180
        bulletinBoardBG.transform = CGAffineTransform(rotationAngle: oneDegree * 180)
        view.addSubview(bulletinBoardBG)
        
        let topbarHeight : CGFloat = 53 //加陰影部分
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0 + topPadding + topbarHeight, width: view.frame.width, height: view.frame.height - topPadding - topbarHeight))
        scrollView.contentSize = CGSize(width: view.frame.width,height: view.frame.height)
        view.addSubview(scrollView)
    }
    
    func GetScrollView() -> UIScrollView{
        return scrollView
    }
    
}
