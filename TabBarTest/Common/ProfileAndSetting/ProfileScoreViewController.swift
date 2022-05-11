//
//  ProfileScoreViewController.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2022/05/12.
//  Copyright © 2022 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit

class ProfileScoreViewController: UIViewController {

    let customTopBarKit = CustomTopBarKit()
    
    let personDetail : PersonDetailInfo!
    
    init(personDetail: PersonDetailInfo) {
        self.personDetail = personDetail
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
        customTopBarKit.CreatCenterTitle(text: personDetail.name)
        customTopBarKit.getGobackBtn().addTarget(self, action: #selector(gobackBtnAct), for: .touchUpInside)
        
    }
    
    @objc private func gobackBtnAct(){
        self.navigationController?.popViewController(animated: true)
    }
    

}
