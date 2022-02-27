//
//  ChooseLocationViewController.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2022/02/25.
//  Copyright © 2022 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import UIKit

class ChooseLocationViewController2 : UIViewController{
    
    var holdShareSeatViewController : HoldShareSeatViewController
    
    //隐藏狀態欄
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    init(holdShareSeatViewController:HoldShareSeatViewController) {
        self.holdShareSeatViewController = holdShareSeatViewController
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setBackground()
        
        view.backgroundColor = .sksPink()
        
    }
}
