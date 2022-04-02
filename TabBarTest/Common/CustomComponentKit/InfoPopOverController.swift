//
//  PrivacyPolicyViewController.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/11/05.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit

class InfoPopOverController: UIViewController {

    
    var titleString = "" //設置後，會覆蓋
    var contentString = "" //設置後，會覆蓋
    
    @IBOutlet weak var gobackBtn: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet weak var seperator: UIView!
    @IBOutlet weak var content: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .surface()
        seperator.backgroundColor = .on().withAlphaComponent(0.16)
        titleLabel.textColor = .on().withAlphaComponent(0.9)
        content.textColor = .on().withAlphaComponent(0.7)
        gobackBtn.tintColor = .gray
        if(titleString != ""){
            titleLabel.text = titleString
        }
        if(contentString != ""){
            content.text = contentString
        }
    }
    
    @IBAction func gobackBtnAct(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    


}
