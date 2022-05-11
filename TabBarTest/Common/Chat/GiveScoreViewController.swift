//
//  GiveScoreViewController.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2022/05/11.
//  Copyright © 2022 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit

class GiveScoreViewController: UIViewController {

    let customTopBarKit = CustomTopBarKit()
    
    let UID : String!
    let name : String!
    
    init(UID: String,name:String) {
        self.UID = UID
        self.name = name
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .surface()
        configTopBar()
    }
    
    fileprivate func configTopBar() {
        customTopBarKit.CreatTopBar(view: view,showSeparator: true)
        customTopBarKit.CreatCenterTitle(text: "給" + name + "評分")
        customTopBarKit.getGobackBtn().addTarget(self, action: #selector(gobackBtnAct), for: .touchUpInside)
        
        customTopBarKit.CreatDoSomeThingTextBtn(text: "確認")
        customTopBarKit.getDoSomeThingBtn().addTarget(self, action: #selector(confirmBtnAct), for: .touchUpInside)
    }
    
    @objc private func gobackBtnAct(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func confirmBtnAct(){
        self.navigationController?.popViewController(animated: true)
    }
    
}
