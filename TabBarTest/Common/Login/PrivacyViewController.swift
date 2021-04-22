//
//  PrivacyPolicyViewController.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/11/05.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController {

    @IBOutlet weak var gobackBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.hexStringToUIColor(hex: "1E2124")
        
    }
    @IBAction func gobackBtnAct(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    


}
